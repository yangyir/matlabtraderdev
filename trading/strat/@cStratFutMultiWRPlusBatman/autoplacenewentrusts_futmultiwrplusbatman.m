function [] = autoplacenewentrusts_futmultiwrplusbatman(obj,signals)
%     error('cStratFutMultiWRPlusBatman:autoplacenewentrusts_futmultiwrplusbatman:not implemented')
    for i = 1:size(signals,1)
        signal = signals{i};
        %firstly to check whether there is a valid signal
        if isempty(signal), continue; end

        %secondly to check whether the instrument is registed with the
        %obj itself
        instrument = signal.instrument;
        [~,ii] = obj.instruments_.hasinstrument(instrument);
        if ~obj.autotrade_(ii),continue;end
        
        %third to check whether the signal is unnatural
        direction = signal.direction;
        if direction == 0, continue; end
        
        %fourth to check whether the instrument has been traded or not,
        %i.e. there is an existing position
        [flag,idx] = obj.bookrunning_.hasposition(instrument);
        if ~flag
            volume_exist = 0;
            direction_exist = 0;
        else
            pos = obj.bookrunning_.positions_{idx};
            volume_exist = pos.position_total_;
            direction_exist = pos.direction_;
        end
        
        %note:in case the exist positions are with the different direction
        %as of the signal, we shall first unwind the existing position and
        %then open up position with the new direction
        %maybe some todo here, i am not sure
        unwind_count = 0;
        while direction_exist * direction < 0
            %try to unwind the position
            obj.unwindposition(instrument,unwind_count);
            %update the position and direction
            pos = obj.bookrunning_.positions_{idx};
            volume_exist = pos.position_total_;
            direction_exist = pos.direction_;
            unwind_count = unwind_count + 1;
        end

        %note:in case there is no existing position, we would trade the
        %base units. o/w, the execution methodology is specified
        if volume_exist == 0
            volume = obj.getbaseunits(instrument);
        else
            maxvolume = obj.getmaxunits(instrument);
            n = obj.getbaseunits(instrument);
            volume = max(min(maxvolume-volume_exist,n),0);            
        end

        %note:exit if the maxvolume is breached
        if volume == 0, continue;end
        
        %check wheter we've already executed trades within the
        %bucket and if so check whether the maximum executed number
        %is breached or not
        bucketnum = obj.mde_fut_.getcandlecount(instrument);
        if bucketnum > 0 && bucketnum == obj.executionbucketnumber_(ii);
            if obj.executionperbucket_(ii) >=  obj.maxexecutionperbucket_(ii)
                %note: if the maximum execution time is reached we
                %won't open up new positions for this bucket
                continue;
            end
        end
        
        %note:there is a maximum limit of 500 entrust placement/withdrawn. as
        %a result, we try to make sure the same entrust, i.e. same underlier
        %futures, entrust price, volume and direction are not repeatly
        %placed.
        if strcmpi(obj.mode_,'realtime')
            q = obj.mde_fut_.qms_.getquote(instrument.code_ctp);
            if direction < 0
                price = q.bid1 + obj.bidspread_(ii)*instrument.tick_size;
            else
                price = q.ask1 - obj.askspread_(ii)*instrument.tick_size;
            end
            ordertime = now;
        else
            tick = obj.mde_fut_.getlasttick(instrument);
            bid = tick(2);
            ask = tick(3);
            if direction < 0
                price =  bid + obj.bidspread_(ii)*instrument.tick_size;
            else
                price =  ask - obj.askspread_(ii)*instrument.tick_size;
            end
            ordertime = tick(1);
        end
        withdraw_flag = true;
        n = obj.helper_.entrustspending_.latest;
        for jj = 1:n
            e = obj.helper_.entrustspending_.node(jj);
            f1 = strcmpi(e.instrumentCode,instrument.code_ctp);
            f2 = e.price == price;
            f3 = e.volume == abs(volume);
            if f1&&f2&&f3
                withdraw_flag = false;
                break
            end
        end
        
        %if withdraw is needed
        %firstly to unwind all existing entrusts associated with
        %the instrument
        if withdraw_flag, obj.withdrawentrusts(instrument); end
                
        if direction < 0
            obj.shortopensingleinstrument(instrument.code_ctp,abs(volume),0,...
                'overrideprice',price,'time',ordertime);
        else
            obj.longopensingleinstrument(instrument.code_ctp,abs(volume),0,...
                'overrideprice',price,'time',ordertime);
        end
        
    end
end