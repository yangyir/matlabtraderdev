%%
% --- user inputs
asset = 'govtbond_10y';
businessDaysPerYear = 252;
daysPerYear = 365;

%%
% --- option user inputs
strike = 1;
spot = 1;
rates = 0.035;
settle = today;
optSpec = 'put';
divType = {'continuous'};
tenor = '1m';

%futures/forward assuming paying the fixed dividend as of the rates
%yield curve
divAmount = rates;

expiry = dateadd(today,tenor);
t = settle:1:expiry;
t = t - settle;
t = t/daysPerYear;
forwards = spot*exp((rates-divAmount)*t);

%%
%forecast volatility
exerciseDates = gendates('FromDate',settle,'ToDate',expiry);
nForecastPeriod = length(exerciseDates);
rollinfo = rollfutures(asset,'CalcDailyReturn',true,...
    'CalibrateVolModel',true,...
    'PrintResults',false,...
    'PlotConditonalVariance',false,...
    'ForecastPeriod',nForecastPeriod);
lv = rollinfo.ForecastResults.LongTermAnnualVol;
fv = sum(rollinfo.ForecastResults.ConditionalVariance)/nForecastPeriod*businessDaysPerYear;
fv = sqrt(fv);
fprintf('lg term annual-vol of %s: %4.1f%%\n',asset,lv*100);
fprintf('fcat %s annual-vol of %s: %4.1f%%\n',tenor,asset,fv*100);
if strcmpi(tenor,'6m')
    rets = rollinfo.DailyReturn(end-126+1:end,2);
elseif strcmpi(tenor,'3m')
    rets = rollinfo.DailyReturn(end-63+1:end,2);
elseif strcmpi(tenor,'1m')
    rets = rollinfo.DailyReturn(end-21+1:end,2);
else
    error('tenor not implemented')
end
hv = std(rets)*sqrt(businessDaysPerYear);
fprintf('hist %s annual-vol of %s: %4.1f%%\n',...
    tenor,asset,hv*100);
ewmav = abs(rets(1));
lambda = rollinfo.VolModel.Variance.GARCH{1};
for i = 2:length(rets)
    ewmav = lambda*ewmav^2+(1-lambda)*rets(i)^2;
    ewmav = sqrt(ewmav);
end
ewmav = ewmav*sqrt(businessDaysPerYear);
fprintf('ewma %s annual-vol of %s: %4.1f%%\n',...
    tenor,asset,ewmav*100);
fprintf('\n');

%%
%timeseries plotting
close all;
indexSynthetic = rollinfo.ContinousFutures;
indexSynthetic(1,2) = 1.0;
for i = 2:size(indexSynthetic,1)
    indexSynthetic(i,2) = indexSynthetic(i-1,2)*exp(rollinfo.DailyReturn(i-1,2));
end
timeseries_plot(indexSynthetic,'dateformat','mmm-yy','title',asset);
[~,V0,~] = infer(rollinfo.VolModel,rollinfo.DailyReturn(:,2));
timeseries_plot([rollinfo.DailyReturn(:,1),V0],'dateformat','mmm-yy',...
    'title',['conditional variance(',asset,')']);

%%
% --- define the rateSpec and stockSpec
%user inputs
sigma = fv;
volshift = 0.0;

%
sigma = sqrt(sigma^2*businessDaysPerYear/daysPerYear);
rateSpec = intenvset('ValuationDate',settle,'StartDates',settle,...
    'EndDates',expiry,'Rates',rates,...
    'Compounding',-1,'Basis',basis2num('ACT/365'));
stockSpec = stockspec(sigma+volshift,spot,divType,divAmount);
fprintf('calendar vol used for pricing:%4.1f%%\n\n',(sigma+volshift)*100);

%%
%fundamental black-scholes price
[pxEuropeanBS,vegaEuropeanBS] = optstocksensbybls(rateSpec,stockSpec,...
    settle,expiry,optSpec,strike,'outspec',{'Price','Vega'});
fprintf('%s european %s valued with BS model:%4.2f%%; vega:%4.2f%%\n\n',...
    tenor,optSpec,pxEuropeanBS*100,vegaEuropeanBS);


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
    europeanPayoff = max(sims(end)-strike,0);
end
pxEuropeanMC = df*mean(europeanPayoff);
fprintf('%s european %s valued with MC paths:%4.2f%%\n\n',tenor,optSpec,pxEuropeanMC*100);
%%
%hedging cost
marginRate = 0.1;   %margin requirements of futures used for hedging
riskLevel = 0.7;    %level of fund depositied into the futures margin account
tcRate = 0.001;     %transaction cost ratio

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
            marginUsed*(exp(rates*(t(i)-t(i-1)))-1);
        if i-1 == 1
            transactionCost(j) = abs(deltaCarry(i-1,j))*tcRate;
        else
            transactionCost(j) = transactionCost(j) + ...
                abs(deltaCarry(i-1,j)-deltaCarry(i-2,j))*tcRate;
        end
    end
end

costAvg = mean(transactionCost)+mean(fundingCost);
costQuantile = quantile(transactionCost,0.95)+quantile(fundingCost,0.95);
fprintf('average cost: %4.2f%%; 95%%-quantile cost:%4.2f%%\n\n',costAvg*100,costQuantile*100);


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
    avgStartDate2 = dateadd(settle,'3m');
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
strike2 = 0.9;
volshift1 = 0.05;
volshift2 = -0.0;

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




