function [] = autoplacenewentrusts_futmultiwr(strategy,signals)
%cStratFutMultiWR
    if isempty(strategy.helper_), error('%s::autoplacenewentrusts::missing helper!!!',class(strategy));end
    %now check the signals
    for i = 1:size(signals,1)
        signal = signals{i};
        %to check whether there is a valid signal
        if isempty(signal), continue; end

        %to check whether the instrument is set with autotrade flag
        instrument = signal.instrument;
        autotrade = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','autotrade');
        if ~autotrade,continue;end

        %to check whether position for the instrument exists,
        try
            [flag,idx] = strategy.helper_.book_.hasposition(instrument);
        catch
            flag = false;
            idx = 0;
        end
        if ~flag
            volume_exist = 0;
        else
            pos = strategy.helper_.book_.positions_{idx};
            volume_exist = pos.position_total_;
        end
        
        direction = signal.direction;
        
%         %note:in case the exist positions are with the different direction
%         %as of the signal, we shall first unwind the existing position and
%         %then open up position with the new direction
%         %maybe some todo here, i am not sure
%         unwind_count = 0;
%         while direction_exist * direction < 0
%             %try to unwind the position
%             strategy.unwindposition(instrument,unwind_count);
%             %update the position and direction
%             pos = strategy.bookrunning_.positions_{idx};
%             volume_exist = pos.position_total_;
%             direction_exist = pos.direction_;
%             unwind_count = unwind_count + 1;
%         end

        %note:in case there is no existing position, we would trade the
        %base units. o/w, the execution methodology is specified
        if volume_exist == 0
            volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','baseunits');
        else
            maxvolume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','maxunits');
            executiontype = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','executiontype');
            if strcmpi(executiontype,'martingale')
                %note:'martingale' execution type means the existing
                %position units are traded every time when the signal is
                %valid
                volume = max(min(maxvolume-volume_exist,volume_exist),0);
            elseif strcmpi(executiontype,'fixed')
                %note:'fixed' execution type means the base units are
                %traded every time when the signal is valid
                n = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','baseunits');
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
        maxexecutionperbucket = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','maxexecutionperbucket');
        candlebucketnum = strategy.mde_fut_.getcandlecount(instrument);
        executionbucketnum = strategy.getexecutionbucketnumber(instrument);
        if candlebucketnum > 0 && candlebucketnum == executionbucketnum;
            executionfinished = strategy.getexecutionperbucket(instrument);
            if executionfinished >=  maxexecutionperbucket
                %note: if the maximum execution time is reached we
                %won't open up new positions for this bucket
                continue;
            end
        end

        %note:there is a maximum limit of 500 entrust placement/withdrawn. as
        %a result, we try to make sure the same entrust, i.e. same underlier
        %futures, entrust price, volume and direction are not repeatly
        %placed.
        bidopenspread = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bidopenspread');
        askopenspread = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','askopenspread');
        
        if strcmpi(strategy.mode_,'realtime')
            ordertime = now;
            q = strategy.mde_fut_.qms_.getquote(instrument.code_ctp);
            if direction < 0
                price = q.bid1 + bidopenspread*instrument.tick_size;
            else
                price = q.ask1 - askopenspread*instrument.tick_size;
            end
        else
            tick = strategy.mde_fut_.getlasttick(instrument);
            if isempty(tick),continue;end
            ordertime = tick(1);
            bid = tick(2);
            ask = tick(3);
            if direction < 0
                price =  bid + bidopenspread*instrument.tick_size;
            else
                price =  ask - askopenspread*instrument.tick_size;
            end
        end
        
        withdraw_flag = true;
        n = strategy.helper_.entrustspending_.latest;
        for jj = 1:n
            e = strategy.helper_.entrustspending_.node(jj);
            f1 = strcmpi(e.instrumentCode,instrument.code_ctp);%the same instrument
            f2 = e.direction == direction; %the same direction
            if e.direction == 1
                f3 = e.price <= price;
            elseif e.direction == -1
                f3 = e.price >= price;
            end
            f4 = e.volume == abs(volume);  %the same volume
            if f1&&f2&&f3&&f4
                withdraw_flag = false;
                break
            end
        end
        
        %if withdraw is needed
        %firstly to unwind all existing entrusts associated with
        %the instrument
        if withdraw_flag, strategy.withdrawentrusts(instrument); end
                
        if direction < 0
            strategy.shortopen(instrument.code_ctp,abs(volume),...
                'overrideprice',price,'time',ordertime,'signalinfo',signal);
        else
            strategy.longopen(instrument.code_ctp,abs(volume),...
                'overrideprice',price,'time',ordertime,'signalinfo',signal);
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