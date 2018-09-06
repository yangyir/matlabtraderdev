function [] = refresh(mdefut,varargin)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime')
            %refresh qms with the latest market quotes
            mdefut.qms_.refresh;
            %save ticks data into memory
            mdefut.saveticks2mem;
            %save candles data into memory
            mdefut.updatecandleinmem;
        %    
        elseif strcmpi(mdefut.mode_,'replay')
%             mdefut.refreshreplaymode;
            %mote:a new framework of in replay mode instroduces here
            %in case replay_time1_ is within replay_datetimevec_,the replay
            %time moves along the replay_datetimvec_, once the time moves
            %pass the last time point of replay_datetimvec_, we continute
            %the time until the next time point the new market data is
            %loaded
            %also:the following code will move to a seperate function
            try
                if strcmpi(mdefut.replayer_.mode_,'singleday')
                    if mdefut.replay_count_ > size(mdefut.replay_datetimevec_,1) &&...
                            isempty(mdefut.ticks_) && ...
                            isempty(mdefut.candles4save_)
                        mdefut.status_ = 'sleep';
                        mdefut.stop;
                    end
                end
            catch e
                fprintf('cMDEFut:refresh:error in replay with singleday mode:%s\n',e.message);
            end
            
            
            
            if isempty(mdefut.replay_datetimevec_)
                mdefut.replay_time1_ = now;
                mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
                mdefut.replay_date1_ = floor(mdefut.replay_time1_);
                mdefut.replay_date2_ = datestr(mdefut.replay_date1_,'yyyy-mm-dd');
                return
            end
                        
            if mdefut.printflag_ && mdefut.replay_count_ == 1
                fprintf('replay date now: %s\n',mdefut.replay_date2_);
            end
            
            if mdefut.replay_time1_ >= mdefut.replay_datetimevec_(1) && mdefut.replay_time1_ <= mdefut.replay_datetimevec_(end)
                checktime = mdefut.replay_datetimevec_(mdefut.replay_count_);
                if abs(mdefut.replay_time1_- checktime) < 1e-7 || mdefut.replay_time1_ - checktime > 1/2880
                    %the current replay_time1_ is one of the data point of
                    %the replay_datetimevec_
                    this_cnt = mdefut.replay_count_;
                    next_cnt = min(this_cnt + 1,size(mdefut.replay_datetimevec_,1));
                    if this_cnt == next_cnt
                        mdefut.saveticks2mem;
                        mdefut.updatecandleinmem;
                        mdefut.replay_time1_ = mdefut.replay_time1_ + mdefut.print_timeinterval_/86400;
                        mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
                    else
                        this_dt = mdefut.replay_datetimevec_(this_cnt);
                        next_dt = mdefut.replay_datetimevec_(next_cnt);
                        this_mm = minute(this_dt) + hour(this_dt)*60;
                        next_mm = minute(next_dt) + hour(next_dt)*60;
                        if next_mm - this_mm >= 60
                            mdefut.saveticks2mem;
                            mdefut.updatecandleinmem;
                            mdefut.replay_time1_ = mdefut.replay_time1_ + mdefut.print_timeinterval_/86400;
                            %move to the next point
                            mdefut.replay_count_ = mdefut.replay_count_ + 1;
                        else
                            mdefut.saveticks2mem;
                            mdefut.updatecandleinmem;
                            mdefut.replay_count_ = mdefut.replay_count_ + 1;
                            mdefut.replay_time1_ = mdefut.replay_datetimevec_(mdefut.replay_count_);
                        end
                        mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
                    end
                else
                    %the current replay_time1_ is not one of the data point
                    %of the replay_datetimevec_
                    mdefut.replay_time1_ = mdefut.replay_time1_ + mdefut.print_timeinterval_/86400;
                    mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
                end
            else
                mdefut.replay_time1_ = mdefut.replay_time1_ + mdefut.print_timeinterval_/86400;
                mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
            end
            
        end
    end
end
%end of refresh