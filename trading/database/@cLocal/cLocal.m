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
        
        flag = isconnect(obj)
        [] = close(obj)
        data = intradaybar(obj,instrument,startdate,enddate,interval,field)
        data = realtime(obj,instruments,fields)
        data = history(obj,instrument,fields,fromdate,todate)
        
        [] = demo(obj)
           
    end
    
end