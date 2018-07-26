function [] = autoplacenewentrusts_futmultiwrplusbatman(obj,signals)
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
        [flag,idx] = obj.bookrunning_.hasposition(instrument);
        if ~flag
            volume_exist = 0;
%             direction_exist = 0;
        else
            pos = obj.bookrunning_.positions_{idx};
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
            tick = obj.mde_fut_.getlasttick(instrument);
            ordertime = tick(1);
        end
        highestprice = signal.highestprice;
        lowestprice = signal.lowestprice;
        npending = obj.helper_.entrustspending_.latest;
        withdraw_entrustshort = zeros(npending,1);
        withdraw_entrustlong = zeros(npending,1);
        for jj = 1:npending
            e = obj.helper_.entrustspending_.node(jj);
            f1 = strcmpi(e.instrumentCode,instrument.code_ctp);
            f2 = (e.price == highestprice & e.direction == -1);
            f3 = (e.price == lowestprice & e.direction == 1);
            f4 = e.volume == abs(volume);
            %pending entrust with short direction
            if f1&&f2&&f4
                withdraw_entrustshort(jj) = 0;
            else
                withdraw_entrustshort(jj) = 1;
            end
            %pending entrust with long direction
            if f1&&f3&&f4
                withdraw_entrustlong(jj) = 0;
            else
                withdraw_entrustlong(jj) = 1;
            end
        end
        if sum(sum(withdraw_entrustshort))>0 || sum(sum(withdraw_entrustlong))>0
            %if withdraw is needed unwind all existing entrusts associated with
            %the instrument
            obj.withdrawentrusts(instrument);
        end
               
        obj.shortopensingleinstrument(instrument.code_ctp,abs(volume),0,...
                'overrideprice',highestprice,'time',ordertime);
        
        obj.longopensingleinstrument(instrument.code_ctp,abs(volume),0,...
                'overrideprice',lowestprice,'time',ordertime);
        
    end
end