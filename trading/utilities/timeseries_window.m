function results = timeseries_window(data,varargin)
% this function, as its name implies, does timeseries window screening
%
% syntax: 
% results = timeseries_window(data,'FromDate',date)
% results = timeseries_window(data,'ToDate',date)
% results = timeseries_window(data,'FromDate',date1,'ToDate',date2)
% results = timeseries_window(data,'FromDate',date1,'ToDate',date2,...
%                                  'TradingHours',th,...
%                                  'TradingBreak',tb)
if isempty(data)
    results = data;
    return
end

p = inputParser;
p.CaseSensitive = false;
p.KeepUnmatched = true;
p.addRequired('Data',@isnumeric);
p.addParameter('FromDate',{},...
        @(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
p.addParameter('ToDate',{},...
        @(x) validateattributes(x,{'char','numeric'},{},'','ToDate'));
p.addParameter('TradingHours',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','TradingHours'));
p.addParameter('TradingBreak',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','TradingBreak'));    
p.parse(data,varargin{:});
%
data = p.Results.Data;
if isempty(p.Results.FromDate)
    datenumFrom = NaN;
else
    datenumFrom = datenum(p.Results.FromDate);
end
if isempty(p.Results.ToDate)
    datenumTo = NaN;
else
    datenumTo = datenum(p.Results.ToDate);
end

tradingHours = p.Results.TradingHours;
tradingBreak = p.Results.TradingBreak;
% sanity check
if isempty(tradingHours) && ~isempty(tradingBreak)
    error('timeseries_window:missing trading hours once trading break is given');
end
%

if isnan(datenumFrom) && isnan(datenumTo)
   results = data;
else
    if isnan(datenumFrom)
        %default the start time of the time series as the first date
        %entry of the time series
        datenumFrom = data(1,1);
    end
    if isnan(datenumTo)
        %default the end time of the time series as the last date entry
        %
        datenumTo = data(end,1);
    end
    % cut off at the earliest date
    datenumFrom = min(max(data(1,1),datenumFrom),data(end,1));
    datenumTo = max(min(data(end,1),datenumTo),data(1,1));

    if isequal(datenumFrom,datenumTo)
        dStr = datestr(datenumFrom,'dd-mmm-yyyy');
        datenumFrom = datenum([dStr,' 00:00:00'],...
            'dd-mmm-yyyy HH:MM:SS');
        datenumTo = datenum([dStr,' 23:59:59'],...
            'dd-mmm-yyyy HH:MM:SS');
    end
    t = data(:,1);
    if hour(datenumTo) == 0
        idx = t>=datenumFrom & t<datenumTo+1;
    else
        idx = t>=datenumFrom & t<=datenumTo;
    end
    results = data(idx,:);
end

intradayFlag = sum(hour(results(:,1))+minute(results(:,1))) > 0;
if ~isempty(tradingHours) && intradayFlag
    idx = istrading(results(:,1),tradingHours,'TradingBreak',tradingBreak);
    results = results(idx,:);
end

end