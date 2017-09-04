function results = timeseries_vwap2(data,varargin)
% this function, as its name implies, compute the vwap price for the
% given data
% data columns: Time,Open,High,Low,Close,Volumn...
% 
intraday_flag = sum(hour(data(:,1))+minute(data(:,1))) > 0;
if ~intraday_flag
    error('timeseries_vwap used only with intraday data');
end
%
if isempty(varargin)
    % vwap calculation day-by-day
    days_str = unique(datestr(data(:,1),'dd-mmm-yyyy'),'rows');
    days_num = sort(datenum(days_str,'dd-mmm-yyyy'));
    d_temp = cell(length(days_num),1);
    for i = 1:length(days_num)
        t_start = datenum([datestr(days_num(i)),' 00:00:00'],...
                                'dd-mmm-yyyy HH:MM:SS');
        t_end = datenum([datestr(days_num(i)),' 23:59:59'],...
                                'dd-mmm-yyyy HH:MM:SS');
        idx = data(:,1)>=t_start&data(:,1)<t_end;
        d = data(idx,:);                    
        
        px = d(:,5);
        volume = d(:,6);
        value = px.*volume;
        temp = zeros(length(px),2);
        temp(:,1) = d(:,1);
        for j = 1:length(px)
            temp(j,2) = sum(value(1:j))/sum(volume(1:j));
        end
        d_temp{i} = temp;
    end
    results = cell2mat(d_temp);
    return
end
%
parser = inputParser;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.addParamValue('FromDate',NaN,...
        @(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
parser.addParamValue('ToDate',NaN,...
        @(x) validateattributes(x,{'char','numeric'},{},'','ToDate'));
parser.addParamValue('TradingHours',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','TradingHours'));
parser.addParamValue('TradingBreak',{},...
        @(x) validateattributes(x,{'cell','char'},{},'','TradingBreak'));
parser.addParamValue('Interval',{},...
        @(x) validateattributes(x,{'cell','char'},{},'','Interval'));    
parser.parse(varargin{:});
%
date_from = parser.Results.FromDate;
date_to = parser.Results.ToDate;
trading_hours = parser.Results.TradingHours;
trading_break = parser.Results.TradingBreak;
%
data = timeseries_window(data,'FromDate',date_from,...
                              'ToDate',date_to,...
                              'TradingHours',trading_hours,...
                              'TradingBreak',trading_break);
%

days_str = unique(datestr(data(:,1),'dd-mmm-yyyy'),'rows');
days_num = sort(datenum(days_str,'dd-mmm-yyyy'));
d_temp = cell(length(days_num),1);
for i = 1:length(days_num)
    t_start = datenum([datestr(days_num(i)),' 00:00:00'],...
        'dd-mmm-yyyy HH:MM:SS');
    t_end = datenum([datestr(days_num(i)),' 23:59:59'],...
        'dd-mmm-yyyy HH:MM:SS');
    idx = data(:,1)>=t_start&data(:,1)<t_end;
    d = data(idx,:);
    
    px = d(:,5);
    volume = d(:,6);
    value = px.*volume;
    temp = zeros(length(px),2);
    temp(:,1) = d(:,1);
    for j = 1:length(px)
        temp(j,2) = sum(value(1:j))/sum(volume(1:j));
    end
    d_temp{i} = temp;
end
vwap = cell2mat(d_temp);
%
interval = parser.Results.Interval;
if isempty(interval)
    results = vwap;
    return
end

interval_num = str2double(interval(1:end-1));
interval_str = interval(end);
%
if strcmpi(interval_str,'m') && isequal(interval_num,1)
    results = vwap;
else
    temp = timeseries_compress(vwap,'Interval',interval);
    results = [temp(:,1),temp(:,5)];
end
                              
end
