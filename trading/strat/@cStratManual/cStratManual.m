classdef cStratManual < cStrat
    
    properties
    end
    
    methods
        function obj = cStratManual
            obj.name_ = 'stratmanual';
        end
        
        function signals = gensignals(obj)
            variablenotused(obj);
            signals = {};
        end
        
        function [] = autoplacenewentrusts(obj,signals)
            variablenotused(obj);
            variablenotused(signals);
        end
        
        function [] = updategreeks(obj)
            variablenotused(obj);
        end
        
        function [] = riskmanagement(obj,dtnum)
            variablenotused(obj);
            variablenotused(dtnum);
        end
        
        function [] = initdata(obj)
            variablenotused(obj);
        end
    end
    
end

