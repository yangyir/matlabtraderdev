function [] = update_from_candle(obj,candle)
    if strcmpi(obj.status_,'closed'), return; end
    candle_time = candle(1);
    candle_high = candle(3);
    candle_low = candle(4);
    candle_close = candle(5);
    
    %1.检查是否需要时间止损
    if ~isempty(obj.dtunwind1_) && obj.dtunwind1_ >= candle_time
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        return
    end
    %2.check whether Batman is set
    if strcmpi(obj.status_,'unset')
        if obj.direction_ == 1
            if candle_close >= obj.pxtarget_
                obj.status_ = 'set';
                obj.pxresistence_ = candle_close;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candle_close < obj.pxtarget_ && candle_close > obj.pxstoploss_
                obj.status_ = 'unset';
                obj.checkflag_ = 1;
            elseif candle_low <= obj.pxstoploss_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
            end
        elseif obj.direction_ == -1
            if candle_close <= obj.pxtarget_
                obj.status_ = 'set';
                obj.pxresistence_ = candle_close;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candle_close > obj.pxtarget_ && candle_close < obj.pxstoploss_
                obj.status_ = 'unset';
                obj.checkflag_ = 1;
            elseif candle_high >= obj.pxstoploss_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
            end
        end
    elseif strcmpi(obj.status_,'set')
        if obj.checkflag_ == 2 && obj.direction_ == 1
            if candle_low <= obj.pxstoploss_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                return
            elseif candle_close <= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                return
            elseif candle_close >= obj.pxresistence_
                obj.pxresistence_ = candle_close;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candle_close < obj.pxresistence_ && candle_close > obj.pxsupportmin_
                obj.checkflag_ = 2;
            elseif candle_close <= obj.pxsupportmin_ && candle_close > obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case pxsupportmax is not
                %breahed from the top.now we need to update the
                %open price
                obj.pxopen_ = candle_close;
                obj.checkflag_ = 3;
            end
        elseif obj.checkflag_ == 2 && obj.direction_ == -1
            if candle_high >= obj.pxstoploss_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                return
            elseif candle_close >= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                return
            elseif candle_close <= obj.pxresistence_
                obj.pxresistence_ = candle_close;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candle_close > obj.pxresistence_ && candle_close < obj.pxsupportmin_
                obj.checkflag_ = 2;
            elseif candle_close >= obj.pxsupportmin_ && candle_close < obj.pxsupportmax_
                obj.pxopen_ = candle_close;
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from below.now we need to update the
                %open price
                obj.checkflag_ = 3;
            end
        elseif obj.checkflag_ == 3 && obj.direction_ == 1
            if candle_low <= obj.pxstoploss_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                return
            elseif candle_close <= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
            elseif candle_close >= obj.pxresistence_
                obj.pxresistence_ = candle_close;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candle_close < obj.pxresistence_ && candle_close > obj.pxsupportmin_
                obj.checkflag_ = 3;
            elseif candle_close <= obj.pxsupportmin_ && candle_close > obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from the top.now we need to update the
                %open price
                obj.pxopen_ = min(obj.pxopen_,candle_close);
                obj.checkflag_ = 3;
            end
        elseif obj.checkflag_ == 3 && obj.direction_ == -1
            if candle_high >= obj.stoploss__
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                return
            elseif candle_close >= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                return
            elseif candle_close <= obj.pxresistence_
                obj.pxresistence_ = candle_close;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candle_close > obj.pxresistence_ && candle_close < obj.pxsupportmin_
                obj.checkflag_ = 3;
            elseif candle_close >= obj.pxsupportmin_ && candle_close < obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from below.now we need to update the
                %open price
                obj.pxopen_ = max(obj.pxopen_,candle_close);
                obj.checkflag_ = 3;
            end
        else
            error('cBatman:update:internal error')
        end
    end
end