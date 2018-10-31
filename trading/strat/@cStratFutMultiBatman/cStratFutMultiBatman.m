classdef cStratFutMultiBatman < cStrat
    %note:BATMAN is a very simple trend-following strategy
    %firstly it opens a trade with either long/short direction, and
    %specifying a stoploss to prevent unexpected loss
    %secondly it keeps updating the highest/lowest prices and then it
    %updates the new open and new stoploss accordingly
    
    %note:once open a trade with either long/short position at pxPosOpen
    %pxPosStopLoss and pxPosTarget are given at the same time. 
    %pxPosStopLoss is for risk-management purposes and 
    %pxPosTarget is used for checking whether there exists a trend
    %schedule and steps:
    %for a pre-specified trading frequency, we record the close price p at
    %the end of each period and we follow the routine as the following:
    %take the long trend for example
    %step 1:
    %a.if p >= pxPosTarget (indicating the upward trend exists)
    %           high = p
    %           pxWithdrawMin = high - (high-pxPosOpen)/3
    %           pxWithdrawMax = high - (high-pxPosOpen)/2
    %b.if p <= pxPosStopLoss
    %           unwind existing position
    %c.if p > pxPosStopLoss && p < pxPosTarget
    %           do nothing and wait for the next close price
    %step 2:
    %if condition a in step 1 holds and we update p with the latest p
    %a.if p <= pxWithdrawMax
    %           unwind existing position
    %b.if p > high
    %           high = p
    %           pxWithdrawMin = high - (high-pxPosOpen)/3
    %           pxWithdrawMax = high - (high-pxPosOpen)/2
    %c.if p < pxWithdrawMin && p > pxWithdrawMax (indicating the first
    %trending move ends but we might have a next round)
    %           pxPosOpen = p(update pxPosOpen)
    %           pxWithdrawMin & pxWithdrawMax keeps the same
    %d. if p >= pxWithdawMin && p <= high
    %           do nothing and wait for the next close price
    
    methods
        function obj = cStratFutMultiBatman
            obj.name_ = 'stratfutmultibatman';
        end
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_futmultibatman;
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_futmultibatman(signals)
        end
        %end of autoplacenewentrusts
        
        function [] = updategreeks(obj)
            obj.updategreeks_futmultibatman
        end
            
        function [] = riskmanagement(obj,dtnum)
            obj.riskmanagement_futmultibatman(dtnum)
        end
        
        function [] = initdata(obj)
            obj.initdata_futmultibatman;
        end
        %end of initdata
    end
    
    methods
        [ret,e] = placeentrust(obj,instrument,varargin)
        
    end
    
    methods (Access = private)
        [] = riskmanagement_futmultibatman(obj,dtnum)
        [] = updategreeks_futmultibatman(obj)
        signals = gensignals_futmultibatman(obj)
        [] = autoplacenewentrusts_futmultibatman(obj,signals)
        [] = initdata_futmultibatman(obj)
    end
    
end