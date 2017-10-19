classdef cStratFutMultiWR < cStrat
    
    properties
        nperiod_ = 144;
        unit_ = 1;
    end
    
        
    properties
        data_@double
    end
    
    methods
        function obj = cStratFutMultiWR
            obj.name_ = 'multiplewr';
        end
    end
    
    methods
        function signals = gensignal(obj,portfolio,quotes)
        end
        %end of gensignal
        
        function [] = initdata(obj)
            
        end
        %end of initdata
        
        function indicator = 
    end
    
end

