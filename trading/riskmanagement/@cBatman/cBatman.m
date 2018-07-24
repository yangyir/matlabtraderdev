classdef cBatman < cTradeRiskManager
    %note:reference can be found on
    %the batman is used on trade level, rather than position level.
    %Position level is a consolidation of trades of which the same
    %instrument is traded
    %20180605 yangyiran
    %20180724 yangyiran;derive this class from cTradeRiskManager
    
    %todo:the following properities might be private as they are set within
    %the riskmanagment process
    properties
        pxsupportmin_@double    %1st support line
        pxsupportmax_@double    %2nd supprot line
        pxresistence_@double
        checkflag_@double
        pxdynamicopen_@double
    end
        
    properties
        %default values
        bandwidthmin_@double = 1/3
        bandwidthmax_@double = 0.5
        bandstoploss_@double = 0.01
        bandtarget_@double = 0.01
    end
    
    methods
        function obj = cBatman
            obj.name_ = 'batman';
        end
    end

    
    methods
        [] = riskmanagement(obj,varargin)
        [] = update(obj,varargin)
        [] = settargetfromsignalinfo(obj,signalinfo)
        [] = setstoplossfromsignalinfo(obj,signalinfo)
        [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
        [unwindtrade] = riskmanagementwithtick(obj,tick,varargin)
    end
    
    methods (Access = private)
        [] = update_from_mdefut(obj,mdefut)
        [] = update_from_qms(obj,qms)
        [] = update_from_tick(obj,tick)
        [] = update_from_candle(obj,candle)
    end
    
end