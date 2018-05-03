function [] = refresh(mdefut)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime')
            if mdefut.display_ == 1
                fprintf('%s mdefut runs......\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
            end
            mdefut.qms_.refresh;
        elseif strcmpi(mdefut.mode_,'replay')
            if mdefut.replay_count_ > size(mdefut.replay_datetimevec_,1)
                mdefut.stop;
            end
        end
        %save ticks data into memory
        mdefut.saveticks2mem;
        %save candles data into memory
        mdefut.updatecandleinmem;
        if strcmpi(mdefut.mode_,'replay'), mdefut.replay_count_ = mdefut.replay_count_ + 1;end

    end
end
%end of refresh