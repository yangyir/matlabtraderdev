function [] = refresh(mdefut)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime')
            mdefut.qms_.refresh;
        elseif strcmpi(mdefut.mode_,'replay')
            n = min(mdefut.replay_count_,size(mdefut.replay_datetimevec_,1));
            tnum = mdefut.replay_datetimevec_(n);
            mdefut.qms_.refresh(datestr(tnum));
        elseif strcmpi(mdefut.mode_,'debug')
            mdefut.debug_count_ = mdefut.debug_count_ + 1;
        end
        %save ticks data into memory
        mdefut.saveticks2mem;
        %save candles data into memory
        mdefut.updatecandleinmem;

    end
end
%end of refresh