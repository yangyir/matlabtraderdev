function [] = saveticks2mem(mdeopt)
% a cMDEOpt function
    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
        
    if strcmpi(mdeopt.mode_,'realtime') || strcmpi(mdeopt.mode_,'demo')
        qs = mdeopt.qms_.getquote;
        if isempty(qs),return;end
        for i = 1:ns
            if isempty(qs{i}),continue;end
            count = mdeopt.ticks_count_(i) + 1;
            mdeopt.ticksquick_(i,1) = qs{i}.update_time1;
            mdeopt.ticksquick_(i,2) = qs{i}.bid1;
            mdeopt.ticksquick_(i,3) = qs{i}.ask1;
            mdeopt.ticksquick_(i,4) = qs{i}.last_trade;
            if mdeopt.savetick_
                 mdeopt.ticks_{i}(count,1) = qs{i}.update_time1;
                 mdeopt.ticks_{i}(count,2) = qs{i}.last_trade;
            end
            mdeopt.ticks_count_(i) = count;
        end
    elseif strcmpi(mdeopt.mode_,'replay')
        for i = 1:ns
            idx = mdeopt.replay_idx_(i);
            if idx == 0, continue; end
            count = mdeopt.ticks_count_(i) + 1;
            mdeopt.ticksquick_(i,1) = mdeopt.replayer_.tickdata_{i}(idx,1);
            mdeopt.ticksquick_(i,2:4) = mdeopt.replayer_.tickdata_{i}(idx,2);
            mdeopt.ticks_count_(i) = count;
            if mdeopt.savetick_
                mdeopt.ticks_{i}(count,1) = mdeopt.ticksquick_(i,1);
                mdeopt.ticks_{i}(count,2) = mdeopt.ticksquick_(i,4);
            end
        end
    end
end
%end of saveticks2mem