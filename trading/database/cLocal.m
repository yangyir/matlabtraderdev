classdef cLocal < cDataSource
    properties
        dsn_ = 'local'
        ds_
    end
    
    methods
        function obj = cLocal(varargin)
            if nargin == 0
                obj.ds_ = getenv('DATAPATH');
            else
                obj.ds_ = varargin{1};
            end
        end
    end
    
    
    methods
        function flag = isconnect(obj)
            if isempty(obj.ds_)
                flag = false;
            else
                flag = true;
            end
        end
        %end of isconnect
        
        function close(obj)
            obj.ds_ = '';
        end
        %end of close
        
        
        function data = intradaybar(obj,instrument,startdate,enddate,interval,field)
            %some sanity check first
            if ~(strcmpi(field,'trade') || ...
                    strcmpi(field,'bid') || ...
                    strcmpi(field,'ask'))
                error(['cLocal:intradaybar:field ',field,' not supported'])
            end
            
            if ~ischar(startdate), error('cLocal:intradaybar:startdate must be char'); end
            if ~ischar(enddate), error('cLocal:intradaybar:enddate must be char'); end
            
            if ~isnumeric(interval), error('cLocal:intradaybar:interval must be scalar'); end
            if isempty(interval), interval = 1; end
            
            if isa(instrument,'cFutures')
                code_ctp = instrument.code_ctp;
                bds = gendates('fromdate',startdate,'todate',enddate);
                n = size(bds,1);
                
                if n == 1
                    fn_ = [code_ctp,'_',datestr(bds,'yyyymmdd'),'_1m.txt'];
                    fullfn_ = [obj.ds_,'intradaybar\',code_ctp,'\',fn_];
                    data_raw_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
                else
                    fn_ = [code_ctp,'_',datestr(bds(1),'yyyymmdd'),'_1m.txt'];
                    fullfn_ = [obj.ds_,'intradaybar\',code_ctp,'\',fn_];
                    data_raw_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
                    for i = 2:n
                        fn_ = [code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_1m.txt'];
                        fullfn_ = [obj.ds_,'intradaybar\',code_ctp,'\',fn_];
                        data_new_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
                        tmp = data_raw_;
                        data_raw_ = [tmp;data_new_];
                    end
                end
                    
                %the columns in d contain the following:
                %numeric representation of data and time
                %open price
                %high price
                %low price
                %closing price
                %volume of ticks
                %number of ticks
                %total tick value in the bar
                data = timeseries_compress(data_raw_(:,1:5),'tradinghours',instrument.trading_hours,...
                    'tradingbreak',instrument.trading_break,...
                    'frequency',[num2str(interval),'m']);
            else
                classname = class(instrument);
                error(['cLocal:intradaybar:not implemented for class ',...
                    classname])
            end
 
            
        end
        %end of intradaybar
        
        function data = realtime(obj,instruments,fields)
            %note:the realtime function in cLocal is for REPLY the market
            %data process and the fields input shall be given as particular
            %date and time, e.g.yyyy-mm-dd HH:MM:SS
            if isa(instruments,'cInstrument')
                n = 1;
                list_ctp = cell(1,1);
                list_ctp{1} = instruments.code_ctp;
            elseif iscell(instruments)
                n = length(instruments);
                list_ctp = cell(n,1);
                for i = 1:n
                    if ischar(instruments{i})
                        list_ctp{i} = instruments{i};
                    elseif isa(instruments{i},'cInstrument')
                        list_ctp{i} = instruments{i}.code_ctp;
                    else
                        error('cLocal:realtime:invalid input')
                    end
                end
            else
                list_ctp = instruments;
            end             
                
            last_update_dt = zeros(n,1);
            time_ = zeros(n,1);
            last_trade = zeros(n,1);
            bid = zeros(n,1);
            ask = zeros(n,1);
            dstr = datestr(fields,'yyyymmdd'); %date
            dtnum = datenum(fields);
            for i = 1:n
                try
                    fn_ = [list_ctp{i},'_',dstr,'_1m.txt'];
                    fullfn_ = [obj.ds_,'intradaybar\',list_ctp{i},'\',fn_];
                    data_raw_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
                    idx = data_raw_(:,1) == dtnum;
                    d = data_raw_(idx,:);
                    if isempty(d)
                        %in case the datestr cannot be found in data_raw_ we
                        %choose the latest one which happens before the input
                        %datestr
                        idx = find(data_raw_(:,1) <= dtnum);
                        idx = idx(end);
                        d = data_raw_(idx,:);
                    end
                    last_update_dt(i) = floor(d(1));
                    time_(i) = d(1);
                    last_trade(i) = d(end);
                    bid(i) = last_trade(i);
                    ask(i) = last_trade(i);
                    
                    data = struct('last_update_dt',last_update_dt,...
                        'time',time_,...
                        'last_trade',last_trade,...
                        'bid',bid,'ask',ask);
                catch e
                    error(['cLocal:realtime:',e.message])
                end
            end
            
        end
        %end of realtime
        
        function data = history(obj,instrument,fields,fromdate,todate)
            %to be implemented
            data = [];
        end
        %end of history
    end
    
end