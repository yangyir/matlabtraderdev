classdef cStratFutBatman < cStrat
    properties
    end
    
    methods
        function obj = cStratFutBatman
            obj.name_ = 'stratfutbatman';
        end
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_futbatman;
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_futbatman(signals)
        end
        %end of autoplacenewentrusts
        
        function [] = updategreeks(obj)
            obj.updategreeks_futbatman
        end
            
        function [] = riskmanagement(obj,dtnum)
            obj.riskmanagement_futbatman(dtnum)
        end
        
        function [] = initdata(obj)
            obj.initdata_futbatman;
        end
        %end of initdata
    end
    
    methods (Access = private)
        [] = riskmanagement_futbatman(obj,dtnum)
        [] = updategreeks_futbatman(obj)
        signals = gensignals_futbatman(obj)
        [] = autoplacenewentrusts_futbatman(obj,signals)
        [] = initdata_futbatman(obj)
    end
    
    methods (Static = true)
        [] = debug(~)
    end
    
end