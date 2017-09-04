%%
% --- user inputs
% clear;
asset = 'soybean';
businessDaysPerYear = 252;
daysPerYear = 365;
addOn = 0;

%% --- rates
ratesSec = 'CCSWOC CMPN Curncy';    %CNY IRS(7D repo) 3MO
%note:DayCount = ACT/365 and PayFrequency = 'Quarterly'
data = getdata(conn,ratesSec,'px_last');
rates = data.px_last/100 + addOn/10000;
fprintf('\tinterest rate: %4.2f%%\n',rates*100);

%%
% --- option user inputs
tenor = '4m';

%futures/forward assuming paying the fixed dividend as of the rates
%yield curve
divType = {'continuous'};
divAmount = rates;

settle = today;
expiry = dateadd(today,tenor);
fprintf('\toption expired on: %s\n',datestr(expiry));

%%
%forecast volatility
fprintf('rolling discrete futures and estimate/forecast volatility with GARCH model...\n');
exerciseDates = gendates('FromDate',settle,'ToDate',expiry);
nForecastPeriod = length(exerciseDates);
fprintf('\tnumber of business days to expiry:%d\n',nForecastPeriod);
rollinfo = rollfutures(asset,'CalcDailyReturn',true,...
    'CalibrateVolModel',true,...
    'PrintResults',false,...
    'PlotConditonalVariance',true,...
    'ForecastPeriod',nForecastPeriod,...
    'UpdateTimeSeries',true);

fprintf('\tlast observation date: %s; close at %f\n',...
    datestr(rollinfo.ContinousFutures(end,1)),...
    rollinfo.ContinousFutures(end,2));

lv = rollinfo.ForecastResults.LongTermAnnualVol;
fv = rollinfo.ForecastResults.ForecastedAnnualVol;
fprintf('\tforecast period length:%d business days\n',nForecastPeriod);
fprintf('\tlg term annual-vol of %s: %4.1f%%\n',asset,lv*100);
fprintf('\tfcat forecast period annual-vol of %s: %4.1f%%\n',asset,fv*100);

hv = rollinfo.ForecastResults.HistoricalAnnualVol;
fprintf('\thist forecast period annual-vol of %s: %4.1f%%\n',...
    asset,hv*100);
ewmav = rollinfo.ForecastResults.EWMAAnnualVol;
fprintf('\tewma forecast period annual-vol of %s: %4.1f%%\n',...
    asset,ewmav*100);
fprintf('\n');

%%
%timeseries plotting
close all;
indexSynthetic = rollinfo.ContinousFutures;
indexSynthetic(1,2) = 1.0;
for i = 2:size(indexSynthetic,1)
    indexSynthetic(i,2) = indexSynthetic(i-1,2)*exp(rollinfo.DailyReturn(i-1,2));
end
timeseries_plot(indexSynthetic,'dateformat','mmm-yy','title',[asset,' index']);

[~,V0,~] = infer(rollinfo.VolModel,rollinfo.DailyReturn(:,2));
timeseries_plot([rollinfo.DailyReturn(:,1),V0],'dateformat','mmm-yy',...
    'title',['conditional variance(',asset,')']);

%calculat the period relative change of the index
nPeriod = nForecastPeriod;
    
periodChange = zeros(size(indexSynthetic,1)-nPeriod+1,2);
for i = nPeriod:size(indexSynthetic,1)
    periodChange(i-nPeriod+1,1) = indexSynthetic(i,1);
    periodChange(i-nPeriod+1,2) = indexSynthetic(i,2)/indexSynthetic(i-nPeriod+1,2)-1;
end
timeseries_plot(periodChange,'dateformat','mmm-yy',...
    'title',['relative change over ',num2str(nPeriod),' business days of ',asset]);

%timeseries of historical volatility with simple model
variance = rollinfo.DailyReturn(:,2).^2;
hv = zeros(length(variance)-nPeriod+1,2);
for i = nPeriod:length(variance)
    hv(i-nPeriod+1,1) = rollinfo.DailyReturn(i,1);
    hv(i-nPeriod+1,2) = sum(variance(i-nPeriod+1:i));
    dt = rollinfo.DailyReturn(i,1) - rollinfo.DailyReturn(i-nPeriod+1,1);
    dt = dt/365;
    hv(i-nPeriod+1,2) = sqrt(hv(i-nPeriod+1,2)/dt);
end
timeseries_plot(hv,'dateformat','mmm-yy',...
    'title',[num2str(nPeriod),' business days-realized vol of ',asset]);


%%
% --- define the rateSpec and stockSpec
%user inputs
sigma = fv;
volshift = 0.06;

%
sigma = sqrt((sigma+volshift)^2*businessDaysPerYear/daysPerYear);
rateSpec = intenvset('ValuationDate',settle,'StartDates',settle,...
    'EndDates',expiry,'Rates',rates,...
    'Compounding',-1,'Basis',basis2num('ACT/365'));
