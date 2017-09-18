classdef cWind < cDataSource
    
    properties
        dsn_ = 'wind'
        ds_
    end
    
    methods
        function obj = cWind
            try
                obj.ds_ = windmatlab;
            catch e
                fprintf(e.message);
            end
        end
        %end of constructor
        
        function flag = isconnect(obj)
            if isempty(obj.ds_)
                flag = false;
            else
                flag = obj.ds_.isconnected;
            end
        end
        
        function [] = close(obj)
            if isempty(obj.ds_)
                return
            else
                obj.ds_.close;
            end
        end
        
        function data = intradaybar(obj,instrument,startdate,enddate,interval,field)
            %to be implemented
            if isempty(obj.ds_)
                data = [];
                return
            end
        end
        
        function data = realtime(obj,instruments,fields)
            if isempty(obj.ds_)
                data = [];
                return
            end
            
            if iscell(fields)
                %wind fields are input as char not cell
                n = length(fields);
                fields_ = fields{1};
                for i = 2:n
                    tmp = [fields_,',',fields{i}];
                    fields_ = tmp;
                end
            end
            
            if isa(instruments,'cInstrument')
                list_wind = instruments.code_wind;
            elseif iscell(instruments)
                list_wind = instruments{1};
                n = length(instruments);
                for i = 2:n
                    tmp = [list_wind,',',instruments{i}];
                    list_wind = tmp;
                end
            elseif ischar(instruments)
                list_wind = instruments;
            end
            
            data = obj.ds_.wsq(list_wind,fields);
        end
        %end of realtime
        
        function data = history(obj,contract,fields,fromdate,todate)
        
        end
        %end of history
        
    end
end