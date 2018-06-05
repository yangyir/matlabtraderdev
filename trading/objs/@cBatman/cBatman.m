classdef cBatman < handle
    %the batman is used on trade level, rather than position level.
    %Position level is a consolidation of trades of which the same
    %instrument is traded
    properties
        code_@char
        direction_@double
        pxopen_@double
        pxopenreal_@double
        pxtarget_@double
        pxstoploss_@double
        pxwithdrawmin_@double
        pxwithdrawmax_@double
        datetimelimit1_@double
        datetimelimit2_@char
        checkflag_@double
        
        %default values
        bandwidthmin_@double = 1/3
        bandwidthmax_@double = 0.5
        
        status_@char
        
    end
    
    methods
        function set.direction_(obj,direction)
            if direction == 1 || direction == -1
                obj.direction_ = direction;
            else
                error('cBatmanInfo:invalid direction')
            end
        end
        
        
    end
    
    methods
        function [] = update(obj,mdefut)
            if ~isa(mdefut,'cMDEFut')
                error('cBatman:update:invalid mdefut input');
            end
            
            lasttick = mdefut.getlasttick(obj.code_);
            tick_time = lasttick(1);
            
            %检查是否需要时间止损
            if ~isempty(obj.datetimelimit1_) && obj.datetimelimit1_ >= tick_time
                obj.status_ = 'closed';
                return
            end
            
                
            
            tick_bid = lasttick(2);
            tick_ask = lasttick(3);
            
            
            
        end
    end
end