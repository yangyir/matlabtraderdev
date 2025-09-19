classdef cStratOptMultiFractal < cStratFutMultiFractal
    events
        DummyTradeOpen
        DummyTradeClose
    end
    
    properties
        call_@char
        put_@char
    end
    
    methods
        function obj = cStratOptMultiFractal
            obj.name_ = 'multifractalopt';
        end
        %
    end
    
    
    %derived (abstract) methods from superclass
    methods
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_optmultifractal(signals);
        end
        %
         
        function [] = updategreeks(obj)
            obj.updategreeks_optmultifractal;
        end
        %
        function [] = riskmanagement(obj,dtnum)
            obj.riskmanagement_optmultifractal(dtnum);
        end
        %

    end
    
    methods
        [] = OnDummyTradeOpen(obj,~,eventData);
        [] = OnDummyTradeClose(obj,~,eventData);
    end
    
    methods (Access = private)
        [] = autoplacenewentrusts_optmultifractal(obj,signals)
        [] = updategreeks_optmultifractal(obj)
        [] = riskmanagement_optmultifractal(obj,dtnum)
    end
    
end

