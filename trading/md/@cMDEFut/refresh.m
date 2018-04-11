function [] = refresh(mdefut)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime')
            if mdefut.display_ == 1
                fprintf('%s mdefut runs......\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
            end
            mdefut.qms_.refresh;
        elseif strcmpi(mdefut.mode_,'replay')
            n = min(mdefut.replay_count_,size(mdefut.replay_datetimevec_,1));
            tnum = mdefut.replay_datetimevec_(n);
            if mdefut.display_ == 1
                fprintf('%s mdefut runs......\n',datestr(tnum,'yyyy-mm-dd HH:MM:SS'));
            end
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