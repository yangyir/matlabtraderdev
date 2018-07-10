function results = timeseries_compress(data,varargin)
% timeseries_compress compress the original data based on the input
% interval in minutes or daily
% the original time series is in 1m interval
% output results column orders: Time,Open,High,Low,Last Price
% Volume of Ticks,Number of Ticks,Total Tick Value (in case)
% todo: compress data originally from tick data


% if isempty(varargin)
%     error('timeseries_compress:at least interval is required!');
% end

if isempty(data)
    results = data;
    return
end

p = inputParser;
p.CaseSensitive = false;
p.KeepUnmatched = true;
p.addRequired('Data',@isnumeric);
% note: all optional parameters for timeseries_window can be called here
p.addParameter('FromDate',NaN,...
       @(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
p.addParameter('ToDate',NaN,...
       @(x) validateattributes(x,{'char','numeric'},{},'','ToDate'));
p.addParameter('TradingHours',{},...
       @(x) validateattributes(x,{'char','cell'},{},'','TradingHours'));
p.addParameter('TradingBreak',{},...
       @(x) validateattributes(x,{'char','cell'},{},'','TradingBreak'));
% note: additional parameter of 'interval'
p.addParameter('Frequency',{},...
       @(x) validateattributes(x,{'char'},{},'','Frequency'));
p.parse(data,varargin{:});
data = p.Results.Data;
dateFrom = p.Results.FromDate;
dateTo = p.Results.ToDate;
tradingHours = p.Results.TradingHours;
tradingBreak = p.Results.TradingBreak;
freq = p.Results.Frequency;

%
data = timeseries_window(data,'FromDate',dateFrom,...
                              'ToDate',dateTo,...
                              'TradingHours',tradingHours,...
                              'TradingBreak',tradingBreak);
%

if isempty(data)
    results = [];
    return
end

[n,m]=size(data);

if isempty(freq) || (~isempty(freq)&&n==1)
    % nothing to do
    if m > 2;
        results = data;
    else
        results = [data,data(:,2),data(:,2),data(:,2)];
    end
    return
end
%

hhmm = sum(hour(data(:,1))) + sum(minute(data(:,1)));
if hhmm == 0
    isdaily = true;
    isbar = false;
    istick = false;
else
    isdaily = false;
    secs = sum(second(data(:,1)));
    if secs ~= 0
        isbar = false;
        istick = true;
    else
        isbar = true;
        istick = false;
    end 
end


interval_num = str2double(freq(1:end-1));
interval_str = freq(end);
% dt = data(2,1)-data(1,1);

if isdaily && strcmpi(interval_str,'d')
    %the data itself is daily data and obviously no compression is required
    if size(data,2) > 2
        results = data;
    else
        results = [data,data(:,2),data(:,2),data(:,2)];
    end
    return
end

if istick && strcmpi(freq,'tick')
    %the data itself is tick data and the compression is in tick level
    %obviously no compression is required
    results = data;
    return
end

if istick && ~strcmpi(freq,'tick')
    %todo:compress from tick data
    error('timeseries_compress:compression from tick data is not support yet!')
end

%not tick data
if isbar && strcmpi(interval_str,'m') && isequal(interval_num,1)
    if m > 2
        results = data;
    else
        results = [data,data(:,2),data(:,2),data(:,2)];
    end
    return
end

if isdaily && (strcmpi(interval_str,'m') || strcmpi(interval_str,'h'))
    %obviously we cannot compress daily data into minute or hour level
    %intraday data
    error('timeseries_compress:cannot compress data with a lower interval');
end
        

% if strcmpi(interval_str,'m')
%     tinterval = dt*1440;
% elseif strcmpi(interval_str,'h')
%     tinterval = dt*24; 
% elseif strcmpi(interval_str,'d')
%     tinterval = dt;
% else
%     error('timeseries_compress:compress interval not supported!');
% end
% 
% FUZZ = 1e-5;
% if tinterval-interval_num > FUZZ
%     %input data's interval is bigger than the compress
%     %requirement and nothing to do or return an error
%     error('timeseries_compress:cannot compress data with a lower interval');
% 
% end
% 
% if abs(tinterval-interval_num)<FUZZ
%     if m > 2
%         results = data;
%     else
%         results = [data,data(:,2),data(:,2),data(:,2)];
%     end
%     return
% end


if strcmpi(interval_str,'m') && ~isequal(interval_num,1)
    days_str = unique(datestr(data(:,1),'dd-mmm-yyyy'),'rows');
    days_num = sort(datenum(days_str,'dd-mmm-yyyy'));
    d_temp = cell(length(days_str),1);
    
    for i = 1:length(days_num)
        buckets = getintradaybuckets('Date',days_num(i),...
                                     'Frequency',freq,...
                                     'TradingHours',tradingHours,...
                                     'TradingBreak',tradingBreak);        
        t_start = datenum([datestr(days_num(i)),' 00:00:00'],...
                            'dd-mmm-yyyy HH:MM:SS');
        t_end = datenum([datestr(days_num(i)),' 23:59:59'],...
                            'dd-mmm-yyyy HH:MM:SS');
        %find the data on the same date first
        idx = data(:,1)>=t_start&data(:,1)<t_end;
        data_i = data(idx,:);
        %now start to compress data
        if ~isempty(data_i)
            if size(data,2) == 8
                temp = NaN(size(data_i,1),8);
            else
                temp = NaN(size(data_i,1),5);
            end
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
                    if size(temp,2) == 8
                        % in case bar interval data is given, compress with
                        % the bar interval data itself
                        d_open = d(1,2);        %the 2nd column is the open price
                        d_high = max(d(:,3));   %the 3rd column is the high price
                        d_low = min(d(:,4));    %the 4th column is the low price
                        d_last = d(end,5);      %the 5th column is the last price
                        t = t_start;
                        vt = sum(d(:,6));       %the 6th column is the volume of ticks
                        nt = sum(d(:,7));       %the 7th column is the number of ticks
                        tv = sum(d(:,8));       %the 8th column is the total tick value
                        %time,open,high,low,last price
                        temp(j,:) = [t,d_open,d_high,d_low,d_last,vt,nt,tv];
                    elseif size(temp,2) == 5
<<<<<<< HEAD
                        % in case bar interval data is given, compress with
                        % the bar interval data itself
=======
>>>>>>> 4450f55e0a1ffb32351b74f2fb6b99e2b1737ae5
                        d_open = d(1,2);        %the 2nd column is the open price
                        d_high = max(d(:,3));   %the 3rd column is the high price
                        d_low = min(d(:,4));    %the 4th column is the low price
                        d_last = d(end,5);      %the 5th column is the last price
                        t = t_start;
                        temp(j,:) = [t,d_open,d_high,d_low,d_last];
                    else
                        % only last price (or tick price) is given
                        % create the bar interval data
                        d_open = d(1,2);
                        d_high = max(d(:,2));
                        d_low = min(d(:,2));
                        d_last = d(end,2);
                        t = t_start;
                        %time,open,high,low,last price
                        temp(j,:) = [t,d_open,d_high,d_low,d_last];
                    end
                end 
            end
            idx = ~isnan(temp(:,1)) & temp(:,1)~=0;
            d_temp{i} = temp(idx,:);
        end
    end
    results = cell2mat(d_temp);
    %
elseif strcmpi(freq,'1d')
    days_str = unique(datestr(data(:,1),'dd-mmm-yyyy'),'rows');
    days_num = sort(datenum(days_str,'dd-mmm-yyyy'));
    if size(data,2) == 8
        results = zeros(size(days_str,1),8);
    else
        results = zeros(size(days_str,1),5);
    end
    %
    if isempty(tradingHours)
%         mktopen_str = ' 09:00:00';
        mktclose_str = ' 15:15:00';
    else
        temp = regexp(tradingHours,';','split');
%         mktopen_str = [' ',temp{1}(1:5),':00'];
        mktclose_str = [' ',temp{2}(end-4:end),':00'];
    end
    
    for i = 1:length(days_num)
        %shall be the within the same trading date
        %by default,the market reblance after market close in the afternoon
        if i == 1
            t_start = datenum([datestr(businessdate(days_num(i),-1)),mktclose_str],...
                'dd-mmm-yyyy HH:MM:SS');
            t_end = datenum([datestr(days_num(i)),mktclose_str],...
                'dd-mmm-yyyy HH:MM:SS');
        else
            t_start = datenum([datestr(days_num(i-1)),mktclose_str],...
                'dd-mmm-yyyy HH:MM:SS');
            t_end = datenum([datestr(days_num(i)),mktclose_str],...
                'dd-mmm-yyyy HH:MM:SS');
        end
        %find the data on the same date first
        idx = data(:,1)>=t_start&data(:,1)<t_end;
        data_i = data(idx,:);
        if size(data_i,2) == 8
            d_open = data_i(1,2);        %the 2nd column is the open price
            d_high = max(data_i(:,3));   %the 3rd column is the high price
            d_low = min(data_i(:,4));    %the 4th column is the low price
            d_last = data_i(end,5);      %the 5th column is the last price
            t = days_num(i);
            vt = sum(data_i(:,6));       %the 6th column is the volume of ticks
            nt = sum(data_i(:,7));       %the 7th column is the number of ticks
            tv = sum(data_i(:,8));       %the 8th column is the total tick value
            %time,open,high,low,last price
            results(i,:) = [t,d_open,d_high,d_low,d_last,vt,nt,tv];
        else
            d_open = data_i(1,2);
            d_high = max(data_i(:,2));
            d_low = min(data_i(:,2));
            d_last = data_i(end,2);
            t = days_num(i);
            %time,open,high,low,last price
            results(i,:) = [t,d_open,d_high,d_low,d_last];
        end
    end
elseif strcmpi(freq,'1w')
    w = year(data(:,1))*100+weeknum(data(:,1));
    w_unique = sort(unique(w));
    if size(data,2) > 2
        results = zeros(size(w_unique,1),6);
    else
        results = zeros(size(w_unique,1),5);
    end
    for i = 1:size(w_unique,1)
        w_i = w_unique(i);
        idx = w == w_i;
        data_i = data(idx,:);
        if size(data_i,2) > 2
            d_open = data_i(1,2);
            d_high = max(data_i(:,3));
            d_low = min(data_i(:,4));
            d_last = data_i(end,5);
            t = w_unique(i);
            vt = sum(data_i(:,6));
            results(i,:) = [t,d_open,d_high,d_low,d_last,vt];
        else
            d_open = data_i(1,2);
            d_high = max(data_i(:,2));
            d_low = min(data_i(:,2));
            d_last = data_i(end,2);
            t = w_unique(i);
            results(i,:) = [t,d_open,d_high,d_low,d_last];
        end
    end
else
    error('invalid interval input');
end

end