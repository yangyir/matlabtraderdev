classdef cBatman < handle
    %note:reference can be found on
    %the batman is used on trade level, rather than position level.
    %Position level is a consolidation of trades of which the same
    %instrument is traded
    %20180605 yangyiran
    properties
        code_@char
        instrument_@cInstrument
        direction_@double
        volume_@double
        pxopen_@double
        pxopenreal_@double
        pxtarget_@double
        pxstoploss_@double
        pxsupportmin_@double    %1st support line
        pxsupportmax_@double    %2nd supprot line
        pxresistence_@double
        dtunwind1_@double
        dtunwind2_@char
        checkflag_@double
        
        %default values
        bandwidthmin_@double = 1/3
        bandwidthmax_@double = 0.5
        bandstoploss_@double = 0.02
        bandtarget_@double = 0.05
        %
        pnlrunning_@double
        pnlclosed_@double
        
        status_@char = 'unset'
        
    end
    
    methods       
        function set.status_(obj,status)
            if strcmpi(status,'unset') || strcmpi(status,'set') ||...
                    strcmpi(status,'closed')
                obj.status_ = status;
            else
                error('cBatman:invalid status')
            end
        end
    end
    
    methods
        [] = update(obj,name,value)
    end
    
    methods (Access = private)
        [] = update_from_mdefut(obj,mdefut)
        [] = update_from_qms(obj,qms)
        [] = update_from_tick(obj,tick)
        [] = update_from_candle(obj,candle)
    end
    
end