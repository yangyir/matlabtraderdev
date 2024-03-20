classdef cTHS < cDataSource
    
    properties
        dsn_ = 'ths'
        ds_
    end
    
    methods
        function obj = cTHS
            try
%                 obj.ds_ = THS_iFinDLogin('dyqh659','2011Sep29');
                obj.ds_ = THS_iFinDLogin('tg5058','4bbeed');
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
        data = tickdata(obj,instrument,startdate,enddate)
        
    end
end