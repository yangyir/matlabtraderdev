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
            if isempty(obj.ds_)
                flag = false;
            else
                flag = obj.ds_.isconnection;
            end
        end
        %end of isconnect
        
        function [] = close(obj)
            if isempty(obj.ds_)
                return
            else
                obj.ds_.close;
            end
        end
        %end of close
        
        function data = intradaybar(obj,instrument,startdate,enddate,interval,field)
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
            
            if isa(instrument,'cFutures')
                code_bbg = instrument.code_bbg;
                
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
                data = timeseries_compress(data_raw_(:,1:5),'tradinghours',instrument.trading_hours,...
                    'tradingbreak',instrument.trading_break,...
                    'frequency',[num2str(interval),'m']);
            else
                classname = class(instrument);
                error(['cBloomberg:intradaybar:not implemented for class ',...
                    classname])
            end
        end
        %end of intradaybar
        
        function data = realtime(obj,instruments,fields)
            if isempty(obj.ds_)
                data = [];
                return
            end
            
            if ~iscell(fields) && ischar(fields), fields = {fields}; end
            
            if isa(instruments,'cInstrument')
                list_bbg = instruments.code_bbg;
            elseif iscell(instruments)
                n = length(instruments);
                list_bbg = cell(n,1);
                for i = 1:n
                    if ischar(instruments{i})
                        list_bbg{i} = instruments{i};
                    elseif isa(instruments{i},'cInstrument')
                        list_bbg{i} = instruments{i}.code_bbg;
                    else
                        error('cBloomberg:realtime:invalid input')
                    end
                end
            else
                list_bbg = instruments;
            end
            
            data = obj.ds_.getdata(list_bbg,fields);
        end
        %end of realtime
        
        function data = history(obj,instrument,fields,fromdate,todate)
            if ~iscell(fields) && ischar(fields), fields = {fields}; end
            
            data = obj.ds_.history(instrument.code_bbg,fields,fromdate,todate);
        end
        %end of history
        
    end
    
end

