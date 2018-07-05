function [] = riskmanagement_futbatman(obj,dtnum)
%cStratFutBatman
    if isempty(obj.counter_) && ~strcmpi(obj.mode_,'debug'), return;end
    
    instruments = obj.instruments_.getinstrument;
    for i = 1:obj.count
        %firstly to check whether this is in trading hours
        ismarketopen = istrading(dtnum,instruments{i}.trading_hours,...
            'tradingbreak',instruments{i}.trading_break);
        if ~ismarketopen, continue; end
        
        %secondly to check whether the instrument has been traded
        [isinstrumenttraded,idx] = obj.bookrunning_.hasposition(instruments{i});
        if ~isinstrumenttraded, continue; end
        
        pos = obj.bookrunning_.positions_{idx};
        if pos.position_total_ == 0, return; end
        direction = pos.direction_;
        
        %if it is traded but pxopen_ is not set, we automatically set the
        %open price to the position open price
        if obj.pxopen_(i) == -1 
            obj.pxopen_(i) = pos.cost_open_;
            if direction == 1
                if obj.pxhigh_(i) == -1, obj.pxhigh_(i) = inf; end
                if obj.pxstoploss_(i) == -1, obj.pxstoploss_(i) = -inf;end
                if obj.pxtarget_(i) == -1, obj.pxtarget_(i) = inf;end
            else
                if obj.pxhigh_(i) == -1, obj.pxhigh_(i) = -inf;end
                if obj.pxstoploss_(i) == -1, obj.pxstoploss_(i) = inf;end
                if obj.pxtarget_(i) == -1, obj.pxtarget_(i) = -inf;end
            end
            obj.doublecheck_(i) = 0;
            return
        end
        
        tick = obj.mde_fut_.getlasttick(instruments{i});
        lasttrade = tick(4);
        %first time to set withdrawmin and withdrawmax
        if (obj.pxwithdrawmin_(i) == -1 && obj.pxwithdrawmax_(i) == -1)
           if direction == 1
               if lasttrade >= obj.pxtarget_(i)
                    obj.pxhigh_(i) = lasttrade;
                    obj.pxwithdrawmin_(i) = obj.pxhigh_(i) - (obj.pxhigh_(i)-obj.pxopen_(i))/3;
                    obj.pxwithdrawmax_(i) = obj.pxhigh_(i) - (obj.pxhigh_(i)-obj.pxopen_(i))/2;
                elseif lasttrade < obj.pxtarget_(i) && lasttrade > obj.pxstoploss_(i)
                    %do nothing and wait for the next trade price
                elseif lasttrade <= obj.pxstoploss_(i)
                    obj.unwindposition(instruments{i},0);
                    return
                end
           elseif direction == -1
               if lasttrade <= obj.pxtarget_(i)
                   obj.pxhigh_(i) = lasttrade;
                   obj.pxwithdrawmin_(i) = obj.pxhigh_(i) + (obj.pxopen_(i)-obj.pxhigh_(i))/3;
                   obj.pxwithdrawmax_(i) = obj.pxhigh_(i) + (obj.pxopen_(i)-obj.pxhigh_(i))/2;
               elseif lasttrade > obj.pxtarget_(i) && lasttrade < obj.pxstoploss_(i)
                   %do nothing and wait for the next trade price
               elseif lasttrade >= obj.pxstoploss_(i)
                   obj.unwindposition(instruments{i},0);
                   return
               end
           else
               error('cStratFutBatman:riskmanagement:invalid direction of position')
           end
           %
           obj.doublecheck_(i) = 0;
           return 
        end        
        %    
        %long up-slope trend
        if direction == 1
            if obj.doublecheck_(i) == 0 
                if lasttrade <= obj.pxwithdrawmax_(i)
                    obj.unwindposition(instruments{i},0);
                    obj.doublecheck_(i) = 0;
                    return
                elseif lasttrade >= obj.pxhigh_(i)
                    obj.pxhigh_(i) = lasttrade;
                    obj.pxwithdrawmin_(i) = obj.pxhigh_(i) - (obj.pxhigh_(i)-obj.pxopen_(i))/3;
                    obj.pxwithdrawmax_(i) = obj.pxhigh_(i) - (obj.pxhigh_(i)-obj.pxopen_(i))/2;
                    obj.doublecheck_(i) = 0;
                elseif lasttrade < obj.pxhigh_(i) && lasttrade > obj.pxwithdrawmin_(i)
                    obj.doublecheck_(i) = 0;
                elseif lasttrade <= obj.pxwithdrawmin_(i) && lasttrade > obj.pxwithdrawmax_(i)
                    %indicating the first round of trend is over but we
                    %may have a second trend in case withdrawmax is not
                    %breahed from the top.now we need to update the
                    %open price
                    obj.pxopen_(i) = lasttrade;
                    obj.pxwithdrawmin_(i) = obj.pxhigh_(i) - (obj.pxhigh_(i)-obj.pxopen_(i))/3;
                    obj.pxwithdrawmax_(i) = obj.pxhigh_(i) - (obj.pxhigh_(i)-obj.pxopen_(i))/2;
                    obj.doublecheck_(i) = 1;
                end
            elseif obj.doublecheck_(i) == 1
                if lasttrade <= obj.pxwithdrawmax_(i)
                    obj.unwindposition(instruments{i},0);
                    obj.doublecheck_(i) = 0;
                    return
                elseif lasttrade >= obj.pxhigh_(i)
                    obj.pxhigh_(i) = lasttrade;
                    obj.pxwithdrawmin_(i) = obj.pxhigh_(i) - (obj.pxhigh_(i)-obj.pxopen_(i))/3;
                    obj.pxwithdrawmax_(i) = obj.pxhigh_(i) - (obj.pxhigh_(i)-obj.pxopen_(i))/2;
                    obj.doublecheck_(i) = 0;
                elseif lasttrade <= obj.pxwithdrawmin_(i) && lasttrade > obj.pxwithdrawmax_(i)
                    obj.pxopen_(i) = min(obj.pxopen_(i),lasttrade);
                    obj.pxwithdrawmin_(i) = obj.pxhigh_(i) - (obj.pxhigh_(i)-obj.pxopen_(i))/3;
                    obj.pxwithdrawmax_(i) = obj.pxhigh_(i) - (obj.pxhigh_(i)-obj.pxopen_(i))/2;
                    obj.doublecheck_(i) = 1;
                elseif lasttrade < obj.pxhigh_(i) && lasttrade > obj.pxwithdrawmin_(i)
                    obj.doublecheck_(i) = 1;
                end
            end
            return
        end
        
        
        %short down-slope trend
        if direction == -1
            if obj.doublecheck_(i) == 0 
                if lasttrade >= obj.pxwithdrawmax_(i)
                    obj.unwindposition(instruments{i},0);
                    obj.doublecheck_(i) = 0;
                    return
                elseif lasttrade <= obj.pxhigh_(i)
                    obj.pxhigh_(i) = lasttrade;
                    obj.pxwithdrawmin_(i) = obj.pxhigh_(i) + (obj.pxopen_(i)-obj.pxhigh_(i))/3;
                    obj.pxwithdrawmax_(i) = obj.pxhigh_(i) + (obj.pxopen_(i)-obj.pxhigh_(i))/2;
                    obj.doublecheck_(i) = 0;
                elseif lasttrade > obj.pxhigh_(i) && lasttrade < obj.pxwithdrawmin_(i)
                    obj.doublecheck_(i) = 0;
                elseif lasttrade >= obj.pxwithdrawmin_(i) && lasttrade < obj.pxwithdrawmax_(i)
                    %indicating the first round of trend is over but we
                    %may have a second trend in case withdrawmax is not
                    %breahed from the top.now we need to update the
                    %open price
                    obj.pxopen_(i) = lasttrade;
                    obj.pxwithdrawmin_(i) = obj.pxhigh_(i) + (obj.pxopen_(i)-obj.pxhigh_(i))/3;
                    obj.pxwithdrawmax_(i) = obj.pxhigh_(i) + (obj.pxopen_(i)-obj.pxhigh_(i))/2;
                    obj.doublecheck_(i) = 1;
                end
            elseif obj.doublecheck_(i) == 1
                if lasttrade >= obj.pxwithdrawmax_(i)
                    obj.unwindposition(instruments{i},0);
                    obj.doublecheck_(i) = 0;
                    return
                elseif lasttrade <= obj.pxhigh_(i)
                    obj.pxhigh_(i) = lasttrade;
                    obj.pxwithdrawmin_(i) = obj.pxhigh_(i) + (obj.pxopen_(i)-obj.pxhigh_(i))/3;
                    obj.pxwithdrawmax_(i) = obj.pxhigh_(i) + (obj.pxopen_(i)-obj.pxhigh_(i))/2;
                    obj.doublecheck_(i) = 0;
                elseif lasttrade >= obj.pxwithdrawmin_(i) && lasttrade < obj.pxwithdrawmax_(i)
                    obj.pxopen_(i) = max(obj.pxopen_(i),lasttrade);
                    obj.pxwithdrawmin_(i) = obj.pxhigh_(i) + (obj.pxopen_(i)-obj.pxhigh_(i))/3;
                    obj.pxwithdrawmax_(i) = obj.pxhigh_(i) + (obj.pxopen_(i)-obj.pxhigh_(i))/2;
                    obj.doublecheck_(i) = 1;
                elseif lasttrade > obj.pxhigh_(i) && lasttrade < obj.pxwithdrawmin_(i)
                    obj.doublecheck_(i) = 1;
                end
            end
            return
        end
        %
        %
    end
end