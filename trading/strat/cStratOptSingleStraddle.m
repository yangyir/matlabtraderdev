classdef cStratOptSingleStraddle < cStrat
    properties
        
    end
    
    methods
        function obj = cStratOptSingleStraddle
            obj.name_ = 'optsinglestraddle';
        end
        
        
    end
    
    methods
        function signals = gensignal(obj,portfolio,quotes)
            underliers = obj.underliers_.getinstrument;
            underlier = underliers{1};
            
            
        end
        
        function [] = querypositions(obj,counter,qms)
            opt_querypositions(obj.instruments_,counter,qms);
        end
        
    end
    
    methods (Access = private)
        function strikes = getstrikes(obj)
            opts = obj.instruments_.getinstrument;
            n = obj.count;
            strikes = zeros(n,1);
            for i = 1:n
                strikes(i) = opts{i}.opt_strike;
            end
            strikes = unique(strikes);
            strikes = sort(strikes);
                
        end
    end
end