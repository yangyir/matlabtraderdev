classdef (Abstract) cDataSource < handle
   
    properties (Abstract)
        dsn_
        ds_
    end
    
    methods (Abstract)
        flag = isconnect(obj)
        close(obj)
        data = intradaybar(obj,contract,startdate,enddate,interval,field)
        data = realtime(obj,contract,fields)
        data = history(obj,contract,fields,fromdate,todate)
    end
    
end

