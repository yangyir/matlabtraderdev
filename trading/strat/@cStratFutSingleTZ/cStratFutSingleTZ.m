classdef cStratFutSingleTZ < cStrat
    %note: strategy can be used on single futures asset
    %signals are based on triangle zone drawn from the candle prices
    properties
        lowerpoint1_@cPoint
        lowerpoint2_@cPoint
        upperpoint1_@cPoint
        upperpoint2_@cPoint
        %
        tradinglengthperday_@double   %the trading length in minutes of the single futures asset
        timevec_@double
    end
    
   methods
        function obj = cStratFutSingleTZ
            obj.name_ = 'singletz';
        end
        %end of cStratFutMultiTZ
   end
    
   methods
       function [] = setlowerpoint1(obj,pointin)
           obj.lowerpoint1_ = pointin;
       end
       
       function [] = setlowerpoint2(obj,pointin)
           obj.lowerpoint2_ = pointin;
       end
       
       function [] = setupperpoint1(obj,pointin)
           obj.upperpoint1_ = pointin;
       end
       
       function [] = setupperpoint2(obj,pointin)
           obj.upperpoint2_ = pointin;
       end
       
       [] = registerinstrument(obj,instrument)
       lowerboundary = getlowerboundary(obj,t)
       upperboundary = getupperboundary(obj,t)
       [] = drawlowerboundaries(obj)
       [] = drawupperboundaries(obj)
   end
   
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_futsingletz;
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_futsingletz(signals)
        end
        %end of autoplacenewentrusts
        
        function [] = updategreeks(obj)
            obj.updategreeks_futsingletz
        end
            
        function [] = riskmanagement(obj,dtnum)
            obj.riskmanagement_futsingletz(dtnum)
        end
        
        function [] = initdata(obj)
            obj.initdata_futsingletz;
        end
        %end of initdata
        
    end
    
    methods (Access = private)
        [] = riskmanagement_futsingletz(obj,dtnum)
        [] = updategreeks_futsingletz(obj)
        signals = gensignals_futsingletz(obj)
        [] = autoplacenewentrusts_futsingletz(obj,signals)
        [] = initdata_futsingletz(obj)
    end
end