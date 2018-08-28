function [] = autoplacenewentrusts_futmultiwrplusbatman(obj,signals)
    if isempty(obj.helper_), error('cStrat::autoplacenewentrusts::missing helper');end
    for i = 1:size(signals,1)
        signal = signals{i};
        %to check whether this is a valid signal
        if isempty(signal), continue; end
        
        %to check whether highest or lowest price is updated
        if signal.checkflag == 0, continue;end
        
        %to check whether the instrument is set with autotrade flag
        instrument = signal.instrument;
        [~,ii] = obj.instruments_.hasinstrument(instrument);
        if ~obj.autotrade_(ii),continue;end
        
        %to check whether position for the instrument exists,
        try
            [flag,idx] = obj.helper_.book_.hasposition(instrument);
        catch
            flag = false;
            idx = 0;
        end
        if ~flag
            volume_exist = 0;
%             direction_exist = 0;
        else
            pos = obj.helper_.book_.positions_{idx};
            volume_exist = pos.position_total_;
%             direction_exist = pos.direction_;
        end
        
        %note:we trade the  base unit volume till the maximum units are
        %breached
        if volume_exist == 0
            volume = obj.getbaseunits(instrument);
        else
            maxvolume = obj.getmaxunits(instrument);
            npending = obj.getbaseunits(instrument);
            volume = max(min(maxvolume-volume_exist,npending),0);            
        end
        
        %note:exit if the maxvolume is breached
        if volume == 0, continue; end
        
        %note:to check wheter we've already executed trades within the
        %bucket and exist the process if so.this is inline with the
        %backtest as we only execute once in every time bucket
%         bucketnum = obj.mde_fut_.getcandlecount(instrument);
%         if bucketnum > 0 && bucketnum == obj.executionbucketnumber_(ii)
%             continue;
%         end
        
        %note:there is a maximum limit of 500 entrust placement/withdrawn. as
        %a result, we try to make sure the same entrust, i.e. same underlier
        %futures, entrust price, volume and direction are not repeatly
        %placed.
        if strcmpi(obj.mode_,'realtime')
            ordertime = now;
        else
            try
                tick = obj.mde_fut_.getlasttick(instrument);
                ordertime = tick(1);
            catch
                ordertime = obj.replay_time1_;
            end
        end
        highestprice = signal.highesthigh;
        lowestprice = signal.lowestlow;
        npending = obj.helper_.entrustspending_.latest;
        place_entrustshort_flag = true;
        place_entrustlong_flag = true;
        
        withdraw_entrustshort_flag = true;
        withdraw_entrustlong_flag = true;
        
        for jj = 1:npending
            e = obj.helper_.entrustspending_.node(jj);
            %existing entrust with the same short direction and price exist
            %
            if (strcmpi(e.instrumentCode,instrument.code_ctp) && ...
                    (e.price == highestprice) && ...
                    (e.direction == -1) && ...
                    (e.volume == abs(volume)))
                withdraw_entrustshort_flag = false;
                place_entrustshort_flag = false;
                break
            end
        end
        
        if withdraw_entrustshort_flag
            %note:we only withdraw open position entrust for the risk
            %management purpose
            obj.withdrawentrusts(instrument,'time',ordertime,'direction',-1,'offset',1);
        end
        
        for jj = 1:npending
            e = obj.helper_.entrustspending_.node(jj);
            %existing entrust with the same short direction and price exist
            %
            if (strcmpi(e.instrumentCode,instrument.code_ctp) && ...
                    (e.price == lowestprice) && ...
                    (e.direction == 1) && ...
                    (e.volume == abs(volume)))
                withdraw_entrustlong_flag = false;
                place_entrustlong_flag = false;
                break
            end
        end
        
        if withdraw_entrustlong_flag
            %note:we only withdraw open position entrust for the risk
            %management purpose
            obj.withdrawentrusts(instrument,'time',ordertime,'direction',1,'offset',1);
        end
           
        if place_entrustshort_flag
            obj.shortopensingleinstrument(instrument.code_ctp,abs(volume),0,...
                'overrideprice',highestprice,'time',ordertime,'signalinfo',signal);
        end
        
        if place_entrustlong_flag
            obj.longopensingleinstrument(instrument.code_ctp,abs(volume),0,...
                'overrideprice',lowestprice,'time',ordertime,'signalinfo',signal);
        end
        
    end
end