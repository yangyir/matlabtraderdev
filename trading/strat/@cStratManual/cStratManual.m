classdef cStratManual < cStrat
    
    properties
        usehistoricaldata_@logical
    end
    
    methods
        function obj = cStratManual
            obj.name_ = 'stratmanual';
            obj.usehistoricaldata_ = false;
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
            obj.initdata_manual;
        end 
    end
    
    methods (Access = public)
        %some technical analysis related funcs
        wrinfo = wlpr(obj,instrument,nperiod)
        [] = stratplot(obj,instrument,varargin)
    end
    
    methods (Access = public)
        %some trading related funcs
        [ret,entrusts] = placeentrusts(obj,varargin)
        [ret] = placeconditionalentrusts(obj,varargin)
    end
    
    
    methods (Access = private)
        [] = initdata_manual(obj)
    end
    
end

