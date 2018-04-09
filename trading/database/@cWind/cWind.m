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
        
        flag = isconnect(obj)
        [] = close(obj)
        data = intradaybar(obj,instrument,startdate,enddate,interval,field)       
        data = realtime(obj,instruments,fields)
        data = history(obj,contract,fields,fromdate,todate)
        
    end
end