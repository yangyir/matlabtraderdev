function [] = refreshreplaymode(mdeopt)
% a cMDEOpt function
    try
        if strcmpi(mdeopt.replayer_.mode_,'singleday')
            if mdeopt.replay_count_ == size(mdeopt.replay_datetimevec_,1) &&...
                    isempty(mdeopt.ticks_) && ...
                    isempty(mdeopt.candles4save_)
                mdeopt.stop;
                return
            end
        end
    catch e
        fprintf('cMDEOpt:refreshreplaymode:error in replay with singleday mode:%s\n',e.message);
        return
    end
    %
    %
    if mdeopt.printflag_ && mdeopt.replay_count_ == 1
        fprintf('replay date now: %s\n',mdeopt.replay_date2_);
    end
    %
    %
    ismarketopen = mdeopt.ismarketopen('time',mdeopt.replay_time1_);
    
    if ismarketopen
        instruments = mdeopt.qms_.instruments_.getinstrument;
        ns = size(instruments,1);
        idx = cell(ns,1);
        this_second = mdeopt.replay_datetimevec_(mdeopt.replay_count_);
        maxidxsize = 0;
        for i = 1:ns
            tick_timevec = mdeopt.replayer_.ticktimevec_{i};
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
            maxidxsize = 2;
        end
        
        if maxidxsize == 1
            mdeopt.replay_updatetime_ = true;
            for i = 1:ns
                try
                    mdeopt.replay_idx_(i) = idx{i}(1);
                catch
                    mdeopt.replay_idx_(i) = 0;
                end
            end
            mdeopt.saveticks2mem;
            mdeopt.updatecandleinmem;
            %
            mdeopt.replay_count_ = mdeopt.replay_count_ + 1;
            mdeopt.replay_time1_ = mdeopt.replay_date1_ + mdeopt.replay_datetimevec_(mdeopt.replay_count_)/86400;
            mdeopt.replay_time2_ = datestr(mdeopt.replay_time1_,'yyyy-mm-dd HH:MM:SS');
            return
        end
        
        if maxidxsize == 2 && mdeopt.replay_updatetime_
            mdeopt.replay_updatetime_ = false;
            for i = 1:ns
                try
                    mdeopt.replay_idx_(i) = idx{i}(1);
                catch
                    mdeopt.replay_idx_(i) = 0;
                end
            end
            mdeopt.saveticks2mem;
            mdeopt.updatecandleinmem;
            return
        end
        
        if maxidxsize == 2 && ~mdeopt.replay_updatetime_
            mdeopt.replay_updatetime_ = true;
            for i = 1:ns
                try
                    mdeopt.replay_idx_(i) = idx{i}(2);
                catch
                    mdeopt.replay_idx_(i) = 0;
                end
            end
            mdeopt.saveticks2mem;
            mdeopt.updatecandleinmem;
            %
            mdeopt.replay_count_ = mdeopt.replay_count_ + 1;
            mdeopt.replay_time1_ = mdeopt.replay_date1_ + mdeopt.replay_datetimevec_(mdeopt.replay_count_)/86400;
            mdeopt.replay_time2_ = datestr(mdeopt.replay_time1_,'yyyy-mm-dd HH:MM:SS');
            return
        end
               

        mdeopt.replay_count_ = mdeopt.replay_count_ + 1;
        mdeopt.replay_time1_ = mdeopt.replay_date1_ + mdeopt.replay_datetimevec_(mdeopt.replay_count_)/86400;
        mdeopt.replay_time2_ = datestr(mdeopt.replay_time1_,'yyyy-mm-dd HH:MM:SS');
    else
        minuteinday = 60*hour(mdeopt.replay_time1_) + minute(mdeopt.replay_time1_);
        %note:we just need to move forward every second 1 minute before the
        %evening market open, i.e. 20:59pm to 21:00pm
        if (minuteinday >= 1259 && minuteinday <= 1260)
            mdeopt.replay_count_ = mdeopt.replay_count_ + 1;
        else
            mdeopt.replay_count_ = mdeopt.replay_count_ + 60;
        end
        
        if mdeopt.replay_count_ <= size(mdeopt.replay_datetimevec_,1)
            mdeopt.replay_time1_ = mdeopt.replay_date1_ + mdeopt.replay_datetimevec_(mdeopt.replay_count_)/86400;
        else
            mdeopt.replay_time1_ = mdeopt.replay_time1_ + 1/1440;
        end
        mdeopt.replay_time2_ = datestr(mdeopt.replay_time1_,'yyyy-mm-dd HH:MM:SS');
    end
            
end