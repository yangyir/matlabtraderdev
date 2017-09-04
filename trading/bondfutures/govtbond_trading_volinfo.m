function output = govtbond_trading_volinfo(rollinfo5y,rollinfo10y,yldSpreads,varargin)
if isempty(varargin)
    doPrint = true;
else
    doPrint = varargin{1};
end

lastbd = rollinfo5y.ContinousFutures(end,1);
lv5y = rollinfo5y.ForecastResults.LongTermAnnualVol;
hv5y = rollinfo5y.ForecastResults.HistoricalAnnualVol;
ewmav5y = rollinfo5y.ForecastResults.EWMAAnnualVol;
fv5y = rollinfo5y.ForecastResults.ForecastedAnnualVol;
V5y = rollinfo5y.ForecastResults.ForecastedVariance;
Y5y = rollinfo5y.ForecastResults.ForecastedReturn;
YMSE5y = rollinfo5y.ForecastResults.ForecastedReturnError;
%
%
lv10y = rollinfo10y.ForecastResults.LongTermAnnualVol;
hv10y = rollinfo10y.ForecastResults.HistoricalAnnualVol;
ewmav10y = rollinfo10y.ForecastResults.EWMAAnnualVol;
fv10y = rollinfo10y.ForecastResults.ForecastedAnnualVol;
V10y = rollinfo10y.ForecastResults.ForecastedVariance;
Y10y = rollinfo10y.ForecastResults.ForecastedReturn;
YMSE10y = rollinfo10y.ForecastResults.ForecastedReturnError;
%
%
hvSpread = yldSpreads.HistoricalAnnualVol;
ewmavSpread = yldSpreads.EWMAAnnualVol;
fvSpread = yldSpreads.ForecastedAnnualVol;
VSpread = yldSpreads.ForecastedSpreadVariance;
YSpread = yldSpreads.ForecastedSpreadChange;
YMSESpread = yldSpreads.ForecastedSpreadChangeError;
%
%
if doPrint
    fprintf('\n');
    fprintf('CN govtbond %2dy futs-->>lv:%3.1f%%;hv:%3.1f%%;ewmav:%3.1f%%;fv:%3.1f%%\n',...
        5,lv5y*100,hv5y*100,ewmav5y*100,fv5y*100);
    fprintf('CN govtbond %2dy futs-->>lv:%3.1f%%;hv:%3.1f%%;ewmav:%3.1f%%;fv:%3.1f%%\n',...
        10,lv10y*100,hv10y*100,ewmav10y*100,fv10y*100);
    fprintf('CN govtbond 5-10y spds-->>hv:%2.1f;ewmav:%2.1f;fv:%2.1f\n',...
        hvSpread,ewmavSpread,fvSpread);
end

%
%construct output
output = struct('LastBusinessDate',lastbd,...
    'LongTermAnnualVol',[lv5y,lv10y,[]],...
    'HistoricalAnnualVol',[hv5y,hv10y,hvSpread],...
    'EWMAAnualVol',[ewmav5y,ewmav10y,ewmavSpread],...
    'ForecastedAnnualVol',[fv5y,fv10y,fvSpread],...
    'ForecastedSpreadVariance',[V5y,V10y,VSpread],...
    'ForecastedSpreadChange',[Y5y,Y10y,YSpread],...
    'ForecastedSpreadChangeError',[YMSE5y,YMSE10y,YMSESpread]);

end

