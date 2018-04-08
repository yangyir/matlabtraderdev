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
        
        flag = isconnect(obj)
        [] = close(obj)
        data = intradaybar(obj,instrument,startdate,enddate,interval,field)
        data = realtime(obj,instruments,fields)
        data = history(obj,instrument,fields,fromdate,todate)
    
    end
    
    
    
end

