classdef cBloomberg < cDataSource
    
    properties
        dsn_ = 'bloomberg'
        ds_
    end
    
    methods
        function obj = cBloomberg
            try
                obj.ds_ = bbgconnect;
            catch e
                fprintf(e.message);
            end
        end
        %end of constructor
        
        function flag = isconnect(obj)
            flag = obj.ds_.isconnection;
        end
        %end of isconnect
        
        function close(obj)
            obj.ds_.close;
        end
        %end of close
        
        function data = intradaybar(obj,contract,startdate,enddate,interval,field)
            %some sanity check first
            if ~(strcmpi(field,'trade') || ...
                    strcmpi(field,'bid') || ...
                    strcmpi(field,'ask'))
                error(['cBloomberg:intradaybar:field ',field,' not supported'])
            end
            
            if ~ischar(startdate), error('cBloomberg:intradaybar:startdate must be char'); end
            if ~ischar(enddate), error('cBloomberg:intradaybar:enddate must be char'); end
            
            if ~isnumeric(interval), error('cBloomberg:intradaybar:interval must be scalar'); end
            if isempty(interval), interval = 1; end
            
            if isa(contract,'cFutures')
                code_bbg = contract.code_bbg;
                
                bds = gendates('fromdate',startdate,'todate',enddate);
                n = size(bds,1);
                if n == 1
                    enddate_ = datestr(businessdate(startdate,1),'yyyy-mm-dd');
                    data_raw_ = obj.ds_.timeseries(code_bbg,{startdate,enddate_},...
                        1,field);
                else
                    startdate_ = datestr(bds(1),'yyyy-mm-dd');
                    enddate_ = datestr(bds(2),'yyyy-mm-dd');
                    data_raw_ = obj.ds_.timeseries(code_bbg,{startdate_,enddate_},...
                        1,field);
                    for i = 2:n
                        startdate_ = datestr(bds(i),'yyyy-mm-dd');
                        if i < n
                            enddate_ = datestr(bds(i+1),'yyyy-mm-dd');
                        else
                            enddate_ = datestr(businessdate(startdate_,1),'yyyy-mm-dd');
                        end
                        data_new_ = obj.ds_.timeseries(code_bbg,{startdate_,enddate_},...
                            1,field);
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
                data = timeseries_compress(data_raw_(:,1:5),'tradinghours',contract.trading_hours,...
                    'tradingbreak',contract.trading_break,...
                    'frequency',[num2str(interval),'m']);
            else
                classname = class(contract);
                error(['cBloomberg:intradaybar:not implemented for class ',...
                    classname])
            end
        end
        %end of intradaybar
        
        function data = realtime(obj,contract,fields)
            if ~iscell(fields) && ischar(fields), fields = {fields}; end
            
            data = obj.ds_.getdata(contract.code_bbg,fields);
        end
        %end of realtime
        
        function data = history(obj,contract,fields,fromdate,todate)
            if ~iscell(fields) && ischar(fields), fields = {fields}; end
            
            data = obj.ds_.history(contract.code_bbg,fields,fromdate,todate);
        end
        %end of history
        
    end
    
end

