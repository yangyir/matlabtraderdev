function [] = refreshreplaymode2(mdefut)
    try
        if strcmpi(mdefut.replayer_.mode_,'singleday')
            if mdefut.replay_count_ == size(mdefut.replay_datetimevec_,1) &&...
                    isempty(mdefut.ticks_) && ...
                    isempty(mdefut.candles4save_)
                mdefut.stop;
                return
            end
        end
    catch e
        fprintf('cMDEFut:refresh:error in replay with singleday mode:%s\n',e.message);
        return
    end
    %
    %
    if mdefut.printflag_ && mdefut.replay_count_ == 1
        fprintf('replay date now: %s\n',mdefut.replay_date2_);
    end
    %
    %
    ismarketopen = sum(mdefut.ismarketopen('time',mdefut.replay_time1_));
    
    if ismarketopen
        instruments = mdefut.qms_.instruments_.getinstrument;
        ns = size(instruments,1);
        idx = cell(ns,1);
        this_second = mdefut.replay_datetimevec_(mdefut.replay_count_);
        maxidxsize = 0;
        for i = 1:ns
            tick_timevec = mdefut.replayer_.ticktimevec_{i};
            idx{i} = find(tick_timevec == this_second);
            if i == 1
                maxidxsize = size(idx{i},1);
            else
                this_size = size(idx{i},1);
                if this_size > maxidxsize
                    maxidxsize = this_size;
                end
            end
        end
        if maxidxsize > 2
%             error('cMDEFut:refreshreplaymode2:internal error')
            maxidxsize = 2;
        end
        
        if maxidxsize == 1
            mdefut.replay_updatetime_ = true;
            for i = 1:ns
                try
                    mdefut.replay_idx_(i) = idx{i}(1);
                catch
                    mdefut.replay_idx_(i) = 0;
                end
            end
            mdefut.saveticks2mem;
            mdefut.updatecandleinmem;
            %
            mdefut.replay_count_ = mdefut.replay_count_ + 1;
            mdefut.replay_time1_ = mdefut.replay_date1_ + mdefut.replay_datetimevec_(mdefut.replay_count_)/86400;
            mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
            return
        end
        
        if maxidxsize == 2 && mdefut.replay_updatetime_
            mdefut.replay_updatetime_ = false;
            for i = 1:ns
                try
                    mdefut.replay_idx_(i) = idx{i}(1);
                catch
                    mdefut.replay_idx_(i) = 0;
                end
            end
            mdefut.saveticks2mem;
            mdefut.updatecandleinmem;
            return
        end
        
        if maxidxsize == 2 && ~mdefut.replay_updatetime_
            mdefut.replay_updatetime_ = true;
            for i = 1:ns
                try
                    mdefut.replay_idx_(i) = idx{i}(2);
                catch
                    mdefut.replay_idx_(i) = 0;
                end
            end
            mdefut.saveticks2mem;
            mdefut.updatecandleinmem;
            %
            mdefut.replay_count_ = mdefut.replay_count_ + 1;
            mdefut.replay_time1_ = mdefut.replay_date1_ + mdefut.replay_datetimevec_(mdefut.replay_count_)/86400;
            mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
            return
        end
               
%         for j = 1:maxidxsize
%             for i = 1:ns
%                 try
%                     mdefut.replay_idx_(i) = idx{i}(j);
%                 catch
%                     mdefut.replay_idx_(i) = 0;
%                 end
%             end
%             mdefut.saveticks2mem;
%             mdefut.updatecandleinmem;
%         end
%         %
%         %
        mdefut.replay_count_ = mdefut.replay_count_ + 1;
        mdefut.replay_time1_ = mdefut.replay_date1_ + mdefut.replay_datetimevec_(mdefut.replay_count_)/86400;
        mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
    else
%         fprintf('%s\n',mdefut.replay_time2_);
        minuteinday = 60*hour(mdefut.replay_time1_) + minute(mdefut.replay_time1_);
        %note:we just need to move forward every second 1 minute before the
        %evening market open, i.e. 20:59pm to 21:00pm
        if (minuteinday >= 1259 && minuteinday <= 1260)
            mdefut.replay_count_ = mdefut.replay_count_ + 1;
        else
            mdefut.replay_count_ = mdefut.replay_count_ + 60;
        end
        
        if mdefut.replay_count_ <= size(mdefut.replay_datetimevec_,1)
            mdefut.replay_time1_ = mdefut.replay_date1_ + mdefut.replay_datetimevec_(mdefut.replay_count_)/86400;
        else
%             if (minuteinday > 150 && minuteinday < 540) || ...
%                     (minuteinday > 690 && minuteinday < 780) || ...
%                     (minuteinday > 915 && minuteinday < 1260)
                mdefut.replay_time1_ = mdefut.replay_time1_ + mdefut.print_timeinterval_/86400;
%             else
%                 mdefut.replay_time1_ = mdefut.replay_time1_ + 1/86400;
%             end
        end
        mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
    end
            
end