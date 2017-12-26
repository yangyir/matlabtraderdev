%%
conn = bbgconnect;
%%
% --- user inputs
sugar = 'sugar';
tenor = '1m';
settle = today;
expiry = dateadd(today,tenor);
busDates = gendates('FromDate',settle,'ToDate',expiry);
nFo1recastPeriod = length(busDates);

%%
%forecast volatility
fprintf('rolling discrete futures and estimate/forecast volatility with GARCH model...\n');
rollinfo = rollfutures(sugar,'CalcDailyReturn',true,...
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
fprintf('\tlg term annual-vol of %s: %4.1f%%\n',sugar,lv*100);
fprintf('\tfcat forecast period annual-vol of %s: %4.1f%%\n',sugar,fv*100);

hv = rollinfo.ForecastResults.HistoricalAnnualVol;
fprintf('\thist forecast period annual-vol of %s: %4.1f%%\n',...
    sugar,hv*100);
ewmav = rollinfo.ForecastResults.EWMAAnnualVol;
fprintf('\tewma forecast period annual-vol of %s: %4.1f%%\n',...
    sugar,ewmav*100);
fprintf('\n');

%%

