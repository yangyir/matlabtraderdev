function [rollinfo5y,rollinfo10y,yldSpreadsEOD,yldSpreadsIntraday] = govtbond_trading_init(varargin)
fprintf('\n');
fprintf('running govtbond_trading_init......\n');
if isempty(varargin)
    nPeriod = 21;
else
    nPeriod = varargin{1};
end

bndfut5y = 'govtbond_5y';
bndfut10y = 'govtbond_10y';

%roll futures information
%make sure this part of script has been run before the market open at 9:15
%on each business date
fprintf('\trolling futures for 05y govtbond......\n');
rollinfo5y = rollfutures(bndfut5y,'ForecastPeriod',nPeriod);
%
fprintf('\trolling futures for 10y govtbond......\n');
rollinfo10y = rollfutures(bndfut10y,'ForecastPeriod',nPeriod);
%
%implied yield spreads
fprintf('\tcalculate daily yields and yield spreads......\n');
yldSpreadsEOD = govtbond_trading_histyieldspread(rollinfo10y);
%
%
fprintf('\tcalculate intraday yields and yield spreads......\n');
yldSpreadsIntraday = govtbond_trading_highfreq(rollinfo10y);
%
fprintf('\tthe last observation date is:%s\n', datestr(rollinfo5y.ContinousFutures(end,1)));
fprintf('init done!\n')

end

