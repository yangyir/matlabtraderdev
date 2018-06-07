function [] = update_from_tick(obj,tick)
    if strcmpi(obj.status_,'closed'), return; end
    tick_time = tick(1);
    %1.检查是否需要时间止损
    if ~isempty(obj.dtunwind1_) && obj.dtunwind1_ >= tick_time
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        return
    end
    %2.check whether Batman is set
    tick_bid = tick(2);
    tick_ask = tick(3);
    if strcmpi(obj.status_,'unset')
        if obj.direction_ == 1
            if tick_bid >= obj.pxtarget_
                obj.status_ = 'set';
                obj.pxresistence_ = tick_bid;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif tick_bid < obj.pxtarget_ && tick_bid > obj.pxstoploss_
                obj.status_ = 'unset';
                obj.checkflag_ = 1;
            elseif tick_bid <= obj.pxstoploss_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
            end
        elseif obj.direction_ == -1
            if tick_ask <= obj.pxtarget_
                obj.status_ = 'set';
                obj.pxresistence_ = tick_ask;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif tick_ask > obj.pxtarget_ && tick_ask < obj.pxstoploss_
                obj.status_ = 'unset';
                obj.checkflag_ = 1;
            elseif tick_ask >= obj.pxstoploss_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
            end
        end
    elseif strcmpi(obj.status_,'set')
        if obj.checkflag_ == 2 && obj.direction_ == 1
            if tick_bid <= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
            elseif tick_bid >= obj.pxresistence_
                obj.pxresistence_ = tick_bid;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif tick_bid < obj.pxresistence_ && tick_bid > obj.pxsupportmin_
                obj.checkflag_ = 2;
            elseif tick_bid <= obj.pxsupportmin_ && tick_bid > obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case pxsupportmax is not
                %breahed from the top.now we need to update the
                %open price
                obj.pxopen_ = tick_ask;
                obj.checkflag_ = 3;
            end
        elseif obj.checkflag_ == 2 && obj.direction_ == -1
            if tick_ask >= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
            elseif tick_ask <= obj.pxresistence_
                obj.pxresistence_ = tick_ask;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif tick_ask > obj.pxresistence_ && tick_ask < obj.pxsupportmin_
                obj.checkflag_ = 2;
            elseif tick_ask >= obj.pxsupportmin_ && tick_ask < obj.pxsupportmax_
                obj.pxopen_ = tick_bid;
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from below.now we need to update the
                %open price
                obj.checkflag_ = 3;
            end
        elseif obj.checkflag_ == 3 && obj.direction_ == 1
            if tick_bid <= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
            elseif tick_bid >= obj.pxresistence_
                obj.pxresistence_ = tick_bid;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif tick_bid < obj.pxresistence_ && tick_bid > obj.pxsupportmin_
                obj.checkflag_ = 3;
            elseif tick_bid <= obj.pxsupportmin_ && tick_bid > obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from the top.now we need to update the
                %open price
                obj.pxopen_ = min(obj.pxopen_,tick_ask);
                obj.checkflag_ = 3;
            end
        elseif obj.checkflag_ == 3 && obj.direction_ == -1
            if tick_ask >= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
            elseif tick_ask <= obj.pxresistence_
                obj.pxresistence_ = tick_ask;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif tick_ask > obj.pxresistence_ && tick_ask < obj.pxsupportmin_
                obj.checkflag_ = 3;
            elseif tick_ask >= obj.pxsupportmin_ && tick_ask < obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from below.now we need to update the
                %open price
                obj.pxopen_ = max(obj.pxopen_,tick_bid);
                obj.checkflag_ = 3;
            end
        else
            error('cBatman:update:internal error')
        end
    end
end