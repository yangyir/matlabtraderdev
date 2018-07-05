classdef cStratFutBatman < cStrat
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
    
    properties
        pxopen_@double
        pxhigh_@double
        pxstoploss_@double
        pxtarget_@double
        pxwithdrawmin_@double
        pxwithdrawmax_@double
        doublecheck_@double
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
%             obj.riskmanagement_futbatman(dtnum)
            obj.riskmanagement_futbatman_sunq(dtnum)
        end
        
        function [] = initdata(obj)
            obj.initdata_futbatman;
        end
        %end of initdata
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        [] = setpxopen(obj,instrument,val)
        [] = setpxhigh(obj,instrument,val)
        [] = setpxstoploss(obj,instrument,val)
        [] = setpxtarget(obj,instrument,val)
        [] = setpxwithdrawmin(obj,instrument,val)
        [] = setpxwithdrawmax(obj,instrument,val)
        %
        val = getpxopen(obj,instrument)
        val = getpxhigh(obj,instrument)
        val = getpxstoploss(obj,instrument)
        val = getpxtarget(obj,instrument)
        val = getpxwithdrawmin(obj,instrument)
        val = getpxwithdrawmax(obj,instrument)
        
    end
    
    methods (Access = private)
        [] = riskmanagement_futbatman(obj,dtnum)
        [] = riskmanagement_futbatman_sunq(obj,dtnum)
        [] = updategreeks_futbatman(obj)
        signals = gensignals_futbatman(obj)
        [] = autoplacenewentrusts_futbatman(obj,signals)
        [] = initdata_futbatman(obj)
    end
    
    methods (Static = true)
        [] = replay(~)
    end
    
end