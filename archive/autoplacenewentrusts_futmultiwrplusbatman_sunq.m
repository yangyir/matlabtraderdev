function [] = autoplacenewentrusts_futmultiwrplusbatman_sunq(obj,signals)
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
        checkflag = signal.checkflag;
        if checkflag == 0, continue; end
        
        %fourth to check whether the instrument has been traded or not,
        %i.e. there is an existing position
        [flag,idx] = obj.bookrunning_.hasposition(instrument);
        if ~flag
            volume_exist = 0;
        else
            pos = obj.bookrunning_.positions_{idx};
            volume_exist = pos.position_total_;
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
            ordertime = now;
        else
            tick = obj.mde_fut_.getlasttick(instrument);
            ordertime = tick(1);
        end
        highprice = signal.highprice;
        lowprice = signal.lowprice;
        withdraw_flag = true;
        n = obj.helper_.entrustspending_.latest;
        withdraw_flag1 = zeros(n);
        withdraw_flag2 = zeros(n);
        for jj = 1:n
            e = obj.helper_.entrustspending_.node(jj);
            f1 = strcmpi(e.instrumentCode,instrument.code_ctp);
            f2 = (e.price == highprice & e.direction == -1);
            f3 = (e.price == lowprice & e.direction == 1);
            f4 = e.volume == abs(volume);
            if f1&&f2&&f4
                withdraw_flag1(jj) = 1;
            else
                withdraw_flag1(jj) = 0;
            end
            if f1&&f3&&f4
                withdraw_flag2(jj) = 1;
            else
                withdraw_flag2(jj) = 0;
            end
        end
        if sum(sum(withdraw_flag1))>0 && sum(sum(withdraw_flag2))>0
            withdraw_flag = false;
        end
        
        %if withdraw is needed
        %firstly to unwind all existing entrusts associated with
        %the instrument
        if withdraw_flag, obj.withdrawentrusts(instrument); end

            obj.shortopensingleinstrument(instrument.code_ctp,abs(volume),0,...
                'overrideprice',highprice,'time',ordertime);

            obj.longopensingleinstrument(instrument.code_ctp,abs(volume),0,...
                'overrideprice',lowprice,'time',ordertime);

    end
end