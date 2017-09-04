
%%
businessDaysPerYear = 252;
daysPerYear = 365;

% --- user inputs
% clear;
asset = 'govtbond_10y';
% tenor = '3m';
settle = today;
% expiry = dateadd(today,tenor);
expiry = datenum('30-Jun-2017');

%%
%forecast volatility
fprintf('rolling discrete futures and estimate/forecast volatility with GARCH model...\n');
exerciseDates = gendates('FromDate',settle,'ToDate',expiry);
nForecastPeriod = length(exerciseDates);
rollinfo = rollfutures(asset,'CalcDailyReturn',true,...
    'CalibrateVolModel',true,...
    'PrintResults',false,...
    'PlotConditonalVariance',true,...
    'ForecastPeriod',nForecastPeriod,...
    'UpdateTimeSeries',true);

fprintf('\tlast observation date is %s\n',datestr(rollinfo.ContinousFutures(end,1)));

lv = rollinfo.ForecastResults.LongTermAnnualVol;
fv = rollinfo.ForecastResults.ForecastedAnnualVol;
fprintf('forecast period length:%d business days\n',nForecastPeriod);
fprintf('\tlg term annual-vol of %s: %4.1f%%\n',asset,lv*100);
fprintf('\tfcat forecast period annual-vol of %s: %4.1f%%\n',asset,fv*100);

hv = rollinfo.ForecastResults.HistoricalAnnualVol;
fprintf('\thist forecast period annual-vol of %s: %4.1f%%\n',...
    asset,hv*100);
ewmav = rollinfo.ForecastResults.EWMAAnualVol;
fprintf('\tewma forecast period annual-vol of %s: %4.1f%%\n',...
    asset,ewmav*100);
fprintf('\n');


%%
%timeseries plotting
dStart = rollinfo.ContinousFutures(1,1);
dEnd = rollinfo.ContinousFutures(end,1);
% --- interest rates
ratesSec = 'CCSWOC CMPN Curncy';    %CNY IRS(7D repo) 3MO
%note:DayCount = ACT/365 and PayFrequency = 'Quarterly'
rates = history(conn,ratesSec,'px_last',dStart,dEnd);
close all;
timeseries_plot(rates,'dateformat','mmm-yy','title','CNY IRS(7D repo)3MO');

rates = rates(end,2)/100;
fprintf('\tinterest rate: %4.2f%%\n',rates*100);



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
% if strcmpi(tenor,'3m')
%     nPeriod = 63;
% elseif strcmpi(tenor,'6m')
%     nPeriod = 126;
% elseif strcmpi(tenor,'1m')
%     nPeriod = 21;
% elseif strcmpi(tenor,'1y')
%     nPeriod = 252;
% end
    
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

divType = {'continuous'};
divAmount = rates;

sigma = fv;
volshift = 0.01;

%
sigma = sqrt((sigma+volshift)^2*businessDaysPerYear/daysPerYear);
rateSpec = intenvset('ValuationDate',settle,'StartDates',settle,...
    'EndDates',expiry,'Rates',rates,...
    'Compounding',-1,'Basis',basis2num('ACT/365'));
fprintf('calendar vol used for pricing:%4.1f%%\n\n',sigma*100);

%%
strike = mean(indexSynthetic(end-9:end,2));
spot = indexSynthetic(end,2);
optSpec = 'call';
stockSpec = stockspec(sigma,spot,divType,divAmount);
%print european option
fprintf('spot:%4.3f; strike:%4.3f; optiontype:%s; toexpiry:%ddays\n',spot,strike,optSpec,...
    nPeriod);


%fundamental black-scholes price
[pxEuropeanBS,deltaEuropeanBS,vegaEuropeanBS] = optstocksensbybls(rateSpec,stockSpec,...
    settle,expiry,optSpec,strike,'outspec',{'Price','Delta','Vega'});
fprintf('european %s valued with BS model:%4.2f%%; delta:%4.2f%%; vega:%4.2f%%\n\n',...
    optSpec,pxEuropeanBS*100,deltaEuropeanBS*100,vegaEuropeanBS);


%%
% call/put spread
optSpec1 = 'call';
strike1 = 1.0;
strike2 = 1.02;
volshift1 = 0.01;
volshift2 = -0.01;

optSpec2 = optSpec1;
stockSpreadSpec1 = stockspec(sigma+volshift1,spot,divType,divAmount);
stockSpreadSpec2 = stockspec(sigma+volshift2,spot,divType,divAmount);

spreadLeg1 = optstockbybls(rateSpec,stockSpreadSpec1,settle,expiry,optSpec1,strike1);
spreadLeg2 = optstockbybls(rateSpec,stockSpreadSpec2,settle,expiry,optSpec2,strike2);
spreadBS = spreadLeg1 - spreadLeg2;
fprintf('%3.0f%%-%3.0f%% %s spread valued with BS model:%4.1f%%; leg1:%4.1f%%; leg2:%4.1f%%\n',...
strike1*100,strike2*100,optSpec2,spreadBS*100,spreadLeg1*100,spreadLeg2*100);


