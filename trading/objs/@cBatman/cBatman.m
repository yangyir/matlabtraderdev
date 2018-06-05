classdef cBatman < handle
    %note:reference can be found on
    %the batman is used on trade level, rather than position level.
    %Position level is a consolidation of trades of which the same
    %instrument is traded
    %20180605 yangyiran
    properties
        code_@char
        direction_@double
        pxopen_@double
        pxopenreal_@double
        pxtarget_@double
        pxstoploss_@double
        pxwithdrawmin_@double
        pxwithdrawmax_@double
        pxhigh_@double
        datetimelimit1_@double
        datetimelimit2_@char
        checkflag_@double
        
        %default values
        bandwidthmin_@double = 1/3
        bandwidthmax_@double = 0.5
        
        status_@char = 'unset'
        
    end
    
    methods
        function set.direction_(obj,direction)
            if direction == 1 || direction == -1
                obj.direction_ = direction;
            else
                error('cBatman:invalid direction')
            end
        end
        
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
        function [] = update(obj,mdefut)
            if ~isa(mdefut,'cMDEFut')
                error('cBatman:update:invalid mdefut input');
            end
            %1.检查Batman的状态
            if strcmpi(obj.status_,'closed'), return; end
            
            lasttick = mdefut.getlasttick(obj.code_);
            tick_time = lasttick(1);
            %2.检查是否需要时间止损
            if ~isempty(obj.datetimelimit1_) && obj.datetimelimit1_ >= tick_time
                obj.status_ = 'closed';
                return
            end
            %3.check whether Batman is set
            tick_bid = lasttick(2);
            tick_ask = lasttick(3);
            tick_trade = lasttick(4);
            if ~isempty(obj.status_,'unset')
                if obj.direction_ == 1
                    if tick_bid >= obj.pxtarget_
                        obj.status_ = 'set';
                        obj.pxhigh_ = tick_bid;
                        obj.pxwithdrawmin_ = obj.pxhigh_ - (obj.pxhigh_ - obj.pxopen
                    elseif tick_bid < obj.pxtarget_ && tick_bid > obj.pxstoploss_
                        obj.status_ = 'unset';
                    elseif tick_bid <= obj.pxstoploss_
                        obj.status_ = 'closed';
                    end
                elseif obj.direction_ == -1
                end
            end
            
            
           
                
            
            
            
            
            
        end
    end
end