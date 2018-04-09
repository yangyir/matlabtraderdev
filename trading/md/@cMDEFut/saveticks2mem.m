function [] = saveticks2mem(mdefut)
    if ~strcmpi(mdefut.mode_,'debug')
        qs = mdefut.qms_.getquote;
        ns = size(mdefut.ticks_,1);
        for i = 1:ns
            count = mdefut.ticks_count_(i)+1;
            mdefut.ticks_{i}(count,1) = qs{i}.update_time1;
            mdefut.ticks_{i}(count,2) = qs{i}.bid1;
            mdefut.ticks_{i}(count,3) = qs{i}.ask1;
            mdefut.ticks_{i}(count,4) = qs{i}.last_trade;
            if ~isempty(qs{i}.yield_last_trade)
                mdefut.ticks_{i}(count,5) = qs{i}.yield_last_trade;
                mdefut.ticks_{i}(count,6) = qs{i}.yield_bid1;
                mdefut.ticks_{i}(count,7) = qs{i}.yield_ask1;
            end
            mdefut.ticks_count_(i) = count;
        end
    else
        ns = size(mdefut.ticks_,1);
        if ns ~= 1
            error('only single instrument is supported in debug mode')
        end
        count = mdefut.ticks_count_(1)+1;
        mdefut.ticks_{1}(count,1) = mdefut.debug_ticks_(mdefut.debug_count_,1);
        mdefut.ticks_{1}(count,2) = mdefut.debug_ticks_(mdefut.debug_count_,2);
        mdefut.ticks_{1}(count,3) = mdefut.debug_ticks_(mdefut.debug_count_,2);
        mdefut.ticks_{1}(count,4) = mdefut.debug_ticks_(mdefut.debug_count_,2);
        mdefut.ticks_count_(1) = count;
    end
end
%end of saveticks2mem