fprintf('calendar vol used for pricing:%4.1f%%\n\n',sigma*100);

%%
% strike = mean(indexSynthetic(end-9:end,2));
% spot = indexSynthetic(end,2);
strike = 1;
spot = 1;
optSpec = 'put';
stockSpec = stockspec(sigma,spot,divType,divAmount);
%print european option
fprintf('spot:%4.3f; strike:%4.3f; optiontype:%s; toexpiry:%d days\n',spot,strike,optSpec,...
    nForecastPeriod);

%fundamental black-scholes price
[pxEuropeanBS,deltaEuropeanBS,vegaEuropeanBS] = optstocksensbybls(rateSpec,stockSpec,...
    settle,expiry,optSpec,strike,'outspec',{'Price','Delta','Vega'});
fprintf('european %s valued with BS model:%4.2f%%; delta:%4.2f%%; vega:%4.2f%%\n\n',...
    optSpec,pxEuropeanBS*100,deltaEuropeanBS*100,vegaEuropeanBS);


%%
%MC simulation
numTrials = 20000;
rng(100);
rv = randn(expiry-settle+1,0.5*numTrials);
rv = [rv,-rv];
Z = zeros(size(rv,1),1,size(rv,2));
for i = 1:size(rv,1)
    Z(i,:) = rv(i,:);
end

[~,sims] = optstockbyls(rateSpec,stockSpec,optSpec,strike,settle,expiry,...
    'AmericanOpt',1,...
    'NumTrials',numTrials,...
    'Antithetic',true,...
    'Z',Z);
% fprintf('%s european %s valued with LS model:%4.2f%%\n',tenor,optSpec,pxEuropeanLS*100);
% fprintf('\n');
% %centering of sims to forwards
% adjs = zeros(1,size(sims,1));
% for i = 1:size(sims,1)
%     adjs(i) = mean(sims(i,:))-forwards(i);
%     sims(i,:) = sims(i,:)-adjs(i);
% end
    

%%
% use the path for pricing
% vanilla option
df = rateSpec.Disc;
if strcmpi(optSpec,'put')
    europeanPayoff = max(strike-sims(end,:),0);
else
    europeanPayoff = max(sims(end,:)-strike,0);
end
pxEuropeanMC = df*mean(europeanPayoff);
fprintf('%s european %s valued with MC paths:%4.2f%%\n\n',tenor,optSpec,pxEuropeanMC*100);
%%
%hedging cost
marginRate = 0.1;   %margin requirements of futures used for hedging
riskLevel = 0.7;    %level of fund depositied into the futures margin account
tcRate = 0.001;     %transaction cost ratio
fundingRate = 0.06; %funding annualcontinuous compouding rate

fundingCost = zeros(numTrials,1);
transactionCost = zeros(numTrials,1);
maxMargin = zeros(numTrials,1);
deltaCarry = zeros(size(sims,1)-1,numTrials);

for i = 2:size(sims,1)-1
    tCarry = t(end)-t(i);
    sims_i = sims(i-1,:);
    %compute the carry delta and its funding,transaction requirements
    for j = 1:numTrials
        [cDeltaCarry,pDeltaCarry] = blsdelta(sims_i(j),strike,rates,tCarry,sigma,divAmount);
        if strcmpi(optSpec,'call')
            deltaCarry(i-1,j) = cDeltaCarry;
        else
            deltaCarry(i-1,j) = pDeltaCarry;
        end
        
        marginUsed = abs(deltaCarry(i-1,j)*marginRate/riskLevel);
        
        if i-1 == 1
            maxMargin(j) = marginUsed;
        else
            maxMargin(j) = max(maxMargin(j),marginUsed);
        end
        
        fundingCost(j) = fundingCost(j) + ...
            marginUsed*(exp(fundingRate*(t(i)-t(i-1)))-1);
        if i-1 == 1
            transactionCost(j) = abs(deltaCarry(i-1,j))*tcRate*...
                exp(fundingRate*tCarry);
        else
            transactionCost(j) = transactionCost(j) + ...
                abs(deltaCarry(i-1,j)-deltaCarry(i-2,j))*tcRate*...
                exp(fundingRate*tCarry);
        end
    end
end

%%
alpha = 0.99;
costAvg = mean(transactionCost)+mean(fundingCost);
costQuantile = quantile(transactionCost,alpha)+quantile(fundingCost,alpha);
fprintf('average cost: %4.2f%%; %2.0f%%-quantile cost:%4.2f%%;',...
    costAvg*100,alpha*100,costQuantile*100);

%in case the option premium is not paid upfront
premiumCost = pxEuropeanBS/exp(-fundingRate*rateSpec.EndTimes)-pxEuropeanBS;
fprintf('funding cost of option premium: %4.2f%%\n',premiumCost*100);

