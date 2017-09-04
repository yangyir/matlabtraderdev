classdef cTimeSeries
    %class of timeseries
    
    properties (Access = private)
        %full range of time and Value associated with the time
        %are stored.However,direct access to the full range of time and 
        %Value is prohited
        %call 'getTimeSeries' function to retrieve data as required
        Time
        Value
    end
    %
    
    properties (GetAccess = public, SetAccess = private)
        Label           %label of data description
        Frequency        %time series interval,e.g.tick,1m or 1d
        Codes           %store the bloomberg code and wind code
    end
    %
    
    methods   %GET method
        %
        function Label = get.Label(obj)
            Label = obj.Label;
        end
        %
        
        %
        function interval = get.Frequency(obj)
            interval = obj.Frequency;
        end
        %
        
        %
        function codes = get.Codes(obj)
            codes = obj.Codes;
        end
        %
        
        %
        function t = getFirstDateEntry(obj)
            if isempty(obj.Time)
                t = [];
            else
                t = datestr(obj.Time(1));
            end
        end
        %
        
        %
        function t = getLastDateEntry(obj)
            if isempty(obj.Time)
                t = [];
            else
                t = datestr(obj.Time(end));
            end
        end
        %
        
        %
        function days = getDates(obj)
            if isempty(obj.Time)
                days = [];
            else
                days = sort(unique(floor(obj.Time)));
            end
        end
        %
    end
    %methods end
    
    methods (Access = public)
        % constructor
        function obj = cTimeSeries(varargin)
            if nargin == 0
                obj.Time = [];
                obj.Value = [];
                obj.Label = {};
                obj.Frequency = {};
            elseif nargin == 2 && strcmpi(varargin{1},'FileName')
                obj = genTimeSeriesFromFile(obj,varargin{:});
            elseif nargin == 6
                obj = init(obj,varargin{:});
            elseif nargin > 6
                for i = 1:length(varargin)
                   if strcmpi(varargin{i},'Connection') && ...
                           isa(varargin{i+1},'blp') 
                       %bloomberg
                       obj = genTimeSeriesFromBloomberg(obj,varargin{:});
                       break;
                   else
                       %wind
                       obj = genTimeSeriesFromWind(obj,varargin{:});
                       break;
                   end
                end
            end   
        end
        %
        
        % get self-defined time series
        function ts = getTimeSeries(obj,varargin)
            if isempty(varargin)
                time = obj.Time;
                val = obj.Value;
                ts = [datenum(time),val];
            else
                p = inputParser;
                p.CaseSensitive = false;
                p.KeepUnmatched = true;
                p.addParameter('Fields',{},...
                    @(x) validateattributes(x,{'char','cell'},{},'','Fields'));
                p.addParameter('FromDate',[],...
                    @(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
                p.addParameter('ToDate',[],...
                    @(x) validateattributes(x,{'char','numeric'},{},'','ToDate'));
                p.addParameter('Frequency',[],...
                    @(x) validateattributes(x,{'char','numeric'},{},'','Frequency'));
                p.addParameter('TradingHours',{},...
                    @(x) validateattributes(x,{'char','cell'},{},'','TradingHours'));
                p.addParameter('TradingBreak',{},...
                    @(x) validateattributes(x,{'char','cell'},{},'','TradingBreak'));
                p.parse(varargin{:});
                fields = p.Results.Fields;
                if ~isempty(fields)
                    %sanity check of input fields that the inputs shall be
                    %limited to open,high,low,close,volume,oi,trade,bid and
                    %ask
                    if ischar(fields)
                        fieldsCheck = regexp(fields,',','split');
                    else
                        fieldsCheck = fields;
                    end
                    for k = 1:length(fieldsCheck)
                        if all(~strcmpi(fieldsCheck{k},...
                                {'open','high','low','close','volume','oi',...
                                'trade','bid','ask'}))
                                error('cTimeSeries:getTimeSeries:invalid field input')
                        end
                    end
                end
                
                dateFrom = p.Results.FromDate;
                dateTo = p.Results.ToDate;
                interval = p.Results.Frequency;
                tradingHours = p.Results.TradingHours;
                tradingBreak = p.Results.TradingBreak;
                %
                ts = [datenum(obj.Time),obj.Value];
                if ~isempty(fields)
                    n = size(obj.Value,1);
                    if ischar(fields)
                        fieldsCell = regexp(fields,',','split');
                        m = length(fieldsCell);
                    else
                        m = length(fields);
                    end
                    ts = zeros(n,m+1);
                    labels = obj.Label;
                    if ischar(labels)
                        ncol = 1;
                    else
                        ncol = length(labels);
                    end
                    %
                    if m == 1 && ncol == 1
                        if ~strcmpi(fields,labels)
                            error(['cTimeSeries:getTimeSeries:Invalid field(s) of ',...
                            fields]);
                        end
                        ts = [datenum(obj.Time),obj.Value];
                    elseif m > 1 && ncol == 1
                        error('cTimeSeries:getTimeSeries:size mismatch between Field(s) and Label(s)');
                    elseif m == 1 && ncol > 1
                        ts(:,1) = datenum(obj.Time);
                        idx = 0;
                        for i = 1:ncol
                            if strcmpi(fields,labels{i})
                                idx = i;
                                break;
                            end
                        end
                        if idx == 0
                            error(['cTimeSeries:getTimeSeries:Invalid field(s) of ',...
                            fields]);
                        end
                        ts(:,2) = obj.Value(:,idx);
                    else
                        ts(:,1) = datenum(obj.Time);
                        for i = 1:m
                            idx = 0;
                            for j = 1:ncol
                                if (iscell(fields) && strcmpi(fields{i},labels{j})) ||...
                                   (ischar(fields) && strcmpi(fieldsCell{i},labels{j}))    
                                    idx = j;
                                    break;
                                end
                            end
                            if idx == 0 %not found
                                error(['cTimeSeries:getTimeSeries:Invalid field(s) of ',...
                                fields{i}]);
                            end
                            ts(:,i+1) = obj.Value(:,idx);
                        end
                    end
                end
                ts = timeseries_window(ts,'TradingHours',tradingHours,...
                                          'TradingBreak',tradingBreak);
                if ~(isempty(dateFrom) && isempty(dateTo))
                    ts = timeseries_window(ts,'FromDate',dateFrom,...
                                          'ToDate',dateTo);
                end
                if ~isempty(interval) && ~strcmpi(interval,'1m')
                    ts = timeseries_compress(ts,'Frequency',interval);
                end
            end
        end
        % 
        
        % save self-defined time series to file
        function writeTimeSeries2File(obj,varargin)
            if nargin == 0
                error('cTimeSeries:genTimeSeriesFromFile:insufficient inputs');
            end
            %
            p = inputParser;
            p.CaseSensitive = false;
            p.addParameter('Directory',{},...
                @(x) validateattributes(x,{'char'},{},'','Directory'));
            p.addParameter('FileName',{},...
                @(x) validateattributes(x,{'char'},{},'','FileName'));
            p.addParameter('Fields',{},...
                @(x) validateattributes(x,{'char','cell'},{},'','Fields'));
            p.addParameter('FromDate',[],...
                @(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
            p.addParameter('ToDate',[],...
                @(x) validateattributes(x,{'char','numeric'},{},'','ToDate'));
            p.addParameter('Frequency',[],...
                @(x) validateattributes(x,{'char','numeric'},{},'','Frequency'));
            p.addParameter('TradingHours',{},...
                @(x) validateattributes(x,{'char','cell'},{},'','TradingHours'));
            p.addParameter('TradingBreak',{},...
                @(x) validateattributes(x,{'char','cell'},{},'','TradingBreak'));
            p.parse(varargin{:});
            directory = p.Results.Directory;
            fileName = p.Results.FileName;
            fields = p.Results.Fields;
            dateFrom = p.Results.FromDate;
            dateTo = p.Results.ToDate;
            interval = p.Results.Frequency;
            tradingHours = p.Results.TradingHours;
            tradingBreak = p.Results.TradingBreak;
            
%             if isempty(directory)
%                 error('cTimeSeries:genTimeSeriesFromFile:input Directory missing');
%             end
            
            if isempty(fileName)
                error('cTimeSeries:genTimeSeriesFromFile:input FileName missing');
            end
            f.data = getTimeSeries(obj,'Fields',fields,...
                                       'FromDate',dateFrom,...
                                       'ToDate',dateTo,...
                                       'Frequency',interval,...
                                       'TradingHours',tradingHours,...
                                       'TradingBreak',tradingBreak);
            if isempty(fields)
                f.label = obj.Label;
            else
                if ischar(fields)
                    fieldsCell = regexp(fields,',','split');
                    f.label = fieldsCell;
                else
                    f.label = fields;
                end
            end
            f.codes = obj.Codes;
            f.interval = obj.Frequency;
            f.name = 'f';
            if isempty(directory)
                save(fileName,f.name);
            else
                if ~isdir(directory)
                    mkdir(directory)
                end
                if strcmpi(directory(end),'\')
                    save([directory,fileName],f.name);
                else
                    save([directory,'\',fileName],f.name);
                end
            end
        end
        %
        
        % test newly developped functions
        function obj = updateTimeSeries(obj)
            if isempty(obj.Codes)
                return
            end
            % update Bloomberg data
            if ~isempty(obj.Codes{1})
                obj = updateTimeSeriesFromBloomberg(obj);
            end
            % update Wind data
            if ~isempty(obj.Codes{2})
                obj = updateTimeSeriesFromWind(obj);
            end
        end
        %
        
        
    end
    %methods end
    
    methods (Access = private)
        %
        function obj = init(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            p.addParameter('Time',[],...
                @(x) validateattributes(x,{'numeric'},{},'','Time'));
            p.addParameter('Value',[],...
                @(x) validateattributes(x,{'numeric'},{},'','Value'));
            p.addParameter('Label',{},...
                @(x) validateattributes(x,{'char','cell'},{},'','Label'));
            p.parse(varargin{:});
            obj.Time = p.Results.Time;
            obj.Value = p.Results.Value;
            obj.Label = p.Results.Label;
            if size(obj.Time,1) ~= size(obj.Value,1)
                error('cTimeSeries:size mismatch between time and data');
            end
            if (ischar(obj.Label) && size(obj.Value,2) ~= 1)||...
               (iscell(obj.Label) && length(obj.Label) ~= size(obj.Value,2))
                error('cTimeSeries:size mismatch between data and label');
            end
        end
        %
        
        % generate timeseries object from bloombeeg
        function obj = genTimeSeriesFromBloomberg(obj,varargin)
            if nargin == 0
                error('cTimeSeries:genTimeSeriesFromBloomberg:insufficient inputs');
            else
                p = inputParser;
                p.CaseSensitive = false;
                p.addParameter('Connection',{},...
                    @(x) validateattributes(x,{'blp'},{},'','Connection'));
                p.addParameter('BloombergCode',{},...
                    @(x) validateattributes(x,{'char'},{},'','BloombergCode'));
                p.addParameter('Fields',{},...
                    @(x) validateattributes(x,{'char','cell'},{},'','Fields'));
                p.addParameter('FromDate',[],...
                    @(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
                p.addParameter('ToDate',[],...
                    @(x) validateattributes(x,{'char','numeric'},{},'','ToDate'));
                p.addParameter('Frequency',[],...
                    @(x) validateattributes(x,{'char','numeric'},{},'','Frequency'));
                p.parse(varargin{:});
                %
                c = p.Results.Connection;
                sec = p.Results.BloombergCode;
                fields = p.Results.Fields;
                dateFrom = p.Results.FromDate;
                dateTo = p.Results.ToDate;
                freq = p.Results.Frequency;
                if isnumeric(dateFrom)
                    dateFrom = datestr(dateFrom);
                end
                if isnumeric(dateTo)
                    dateTo = datestr(dateTo);
                end
                if isnumeric(freq)
                    %IntradayBarRequest with time interval specified:
                    %'TRADE','BID','ASK','BID_BEST','ASK_BEST'
                    if ~sum(strcmpi(fields,{'trade','bid','ask','bid_best','ask_best'}))
                        error('cTimeSeries:genTimeSeriesFromBloomberg:invalid fields input')
                    end
                    d = timeseries(c,sec,{dateFrom,dateTo},freq,fields);
                    if ~isempty(d)
                        obj.Time = d(:,1);
                        obj.Value = d(:,2:end-2);
                        %bloomberg will automatically strcuture data into
                        %the following column order
                        %'Number of ticks' and 'Total tick value' in the bar
                        %are ignored
                        obj.Label = {'open','high','low','close','volume'};
                        codes = cell(2,1);
                        codes{1} = sec;
                        obj.Codes = codes;
                        obj.Frequency = [num2str(freq),'m'];
                    else
                        obj = cTimeSeries;
                    end
                elseif strcmpi(freq,'tick')
                    %tick data
                    ticks = timeseries(c,sec,{dateFrom,dateTo},{},fields);
                    [d,label] = bloombergticksregroup(ticks);
                    if ~isempty(d)
                        obj.Time = d(:,1);
                        obj.Value = d(:,2:end);
                        obj.Label = label;
                        codes = cell(2,1);
                        codes{1} = sec;
                        obj.Codes = codes;
                        obj.Frequency = freq;
                    else
                        obj = cTimeSeries;
                    end
                else
                    %download daily data
                    d = history(c,sec,fields,dateFrom,dateTo);
                    if ~isempty(d)
                        obj.Time = d(:,1);
                        obj.Value = d(:,2:end);
                        %original fields are 'px_open','px_high','px_low'...
                        %'px_last','volume','open_int'
                        obj.Label = {'open','high','low','close','volume','oi'};
                        codes = cell(2,1);
                        codes{1} = sec;
                        obj.Codes = codes;
                        obj.Frequency = freq;
                    else
                        obj = cTimeSeries;
                    end
                end
            end
        end
        %
        
        % generate timeseries object from wind
        function obj = genTimeSeriesFromWind(obj,varargin)
            if nargin == 0
                error('cTimeSeries:genTimeSeriesFromWind:insufficient inputs');
            end
            %
            p = inputParser;
            p.CaseSensitive = false;
            p.addParameter('Connection',{});
            p.addParameter('WindCode',{},...
                @(x) validateattributes(x,{'char'},{},'','WindCode'));
            p.addParameter('Fields',{},...
                @(x) validateattributes(x,{'char','cell'},{},'','Fields'));
            p.addParameter('FromDate',[],...
                @(x) validateattributes(x,{'char','numeric'},{},'','FromDate'));
            p.addParameter('ToDate',[],...
                @(x) validateattributes(x,{'char','numeric'},{},'','ToDate'));
            p.addParameter('Frequency',[],...
                @(x) validateattributes(x,{'char','numeric'},{},'','Frequency'));
            p.parse(varargin{:});
            %
            w = p.Results.Connection;
            sec = p.Results.WindCode;
            fields = p.Results.Fields;
            dateFrom = p.Results.FromDate;
            dateTo = p.Results.ToDate;
            interval = p.Results.Frequency;
            %sanity check
            if isempty(sec)
                error('cTimeSeries:genTimeSeriesFromWind:missing WindCode')
            end
     
            if isnumeric(interval)
                dateFrom = [datestr(dateFrom,'yyyy-mm-dd'),' 09:00:00'];
                dateTo = [datestr(dateTo,'yyyy-mm-dd'),' 15:15:00'];
                obj.Frequency = [num2str(interval),'m'];
                [d,~,~,t] = w.wsi(sec,fields,dateFrom,dateTo,...
                                    ['BarSize=',num2str(interval)]);
                if isnumeric(d)
                    obj.Time = t;
                    obj.Value = d;
                    fieldsCell = regexp(fields,',','split');
                    obj.Label = fieldsCell;
                    codes = cell(2,1);
                    codes{2} = sec;
                    obj.Codes = codes;
                    obj.Frequency = [num2str(interval),'m'];
                else
                    error(d{1});
                end
            elseif strcmpi(interval,'1d')
                dateFrom = datestr(dateFrom,'yyyy-mm-dd');
                dateTo = datestr(dateTo,'yyyy-mm-dd');
                [d,~,~,t] = w.wsd(sec,fields,dateFrom,dateTo,...
                                    'Fill=previous');
                % rubbish wind makes the code below so annoying
                if ~isnumeric(d) && strcmpi(sec(end-2:end),'CZC')
                    n = length(sec);
                    sec_new = [sec(1:n-7),'1',sec(n-6:end)];
                    [d,~,~,t] = w.wsd(sec_new,fields,dateFrom,dateTo,...
                                    'Fill=previous');
                    if ~isnumeric(d)
                        error('cTimeSeries:genTimeSeriesFromWind Failed');
                    end
                end
                obj.Time = t;
                obj.Value = d;
                fieldsCell = regexp(fields,',','split');
                obj.Label = fieldsCell;
                codes = cell(2,1);
                codes{2} = sec;
                obj.Codes = codes;
                obj.Frequency = interval;
            elseif strcmpi(interval,'tick')
                [d,~,~,t] = w.wst(sec,fields,dateFrom,dateTo);
                obj.Time = t;
                obj.Value = d;
                fieldsCell = regexp(fields,',','split');
                obj.Label = fieldsCell;
                codes = cell(2,1);
                codes{2} = sec;
                obj.Codes = codes;
                obj.Frequency = interval;
            end
        end
        %
        
        % generate timeseries object from local file
        function obj = genTimeSeriesFromFile(obj,varargin)
            if nargin == 0
                error('cTimeSeries:genTimeSeriesFromFile:insufficient inputs');
            end
            p = inputParser;
            p.CaseSensitive = false;
            p.addParameter('FileName',{},...
                @(x) validateattributes(x,{'char'},{},'','FileName'));
            p.parse(varargin{:});
            fileName = p.Results.FileName;
            if isempty(fileName)
                error('cTimeSeries:genTimeSeriesFromFile:missing filename');
            end
            [flag,d] = isfile(fileName);
            if ~flag
                error('cTimeSeries:genTimeSeriesFromFile:invalid filename');
            end
            % todo:revise the following code
            if ~isstruct(d)
                error('cTimeSeries:genTimeSeriesFromFile:invalid file syntax');
            end
            if ~isempty(d.data)
                obj.Time = d.data(:,1);
                obj.Value = d.data(:,2:end);
                obj.Label = d.label;
                obj.Codes = d.codes;
                obj.Frequency = d.interval;
            else
                obj.Time = [];
                obj.Value = [];
                obj.Label = {};
                obj.Codes = {};
                obj.Frequency = {};
            end
        end
        %
        
        %
        function obj = updateTimeSeriesFromBloomberg(obj)
            c = bbgconnect;
            time = obj.Time;
            data = obj.Value;
            bbgCode = obj.Codes{1};
            if ~isempty(bbgCode)
                if ~isempty(strfind(bbgCode,'IFB')) || ...
                        ~isempty(strfind(bbgCode,'FFB')) || ...
                        ~isempty(strfind(bbgCode,'FFD')) || ...
                        ~isempty(strfind(bbgCode,'TFC')) || ...
                        ~isempty(strfind(bbgCode,'TFT'))
                    isFinancial = true;
                else
                    isFinancial = false;
                end
            else
                error('cTimeSeries:updateTimeSeriesFromBloomberg:internal error!')
            end
            
            
            %update timeseries until the last business date
            if ~isholiday(today)
                hh = hour(now);
                if hh > 15 && hh < 21
                    lastbd = today;
                else
                    if isFinancial
                        if hh <= 15
                            lastbd = businessdate(today,-1);
                        else
                            lastbd = today;
                        end
                    else
                        lastbd = businessdate(today,-1);
                    end
                end
            else
                lastbd = businessdate(today,-1);
            end
            
            if strcmpi(obj.Frequency,'1d')
                d_last = floor(time(end));
                if d_last >= lastbd
                    return
                else
                    fields = cell(length(obj.Label),1);
                    for i = 1:length(obj.Label)
                        if strcmpi(obj.Label{i},'open') ||...
                           strcmpi(obj.Label{i},'high') ||...
                           strcmpi(obj.Label{i},'low')
                            fields{i} = ['px_',obj.Label{i}];
                        elseif strcmpi(obj.Label{i},'close')
                            fields{i} = 'px_last';
                        elseif strcmpi(obj.Label{i},'volume')
                            fields{i} = 'volume';
                        elseif strcmpi(obj.Label{i},'oi')
                            fields{i} = 'open_int';
                        else
                        end
                    end
                    d = history(c,obj.Codes{1},fields,datestr(d_last),datestr(lastbd));
                    if ~isempty(d)
                        idx = time < d_last;
                        t = [time(idx);d(:,1)];
                        d = [data(idx,:);d(:,2:end)];
                        obj.Time = t;
                        obj.Value = d;
                    end
                end
            %    
            elseif strcmpi(obj.Frequency,'1m')
                t_start = time(end);
                ex_close = '15:15:00';
                t_end = [datestr(lastbd),' ',ex_close];
                
                d = timeseries(c,obj.Codes{1},{t_start,t_end},1,'trade');
                if ~isempty(d)
                    idx = time < datenum(t_start);
                    t = [time(idx);d(:,1)];
                    d = [data(idx,:);d(:,2:end-2)];
                    obj.Time = t;
                    obj.Value = d;
                end
            %
            elseif strcmpi(obj.Frequency,'tick')
                t_start = time(end);
                ex_close = '15:15:00';
                t_end = [datestr(lastbd),' ',ex_close];
                if size(obj.Label,2) == 6
                    fields = {'bid','trade','ask'};
                elseif size(obj.Label,2) == 2
                    if strcmpi(obj.Label{1},'tradeprice')
                        fields = 'trade';
                    elseif strcmpi(obj.Label{1},'bidprice')
                        fields = 'bid';
                    else
                        fields = 'ask';
                    end
                elseif size(obj.Label,2) == 4
                    if strcmpi(obj.Label{1},'bidprice')
                        fields = 'bid';
                    elseif strcmpi(obj.Label{1},'askprice')
                        fields = 'ask';
                    else
                        fields = 'trade';
                    end
                    %
                    if strcmpi(obj.Label{3},'bidprice')
                        fields = [fields,',bid'];
                    elseif strcmpi(obj.Label{3},'askprice')
                        fields = [fields,',ask'];
                    else
                        fields = [fields,',trade'];
                    end
                    fields = regexp(fields,',','split');
                end
                ticks = timeseries(c,obj.Codes{1},{t_start,t_end},[],fields);
                d = bloombergticksregroup(ticks);
                if ~isempty(d)
                    idx = time < datenum(t_start);
                    t = [time(idx);d(:,1)];
                    d = [data(idx,:);d(:,2:end)];
                    obj.Time = t;
                    obj.Value = d;
                end
            end
            close(c);
        end
        %
        
        %
        function obj = updateTimeSeriesFromWind(obj)
            w = windconnect;
            time = obj.Time;
            data = obj.Value;
            fields = obj.Label;
            windCode = obj.Codes{2};
            if ~isempty(windCode)
                if ~isempty(strfind(windCode,'IF')) || ...
                        ~isempty(strfind(windCode,'IH')) || ...
                        ~isempty(strfind(windCode,'IC')) || ...
                        ~isempty(strfind(windCode,'TF')) || ...
                        ~isempty(strfind(windCode,'TF'))
                    isFinancial = true;
                else
                    isFinancial = false;
                end
            else
                error('cTimeSeries:updateTimeSeriesFromWind:internal error!')
            end
            
            
            if ~isholiday(today)
                hh = hour(now);
                if hh > 15 && hh < 21
                    lastbd = today;
                else
                    if isFinancial
                        if hh <= 15
                            lastbd = businessdate(today,-1);
                        else
                            lastbd = today;
                        end
                    else
                        lastbd = businessdate(today,-1);
                    end
                end
            else
                lastbd = businessdate(today,-1);
            end
            
            if strcmpi(obj.Frequency,'1d')
                d_last = floor(time(end));
                if d_last >= lastbd
                    return
                else
                    [d,~,~,t] = w.wsd(obj.Codes{2},fields,datestr(d_last,'yyyy-mm-dd'),...
                                datestr(lastbd,'yyyy-mm-dd'));
                    if ~isempty(d)
                        idx = time < d_last;
                        t = [time(idx);t(:,1)];
                        d = [data(idx,:);d(:,1:end)];
                        obj.Time = t;
                        obj.Value = d;
                    end
                end
            elseif strcmpi(obj.Frequency,'1m')
                ex_close = '15:15:00';
                t_end = [datestr(lastbd),' ',ex_close];
                t_start = time(end);
                %
                [d,~,~,t] = w.wsi(obj.Codes{2},fields,datestr(t_start,'yyyy-mm-dd HH:MM:SS'),...
                    datestr(t_end,'yyyy-mm-dd HH:MM:SS'),'BarSize=1');
                if ~isempty(d)
                    idx = time < datenum(t_start);
                    t = [time(idx);t(:,1)];
                    d = [data(idx,:);d(:,1:end)];
                    obj.Time = t;
                    obj.Value = d;
                end
            else
                ex_close = '15:15:00';
                t_end = [datestr(lastbd),' ',ex_close];
                t_start = time(end);
                [d,~,~,t] = w.wst(obj.Codes{2},fields,t_start,t_end);
                if ~isempty(d)
                    idx = time < datenum(t_start);
                    t = [time(idx);t(:,1)];
                    d = [data(idx,:);d(:,1:end)];
                    obj.Time = t;
                    obj.Value = d;
                end
            end
        end
        %
    end
    %methods end
    
end

