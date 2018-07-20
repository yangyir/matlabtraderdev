function [] = refresh(mdefut)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime')
            if mdefut.display_ == 1
                fprintf('%s mdefut runs......\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
            end
            mdefut.qms_.refresh;
        elseif strcmpi(mdefut.mode_,'replay')
            if mdefut.replay_count_ <= size(mdefut.replay_datetimevec_,1)
                if strcmpi(mdefut.status_,'working')
                    this_cnt = mdefut.replay_count_;
                    mdefut.replay_time1_ = mdefut.replay_datetimevec_(this_cnt);
                    mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
                    next_cnt = min(this_cnt + 1,size(mdefut.replay_datetimevec_,1));
                    this_dt = mdefut.replay_datetimevec_(this_cnt);
                    next_dt = mdefut.replay_datetimevec_(next_cnt);
                    this_mm = minute(this_dt) + hour(this_dt)*60;
                    next_mm = minute(next_dt) + hour(next_dt)*60;
                    if (next_mm - this_mm > 180 && (this_mm <= 915 &&this_mm >540)) || ...
                            (this_cnt == next_cnt && (this_mm <= 915 &&this_mm >540))
                        %we can check whether the market is settled with 2
                        %different scenarios
                        %1.the next time point is more than 3 hours
                        %later than the previous
                        %time point(i.e.the market close 2 hours for lunch
                        %break).
                        %2.the datetime vec has moved to the end and the
                        %last date point is before 3:15pm
                        mdefut.status_ = 'sleep';
                    end
                elseif strcmpi(mdefut.status_,'sleep')
                    mm = minute(mdefut.replay_time1_) + 60*hour(mdefut.replay_time1_);
                    %once the mdefut is asleep, it won't wake up until either
                    %09:00pm or 09:00am on the next business date 
                    if (mdefut.iseveningrequired_ && mm < 1260)
                        mdefut.status_ = 'sleep';
                    elseif mm < 540     %09:00am
                        mdefut.status_ = 'sleep';
                    else
                        mdefut.status_ = 'working';
                    end
                    if mdefut.display_ && strcmpi(mdefut.status_,'sleep')
                        fprintf('time:%s; status:%s\n',mdefut.replay_time2_,mdefut.status_);
                    end
                    %in case the mdefut is sleeping, we move the replay
                    %time minute by minute
                    mdefut.replay_time1_ = mdefut.replay_time1_ + 1/60/24;
                    mdefut.replay_time2_ = datestr(mdefut.replay_time1_,'yyyy-mm-dd HH:MM:SS');
                end
            end
            %
            if strcmpi(mdefut.replayer_.mode_,'singleday')
                if mdefut.replay_count_ > size(mdefut.replay_datetimevec_,1)
                    %once all the tick data is passed, we shall just stop
                    %the mdefut
                    if mdefut.candlesaveflag_
                        inst = mdefut.replayer_.instruments_.getinstrument;
                        code = inst{1}.code_ctp;
                        [~,idx2] = mdefut.qms_.instruments_.hasinstrument(code);
                        coldefs = {'datetime','open','high','low','close'};
                        dir_ = [getenv('HOME'),'trading\objs\@cReplayer\'];
                        fn_ = [dir_,code,'_',datestr(mdefut.replay_date1_,'yyyymmdd'),'_1m.txt'];
                        if mdefut.display_ == 1
                            fprintf('save intraday candle of %s on %s...\n',...
                                code,mdefut.replay_date2_);
                        end
                        cDataFileIO.saveDataToTxtFile(fn_,mdefut.candles4save_{idx2},coldefs,'w',true);
                    end
                    %
                    mdefut.stop;
                    fprintf('replay finishes!...\n');
                    return
                end
            elseif strcmpi(mdefut.replayer_.mode_,'multiday')
                if mdefut.replay_count_ > size(mdefut.replay_datetimevec_,1)
                    inst = mdefut.replayer_.instruments_.getinstrument;
                    code = inst{1}.code_ctp;
                    [~,idx] = mdefut.replayer_.instruments_.hasinstrument(code);
                    [~,idx2] = mdefut.qms_.instruments_.hasinstrument(code);
                    if mdefut.candlesaveflag_
                        coldefs = {'datetime','open','high','low','close'};
                        dir_ = [getenv('HOME'),'trading\objs\@cReplayer\'];
                        fn_ = [dir_,code,'_',datestr(mdefut.replay_date1_,'yyyymmdd'),'_1m.txt'];
                        if mdefut.display_ == 1
                            fprintf('save intraday candle of %s on %s...\n',...
                                code,mdefut.replay_date2_);
                        end
                        cDataFileIO.saveDataToTxtFile(fn_,mdefut.candles4save_{idx2},coldefs,'w',true);
                    end
                    %once all the tick data is passed for one business date
                    %in multiday mode, we shall jump to the next business
                    %date
                    %make sure that we are still within the replay date
                    %period,o/w we shall switch off the mdefut.
                    if mdefut.replayer_.multidayidx_ >= size(mdefut.replayer_.multidayfiles_,1)
                         mdefut.stop;
                         fprintf('replay finishes!...\n');
                         return
                    else
                        %todo:here we may extend the replay mode with mutltiple futures
                                                
                        %below we first load tick data for the next business date
                        multidayidx = mdefut.replayer_.multidayidx_;
                        %move to the next business date
                        multidayidx = multidayidx+1;
                        fns = mdefut.replayer_.multidayfiles_;
                        mdefut.replayer_.loadtickdata('code',code,'fn',fns{multidayidx});
                        %
                        mdefut.replay_date1_ = floor(mdefut.replayer_.tickdata_{idx}(1,1));
                        mdefut.replay_date2_ = datestr(mdefut.replay_date1_,'yyyy-mm-dd');
                        mdefut.replay_datetimevec_ = mdefut.replayer_.tickdata_{idx}(:,1);
                        mdefut.replay_count_ = 1;
                        %
%                         if ~isempty(mdefut.hist_candles_)
%                             %in case historical candles are required, we
%                             %update the historical candles as well
%                             histcandles = mdefut.hist_candles_{idx2};
%                             candles = mdefut.candles_{idx2};
%                             ncandle = size(candles,1);
%                             %here we move the historical candle one day
%                             %forward to save memory usage
%                             histcandles = [histcandles(ncandle+1:end,:);candles];
%                             mdefut.hist_candles_{idx2} = histcandles;
%                         end
%                         %
%                         instruments = mdefut.qms_.instruments_.getinstrument;
%                         %update candle_ and candle4save_ in mdefut
%                         buckets = getintradaybuckets2('date',mdefut.replay_date1_,...
%                             'frequency',[num2str(mdefut.candle_freq_(idx2)),'m'],...
%                             'tradinghours',instruments{idx2}.trading_hours,...
%                             'tradingbreak',instruments{idx2}.trading_break);
%                         candle_ = [buckets,zeros(size(buckets,1),4)];
%                         mdefut.candles_{idx2} = candle_;
%                         
%                         buckets = getintradaybuckets2('date',mdefut.replay_date1_,...
%                             'frequency','1m',...
%                             'tradinghours',instruments{idx2}.trading_hours,...
%                             'tradingbreak',instruments{idx2}.trading_break);
%                         candle_ = [buckets,zeros(size(buckets,1),4)];
%                         mdefut.candles4save_{idx2} = candle_;
%                         mdefut.replayer_.multidayidx_ = multidayidx;
                        mdefut.move2cobdate(mdefut.replay_date1_);
                        mdefut.replayer_.multidayidx_ = multidayidx;
                        %
                    end
                end
            end
            if mdefut.display_ == 1 && mdefut.replay_count_ == 1
                fprintf('replay date now: %s\n',mdefut.replay_date2_);
%                 fprintf('candles date vector:\n');
%                 display(datestr(mdefut.candles_{1}(:,1)))
%                 fprintf('\n');
            end
        end
        %
        %save ticks data into memory
        mdefut.saveticks2mem;
        %save candles data into memory
%         mdefut.newset_ = mdefut.updatecandleinmem_sunq;
        mdefut.updatecandleinmem;
         %
        if strcmpi(mdefut.mode_,'replay') && strcmpi(mdefut.status_,'working') 
            mdefut.replay_count_ = mdefut.replay_count_ + 1;
        end
    end
end
%end of refresh