%%
%asian
% AvgType = 'arithmetic';
% pxAsianLS= asianbyls(rateSpec,stockSpec,optSpec,strike,settle,expiry,...
%     'Z',Z,...
%     'NumTrials',numTrials,...
%     'Antithetic',true,...
%     'AvgType', AvgType);
% fprintf('%s asian %s valued with LS model:%4.2f%%\n',tenor,optSpec,pxAsianLS*100);

asianRateValue1 = zeros(numTrials,1);
asianRateValue2 = zeros(numTrials,1);
avgStartIdx1 = 1;
if strcmpi(tenor,'6m')
    avgStartDate2 = dateadd(settle,'4m');
else
    avgStartDate2 = dateadd(settle,'2m');
end
avgStartIdx2 = avgStartDate2-settle+1;

for i = 1:numTrials
    asianRateValue1(i) = mean(sims(avgStartIdx1:end,:,i));
    asianRateValue2(i) = mean(sims(avgStartIdx2:end,:,i));
end

if strcmpi(optSpec,'put')
    asianPayoff1 = max(strike-asianRateValue1,0);
    asianPayoff2 = max(strike-asianRateValue2,0);
else
    asianPayoff1 = max(asianRateValue1-strike,0);
    asianPayoff2 = max(asianRateValue2-strike,0);
end
pxAsian1MC = df*mean(asianPayoff1);
pxAsian2MC = df*mean(asianPayoff2);
fprintf('%s asian %s valued with MC path:%4.2f%%\n',tenor,optSpec,pxAsian1MC*100);
fprintf('%s asian %s valued with MC path:%4.2f%%\n\n',tenor,optSpec,pxAsian2MC*100);

%%
%american
pxAmericanLS = optstockbyls(rateSpec,stockSpec,optSpec,strike,settle,expiry,...
    'AmericanOpt',1,...
    'NumTrials',numTrials,...
    'Antithetic',true,...
    'Z',Z);
fprintf('%s american %s valued with LS model:%4.2f%%\n\n',tenor,optSpec,pxAmericanLS*100);

%%
%bermudan
exercisedates = [datenum(dateadd(settle,'4m')),...
    datenum(dateadd(settle,'5m'))....
    datenum(dateadd(settle,'6m'))];

pxBermudanLS= optstockbyls(rateSpec,stockSpec,optSpec,strike,settle,exercisedates,...
    'NumTrials',numTrials,...
    'Z',Z,...
    'AmericanOpt',0);


%%
% call/put spread
optSpec1 = 'put';
strike1 = 1.0;
strike2 = 0.85;
volshift1 = 0.0;
volshift2 = -0.03;

optSpec2 = optSpec1;
stockSpreadSpec1 = stockspec(sigma+volshift1,spot,divType,divAmount);
stockSpreadSpec2 = stockspec(sigma+volshift2,spot,divType,divAmount);

spreadLeg1 = optstockbybls(rateSpec,stockSpreadSpec1,settle,expiry,optSpec1,strike1);
spreadLeg2 = optstockbybls(rateSpec,stockSpreadSpec2,settle,expiry,optSpec2,strike2);
spreadBS = spreadLeg1 - spreadLeg2;
fprintf('%3.0f%%-%3.0f%% %s spread valued with BS model:%4.2f%%; leg1:%4.2f%%; leg2:%4.2f%%\n',...
strike1*100,strike2*100,optSpec2,spreadBS*100,spreadLeg1*100,spreadLeg2*100);


%%
%digital:booked as call spread
binaryStrike = 1.02;
binaryPayoff = 0.02;
digitalVolShift1 = 0.018;
digitalVolShift2 = -0.018;
wedge = 0.03;

digitalStrike1 = binaryStrike-0.5*wedge;
digitalStrike2 = binaryStrike+0.5*wedge;

s = 0.8:0.005:1.2;
payoffs = max(s-digitalStrike1,0)-max(s-digitalStrike2,0);
plot(s,payoffs);

digitalSpreadSpec1 = stockspec(sigma+digitalVolShift1,spot,divType,divAmount);
digitalSpreadSpec2 = stockspec(sigma+digitalVolShift2,spot,divType,divAmount);

digitalSpreadLeg1 = optstockbybls(rateSpec,digitalSpreadSpec1,settle,expiry,'call',digitalStrike1);
digitalSpreadLeg2 = optstockbybls(rateSpec,digitalSpreadSpec2,settle,expiry,'call',digitalStrike2);

digitalBS = (digitalSpreadLeg1 - digitalSpreadLeg2)*binaryPayoff/wedge;
binaryBS = cashbybls(rateSpec,digitalSpreadSpec1,settle,expiry,'call',binaryStrike,binaryPayoff);

fprintf('digital with strike %2.0f%% valued as call spread with BS model:%4.2f%%\n',binaryStrike*100,digitalBS*100);
fprintf('digital with strike %2.0f%% valued as digital with BS model:%4.2f%%\n',binaryStrike*100,binaryBS*100);
fprintf('\n');




