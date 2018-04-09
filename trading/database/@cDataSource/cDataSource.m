classdef (Abstract) cDataSource < handle
   
    properties (Abstract)
        dsn_
        ds_
    end
    
    methods (Abstract)
        flag = isconnect(obj)
        [] = close(obj)
        data = intradaybar(obj,instrument,startdate,enddate,interval,field)
        data = realtime(obj,instruments,fields)
        data = history(obj,instrument,fields,fromdate,todate)
    end
    
end

