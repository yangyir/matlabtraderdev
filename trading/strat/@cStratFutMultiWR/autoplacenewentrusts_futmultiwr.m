function [] = autoplacenewentrusts_futmultiwr(strategy,signals)
    if isempty(strategy.counter_) && ~strcmpi(strategy.mode_,'debug'), return; end

    %now check the signals
    for i = 1:size(signals,1)
        signal = signals{i};
        %firstly to check whether there is a valid signal
        if isempty(signal), continue; end

        %secondly to check whether the instrument is registed with the
        %strategy itself
        instrument = signal.instrument;
        [~,ii] = strategy.instruments_.hasinstrument(instrument);
        if ~strategy.autotrade_(ii),continue;end
        
        %third to check whether the signal is valid
        direction = signal.direction;
        if direction == 0, continue; end

        %fourth to check whether the instrument has been traded or not,
        %i.e. there is an existing position
        [flag,idx] = strategy.portfolio_.hasposition(instrument);
        if ~flag
            volume_exist = 0;
            direction_exist = 0;
        else
            pos = strategy.portfolio_.pos_list{idx};
%             volume_exist = pos.direction_*pos.position_total_;
            volume_exist = pos.position_total_;
            direction_exist = pos.direction_;
        end
        
        %note:in case the exist positions are with the different direction
        %as of the signal, we shall first unwind the existing position and
        %then open up position with the new direction
        unwind_count = 0;
        while direction_exist * direction < 0
            %try to unwind the position
            strategy.unwindposition(instrument,unwind_count);
            %update the position and direction
            pos = strategy.portfolio_.pos_list{idx};
            volume_exist = pos.position_total_;
            direction_exist = pos.direction_;
            unwind_count = unwind_count + 1;
        end

        %note:in case there is no existing position, we would trade the
        %base units. o/w, the execution methodology is specified
        if volume_exist == 0
            volume = strategy.getbaseunits(instrument);
        else
            maxvolume = strategy.getmaxunits(instrument);
            executiontype = strategy.getexecutiontype(instrument);
            if strcmpi(executiontype,'martingale')
                %note:'martingale' execution type means the existing
                %position units are traded every time when the signal is
                %valid
                volume = max(min(maxvolume-volume_exist,volume_exist),0);
            elseif strcmpi(executiontype,'fixed')
                %note:'fixed' execution type means the base units are
                %traded every time when the signal is valid
                n = strategy.getbaseunits(instrument);
                volume = max(min(maxvolume-volume_exist,n),0);
            elseif strcmpi(executiontype,'option')
                error('option execution type not implemented yet')
            end
        end

        %note:exit if the maxvolume is breached
        if volume == 0, continue;end

        %check wheter we've already executed trades within the
        %bucket and if so check whether the maximum executed number
        %is breached or not
        bucketnum = strategy.mde_fut_.getcandlecount(instrument);
        if bucketnum > 0 && bucketnum == strategy.executionbucketnumber_(ii);
            if strategy.executionperbucket_(ii) >=  strategy.maxexecutionperbucket_(ii)
                %note: if the maximum execution time is reached we
                %won't open up new positions for this bucket
                continue;
            end
        end

        if strcmpi(strategy.mode_,'debug')
            offset = 1;
            tick = strategy.mde_fut_.getlasttick(instrument);
            bid = tick(2);
            ask = tick(3);
            if direction < 0
                price =  bid + strategy.bidspread_(ii)*instrument.tick_size;
            else
                price =  ask - strategy.askspread_(ii)*instrument.tick_size;
            end
            if strategy.executionbucketnumber_(ii) ~= bucketnum;
                strategy.executionbucketnumber_(ii) = bucketnum;
                strategy.executionperbucket_(ii) = 1;
            else
                strategy.executionperbucket_(ii) = strategy.executionperbucket_(ii)+1;
            end
%             assuming the entrust is completely filled
            t = cTransaction;
            t.instrument_ = instrument;
            t.price_ = price;
            t.volume_= abs(volume);
            t.direction_ = direction;
            t.offset_ = offset;
            strategy.portfolio_.updateportfolio(t);
            return    
        end

        %note:there is a maximum limit of 500 entrust placement/withdrawn. as
        %a result, we try to make sure the same entrust, i.e. same underlier
        %futures, entrust price, volume and direction are not repeatly
        %placed.
        q = strategy.mde_fut_.qms_.getquote(instrument.code_ctp);
        if direction < 0
            price = q.bid1 + strategy.bidspread_(ii)*instrument.tick_size;
        else
            price = q.ask1 - strategy.askspread_(ii)*instrument.tick_size;
        end
        withdraw_flag = true;
        n = strategy.entrustspending_.count;
        for jj = 1:n
            e = strategy.entrustspending_.node(jj);
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
        if withdraw_flag
            strategy.withdrawentrusts(instrument);
        end
                
        if direction < 0
%             [ret,e] = strategy.shortopensingleinstrument(instrument.code_ctp,abs(volume));
            strategy.shortopensingleinstrument(instrument.code_ctp,abs(volume));
        else
%             [ret,e] = strategy.longopensingleinstrument(instrument.code_ctp,abs(volume));
            strategy.longopensingleinstrument(instrument.code_ctp,abs(volume));
        end

%         strategy.counter_.queryEntrust(e);
%         f2 = e.is_entrust_closed;
%         
%         if ret&& f2
%             if strategy.executionbucketnumber_(ii) ~= bucketnum;
%                 strategy.executionbucketnumber_(ii) = bucketnum;
%                 strategy.executionperbucket_(ii) = 1;
%             else
%                 strategy.executionperbucket_(ii) = strategy.executionperbucket_(ii)+1;
%             end
%         end

    end

end
%end of autoplacenewentrusts