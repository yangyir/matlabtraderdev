function results = timeseries_channel(data,varargin)
% compute the channel width given the time-series data ts
%
if size(data,2) > 2
    col_end = 5;
else
    col_end = 2;
end
data = data(:,1:col_end);

if isempty(varargin)
    [crange,cmax,cmin,cgradient] = get_detrended_channel(data);
    results = [data(1,1),crange,cmax,cmin,cgradient];
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
%
parser.parse(varargin{:});
date_from = parser.Results.FromDate;
date_to = parser.Results.ToDate;
trading_hours = parser.Results.TradingHours;
trading_break = parser.Results.TradingBreak;
% first screening data
data = timeseries_window(data,'FromDate',date_from,...
                              'ToDate',date_to,...
                              'TradingHours',trading_hours,...
                              'TradingBreak',trading_break);
interval = parser.Results.Interval;
if isempty(interval)
    [crange,cmax,cmin,cgradient] = get_detrended_channel(data);
    results = [data(1,1),crange,cmax,cmin,cgradient];
    return
end
%
interval_num = str2double(interval(1:end-1));
interval_str = interval(end);
%
if strcmpi(interval_str,'m') && isequal(interval_num,1)
    error('timeseries_channel:cannot compute channel width with the same or lower interval');
    %TODO:from tick data
    %
elseif strcmpi(interval_str,'m') && ~isequal(interval_num,1)
    intraday_flag = sum(hour(data(:,1))+minute(data(:,1))) > 0;
    if ~intraday_flag
        error('timeseries_channel:cannot compute channel width with a lower interval');
    end
    days_str = unique(datestr(data(:,1),'dd-mmm-yyyy'),'rows');
    days_num = sort(datenum(days_str,'dd-mmm-yyyy'));
    d_temp = cell(length(days_str),1);
    %
    for i = 1:length(days_num)
        buckets = get_intraday_buckets('Date',days_num(i),...
                                        'Interval',interval,...
                                        'TradingHours',trading_hours,...
                                        'TradingBreak',trading_break);        
        t_start = datenum([datestr(days_num(i)),' 00:00:00'],...
                            'dd-mmm-yyyy HH:MM:SS');
        t_end = datenum([datestr(days_num(i)),' 23:59:59'],...
                            'dd-mmm-yyyy HH:MM:SS');
        %find the data on the same date first
        idx = data(:,1)>=t_start&data(:,1)<t_end;
        data_i = data(idx,:);
        %now start to compute the channel width
        temp = NaN(size(data_i,1),5);
        for j = 1:length(buckets)
            t_start = buckets(j);
            if j < length(buckets)
                t_end = buckets(j+1);
            else
                t_end = data_i(end,1);
            end
            idx = data_i(:,1)>=t_start&data_i(:,1)<t_end;
            d = data_i(idx,:);
            if ~isempty(d)
                [crange,cmax,cmin,cgradient] = get_detrended_channel(d);
                temp(j,:) = [t_start,crange,cmax,cmin,cgradient];
            end 
        end
        idx = ~isnan(temp(:,1)) & temp(:,1)~=0;
        d_temp{i} = temp(idx,:);
    end
    results = cell2mat(d_temp);
    %
elseif strcmpi(interval,'1d')
    intraday_flag = sum(hour(data(:,1))+minute(data(:,1))) > 0;
    if ~intraday_flag
         error('timeseries_channel:cannot compute channel width with the same or lower interval');
    else
        days_str = unique(datestr(data(:,1),'dd-mmm-yyyy'),'rows');
        days_num = sort(datenum(days_str,'dd-mmm-yyyy'));
        results = zeros(size(days_str,1),5);
        %
        for i = 1:length(days_num)
            t_start = datenum([datestr(days_num(i)),' 00:00:00'],...
                            'dd-mmm-yyyy HH:MM:SS');
            t_end = datenum([datestr(days_num(i)),' 23:59:59'],...
                            'dd-mmm-yyyy HH:MM:SS');
            %find the data on the same date first
            idx = data(:,1)>=t_start&data(:,1)<=t_end;
            data_i = data(idx,:);
            [crange,cmax,cmin,cgradient] = get_detrended_channel(data_i);
            results(i,:) = [days_num(i),crange,cmax,cmin,cgradient];
        end
    end
elseif strcmpi(interval,'1w')
    w = year(data(:,1))*100+weeknum(data(:,1));
    w_unique = sort(unique(w));
    results = zeros(size(w_unique,1),5);
    for i = 1:size(w_unique,1)
        w_i = w_unique(i);
        idx = w == w_i;
        data_i = data(idx,:);
        [crange,cmax,cmin,cgradient] = get_detrended_channel(data_i);
        results(i,:) = [w_i,crange,cmax,cmin,cgradient];
    end
else
    error('invalid interval input');
end
%
    
    
    
end




