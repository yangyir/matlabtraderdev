function [] = refresh(mdefut)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime')
            if mdefut.display_ == 1
                fprintf('%s mdefut runs......\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
            end
            mdefut.qms_.refresh;
        elseif strcmpi(mdefut.mode_,'replay')
            if strcmpi(mdefut.replayer_.mode_,'singleday')
                if mdefut.replay_count_ > size(mdefut.replay_datetimevec_,1)
                    %once all the tick data is passed, we 
                    mdefut.stop;
                    return
                end
            elseif strcmpi(mdefut.replayer_.mode_,'multiday')
                if mdefut.replay_count_ > size(mdefut.replay_datetimevec_,1)
                    if mdefut.replayer_.multidayidx_ <= size(mdefut.replayer_.multidayfiles_,1)
                        %
                        mdefut.status_ = 'sleep';
                        %
                        multidayidx = mdefut.replayer_.multidayidx_;
                        multidayidx = multidayidx+1;
                        inst = mdefut.replayer_.instruments_.getinstrument;
                        code = inst{1}.code_ctp;
                        fns = mdefut.replayer_.multidayfiles_;
                        mdefut.replayer_.loadtickdata('code',code,'fn',fns{multidayidx});
                        %
                        [~,idx] = mdefut.replayer_.instruments_.hasinstrument(code);
                        mdefut.replay_date1_ = floor(mdefut.replayer_.tickdata_{idx}(1,1));
                        mdefut.replay_date2_ = datestr(mdefut.replay_date1_,'yyyy-mm-dd');
                        mdefut.replay_datetimevec_ = mdefut.replayer_.tickdata_{idx}(:,1);
                        mdefut.replay_count_ = 1;
                        fprintf('replay date moves to %s...\n',mdefut.replay_date2_);
                        %
                        [f2,idx2] = mdefut.qms_.instruments_.hasinstrument(code);
                        if ~f2, error('cMDEFut:initreplayer:code not registered!');end
                        instruments = mdefut.qms_.instruments_.getinstrument;
                        
                        if ~isempty(mdefut.hist_candles_)
                            %in case historical candles are required, we
                            %update the historical candles as well
                            histcandles = mdefut.hist_candles_{idx2};
                            candles = mdefut.candles_{idx2};
                            %todo:maybe the old histcandles shall be cut as
                            %we try to avoid the histcandles grow too bug
                            histcandles = [histcandles;candles];
                            mdefut.hist_candles_{idx2} = histcandles;
                        end
                        
                        if mdefut.candlesaveflag_
                            coldefs = {'datetime','open','high','low','close'};
                            dir_ = [getenv('HOME'),'trading\objs\@cReplayer\'];
                            fn_ = [dir_,code,'_',datestr(mdefut.replay_date1_,'yyyymmdd'),'_1m.txt'];
                            cDataFileIO.saveDataToTxtFile(fn_,mdefut.candles4save_{idx},coldefs,'w',true);
                        end
                        
                        buckets = getintradaybuckets2('date',mdefut.replay_date1_,...
                            'frequency',[num2str(mdefut.candle_freq_(idx2)),'m'],...
                            'tradinghours',instruments{idx2}.trading_hours,...
                            'tradingbreak',instruments{idx2}.trading_break);
                        candle_ = [buckets,zeros(size(buckets,1),4)];
                        mdefut.candles_{idx2} = candle_;
                        
                        buckets = getintradaybuckets2('date',mdefut.replay_date1_,...
                            'frequency','1m',...
                            'tradinghours',instruments{idx2}.trading_hours,...
                            'tradingbreak',instruments{idx2}.trading_break);
                        candle_ = [buckets,zeros(size(buckets,1),4)];
                        mdefut.candles4save_{idx2} = candle_;
                        mdefut.replayer_.multidayidx_ = multidayidx;
                        %
                        mdefut.status_ = 'working';
                        %
                    else
                        mdefut.stop;
                    end
                end
            end
        end
        %save ticks data into memory
        mdefut.saveticks2mem;
        %save candles data into memory
        mdefut.updatecandleinmem;
        %
        if strcmpi(mdefut.mode_,'replay') && strcmpi(mdefut.status_,'working') 
            mdefut.replay_count_ = mdefut.replay_count_ + 1;
        end

    end
end
%end of refresh