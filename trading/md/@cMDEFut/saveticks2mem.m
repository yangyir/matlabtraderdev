function [] = saveticks2mem(mdefut)
    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    
%     if strcmpi(mdefut.mode_,'replay') && ns ~= 1
%         error('cMDEFut:saveticks2mem:only single instrument is supported in replay mode');
%     end
    
    if strcmpi(mdefut.mode_,'realtime') || strcmpi(mdefut.mode_,'demo')
        qs = mdefut.qms_.getquote;
%         for i = 1:ns
%             count = mdefut.ticks_count_(i)+1;
%             mdefut.ticks_{i}(count,1) = qs{i}.update_time1;
%             mdefut.ticks_{i}(count,2) = qs{i}.bid1;
%             mdefut.ticks_{i}(count,3) = qs{i}.ask1;
%             mdefut.ticks_{i}(count,4) = qs{i}.last_trade;
%             if ~isempty(qs{i}.yield_last_trade)
%                 mdefut.ticks_{i}(count,5) = qs{i}.yield_last_trade;
%                 mdefut.ticks_{i}(count,6) = qs{i}.yield_bid1;
%                 mdefut.ticks_{i}(count,7) = qs{i}.yield_ask1;
%             end
%             mdefut.ticks_count_(i) = count;
%         end
        %
        for i = 1:ns
            count = mdefut.ticks_count_(i)+1;
            mdefut.ticksquick_(i,1) = qs{i}.update_time1;
            mdefut.ticksquick_(i,2) = qs{i}.bid1;
            mdefut.ticksquick_(i,3) = qs{i}.ask1;
            mdefut.ticksquick_(i,4) = qs{i}.last_trade;
            if ~isa(qs{i},'cQuoteStock')
                if ~isempty(qs{i}.yield_last_trade)
                    mdefut.ticksquick_(i,5) = qs{i}.yield_last_trade;
                    mdefut.ticksquick_(i,6) = qs{i}.yield_bid1;
                    mdefut.ticksquick_(i,7) = qs{i}.yield_ask1;
                end
            end
            mdefut.ticks_count_(i) = count;
        end
    elseif strcmpi(mdefut.mode_,'replay')
%         %old style in case only 1 single instrument is allowed in replay
%         mode
%         count = mdefut.ticks_count_(1)+1;
%         mdefut.ticks_{1}(count,1) = mdefut.replayer_.tickdata_{1}(mdefut.replay_count_,1);
%         mdefut.ticks_{1}(count,2) = mdefut.replayer_.tickdata_{1}(mdefut.replay_count_,2);
%         mdefut.ticks_{1}(count,3) = mdefut.replayer_.tickdata_{1}(mdefut.replay_count_,2);
%         mdefut.ticks_{1}(count,4) = mdefut.replayer_.tickdata_{1}(mdefut.replay_count_,2);
%         mdefut.ticks_count_(1) = count;
%         for i = 1:ns
%             idx = mdefut.replay_idx_(i);
%             if idx == 0, continue; end
%             count = mdefut.ticks_count_(i) + 1;
%             mdefut.ticks_{i}(count,1) = mdefut.replayer_.tickdata_{i}(idx,1);
%             mdefut.ticks_{i}(count,2:4) = mdefut.replayer_.tickdata_{i}(idx,2);
%             mdefut.ticks_count_(i) = count;
%         end
        %
        for i = 1:ns
            idx = mdefut.replay_idx_(i);
            if idx == 0, continue; end
            count = mdefut.ticks_count_(i) + 1;
            mdefut.ticksquick_(i,1) = mdefut.replayer_.tickdata_{i}(idx,1);
            mdefut.ticksquick_(i,2:4) = mdefut.replayer_.tickdata_{i}(idx,2);
            mdefut.ticks_count_(i) = count;
        end
    end
end
%end of saveticks2mem