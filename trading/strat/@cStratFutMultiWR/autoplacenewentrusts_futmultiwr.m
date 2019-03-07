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

        %note:there is a maximum limit of 500 entrust placement/withdrawn. as
        %a result, we try to make sure the same entrust, i.e. same underlier
        %futures, entrust price, volume and direction are not repeatly
        %placed.

        bidopenspread = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bidopenspread');
        askopenspread = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','askopenspread');
        wrmode = signal.wrmode;
        highestprice = signal.highesthigh;
        lowestprice = signal.lowestlow;
        highestcandle = signal.highestcandle;
        lowestcandle = signal.lowestcandle;
        %
        tick = strategy.mde_fut_.getlasttick(instrument);
        if isempty(tick),continue;end
        bid = tick(2);
        ask = tick(3);
        %in case the market is stopped when the upper or lower limit is
        %breached
        if abs(bid) > 1e10 || abs(ask) > 1e10, continue; end
        ordertime = tick(1);
        lasttrade = tick(4);
        
        if strcmpi(wrmode,'classic')
            direction = signal.direction;
            if direction < 0
                price =  bid + bidopenspread*instrument.tick_size;
            else
                price =  ask - askopenspread*instrument.tick_size;
            end
            
            % check whether existing pending entrust is the same and if it
            % is not, withdraw the existing one and place a new one
            isplacenewrequired = true;
            n = strategy.helper_.entrustspending_.latest;
            for jj = 1:n
                e = strategy.helper_.entrustspending_.node(jj);
                if e.offsetFlag ~= 1, continue; end
                if isempty(e.signalinfo_), continue; end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                if e.direction ~= direction, continue;end %the same direction
                if e.volume ~= volume,continue;end  %the same volume
                if ~strcmpi(e.signalinfo_.wrmode,wrmode),continue;end %the same open signal
                %is it a better long position deal?
                if e.direction == 1 && e.price <= price
                    isplacenewrequired = false;
                    continue;
                end
                %
                %is it a better short position deal?
                if e.direction == -1 && e.price >= price
                    isplacenewrequired = false;
                    continue;
                end 
                %if the code reaches here, the existing entrust shall be
                %canceled
                strategy.helper_.getcounter.withdrawEntrust(e);
            end
        
            if isplacenewrequired
                if direction < 0
                    strategy.shortopen(instrument.code_ctp,volume,...
                        'overrideprice',price,'time',ordertime,'signalinfo',signal);
                else
                    strategy.longopen(instrument.code_ctp,volume,...
                        'overrideprice',price,'time',ordertime,'signalinfo',signal);
                end
            end
            %
        elseif strcmpi(wrmode,'reverse')
            %note:in mode 'reverse', we generate signals based on the
            %previous max and min prices of the selected period, i.e.
            %we sell at the previous max (plus specified bid spread);
            %and buy at the previous min (minus specified offer spread)
            %here the latest candle are included to avoid price jump
            threshold = (lasttrade - lowestprice)/(highestprice-lowestprice);
            if threshold >= 0.7
                placelong = false;
                placeshort = true;
            elseif threshold <= 0.3
                placelong = true;
                placeshort = false;
            else
                placelong = false;
                placeshort = false;
            end
            
            if placelong
                price =  min(lowestprice,ask) - askopenspread*instrument.tick_size;
                isplacenewrequired = true;
                n = strategy.helper_.entrustspending_.latest;
                for jj = 1:n
                    e = strategy.helper_.entrustspending_.node(jj);
                    if e.offsetFlag ~= 1, continue; end
                    if isempty(e.signalinfo_), continue; end
                    if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                    if e.direction ~= 1, continue;end %the same direction
                    if e.volume ~= volume,continue;end  %the same volume
                    if ~strcmpi(e.signalinfo_.wrmode,wrmode),continue;end %the same open signal
                    %is it a better long position deal?
                    if e.price <= price
                        isplacenewrequired = false;
                        continue;
                    end
                    %if the code reaches here, the existing entrust shall be
                    %canceled
                    strategy.helper_.getcounter.withdrawEntrust(e);
                end
                if isplacenewrequired
                    strategy.longopen(instrument.code_ctp,volume,...
                        'overrideprice',price,'time',ordertime,'signalinfo',signal);
                end            
            end
            
            if placeshort
                price =  max(highestprice,bid) + bidopenspread*instrument.tick_size;
                isplacenewrequired = true;
                n = strategy.helper_.entrustspending_.latest;
                for jj = 1:n
                    e = strategy.helper_.entrustspending_.node(jj);
                    if e.offsetFlag ~= 1, continue; end
                    if isempty(e.signalinfo_), continue; end
                    if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                    if e.direction ~= -1, continue;end %the same direction
                    if e.volume ~= volume,continue;end  %the same volume
                    if ~strcmpi(e.signalinfo_.wrmode,wrmode),continue;end %the same open signal
                    %is it a better long position deal?
                    if e.price >= price
                        isplacenewrequired = false;
                        continue;
                    end
                    %if the code reaches here, the existing entrust shall be
                    %canceled
                    strategy.helper_.getcounter.withdrawEntrust(e);
                end
                
                if isplacenewrequired
                    strategy.shortopen(instrument.code_ctp,volume,...
                        'overrideprice',price,'time',ordertime,'signalinfo',signal);
                end
            end
            %
        elseif strcmpi(wrmode,'flash')
            %note in mode 'flash', we generate signals based on the
            %candle which contains either the latest max or min prices
            %then we try to open 1)long once the latest price
            %breaches above the highest of that candle or 2)short once the
            %lastest price breaches below the lowest of that candle
            
            %rule:1)no new high is achieved with the tick
            %2)the tick is higher than the candle's low
            %3)open a conditional entrust with short position at the
            %candle's low price
            checkflag = signal.checkflag;
            if lasttrade <= highestprice && checkflag == 1
                if lasttrade >= highestcandle(4)
                    price = highestcandle(4) - instrument.tick_size;
                    isplacenewrequired = true;
                    condentrusts2remove = EntrustArray;
                    n = strategy.helper_.condentrustspending_.latest;
                    for jj = 1:n
                        e = strategy.helper_.condentrustspending_.node(jj);
                        if e.offsetFlag ~= 1, continue; end
                        if isempty(e.signalinfo_), continue; end
                        if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                        if e.direction ~= -1, continue;end %the same direction
                        if e.volume ~= volume,continue;end  %the same volume
                        if ~strcmpi(e.signalinfo_.wrmode,wrmode),continue;end %the same open signal
                        %is it a better long position deal?
                        if e.price >= price
                            isplacenewrequired = false;
                            continue;
                        end
                        %if the code reaches here, the existing conditional
                        %entrust shall be canceled
                        condentrusts2remove.push(e);
    %                     strategy.helper_.condentrustspending_.removeByIndex(jj);
                    end
                    %now we first remove any conditional entrusts if required
                    n2remove = condentrusts2remove.latest;
                    for k = 1:n2remove
                        e2remove = condentrusts2remove.node(k);
                        npending = strategy.helper_.condentrustspending_.latest;
                        for kk = npending:-1:1
                            e = strategy.helper_.condentrustspending_.node(kk);
                            if strcmpi(e.instrumentCode,e2remove.instrumentCode) && ...
                                    (e.direction == e2remove.direction) && ...
                                    (e.volume == e2remove.volume) && ...
                                    (e.price == e2remove.price)
                                rmidx = kk;
                                strategy.helper_.condentrustspending_.removeByIndex(rmidx);
                                break
                            end
                        end
                    end
                    %
                    if isplacenewrequired
                        strategy.condshortopen(instrument.code_ctp,price,...
                            volume,'signalinfo',signal);
                    end
                elseif lasttrade < highestcandle(4)
                    %market order
                    price = bid;
                    strategy.shortopen(instrument.code_ctp,volume,...
                        'overrideprice',price,'time',ordertime,'signalinfo',signal);
                    %also we need to remove any pending conditional entrust
                    %associated with this instrument
                    condentrusts2remove = EntrustArray;
                    n = strategy.helper_.condentrustspending_.latest;
                    for jj = 1:n
                        e = strategy.helper_.condentrustspending_.node(jj);
                        if e.offsetFlag ~= 1, continue; end
                        if isempty(e.signalinfo_), continue; end
                        if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                        if e.direction ~= -1, continue;end %the same direction
                        if e.volume ~= volume,continue;end  %the same volume
                        if ~strcmpi(e.signalinfo_.wrmode,wrmode),continue;end %the same open signal
                        condentrusts2remove.push(e);
                    end
                    %now we first remove any conditional entrusts if required
                    n2remove = condentrusts2remove.latest;
                    for k = 1:n2remove
                        e2remove = condentrusts2remove.node(k);
                        npending = strategy.helper_.condentrustspending_.latest;
                        for kk = npending:-1:1
                            e = strategy.helper_.condentrustspending_.node(kk);
                            if strcmpi(e.instrumentCode,e2remove.instrumentCode) && ...
                                    (e.direction == e2remove.direction) && ...
                                    (e.volume == e2remove.volume) && ...
                                    (e.price == e2remove.price)
                                rmidx = kk;
                                strategy.helper_.condentrustspending_.removeByIndex(rmidx);
                                break
                            end
                        end
                    end
                end
            end
            %
            %rule:1)no new low is achieved with the tick
            %2)the tick is lower than the candle's high
            %3)open a conditional entrust with long position at the
            %candle's high price
            if lasttrade >= lowestprice && checkflag == -1
                if lasttrade <= lowestcandle(3)
                    price = lowestcandle(3) + instrument.tick_size;
                    isplacenewrequired = true;
                    condentrusts2remove = EntrustArray;
                    n = strategy.helper_.condentrustspending_.latest;
                    for jj = 1:n
                        e = strategy.helper_.condentrustspending_.node(jj);
                        if e.offsetFlag ~= 1, continue; end
                        if isempty(e.signalinfo_), continue; end
                        if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                        if e.direction ~= 1, continue;end %the same direction
                        if e.volume ~= volume,continue;end  %the same volume
                        if ~strcmpi(e.signalinfo_.wrmode,wrmode),continue;end %the same open signal
                        %is it a better long position deal?
                        if e.price <= price
                            isplacenewrequired = false;
                            continue;
                        end
                        %if the code reaches here, the existing conditional 
                        %entrust shall be canceled
                        condentrusts2remove.push(e);
    %                     strategy.helper_.condentrustspending_.removeByIndex(jj);
                    end
                    %now we first remove any conditional entrusts if required
                    n2remove = condentrusts2remove.latest;
                    for k = 1:n2remove
                        e2remove = condentrusts2remove.node(k);
                        npending = strategy.helper_.condentrustspending_.latest;
                        for kk = npending:-1:1
                            e = strategy.helper_.condentrustspending_.node(kk);
                            if strcmpi(e.instrumentCode,e2remove.instrumentCode) && ...
                                    (e.direction == e2remove.direction) && ...
                                    (e.volume == e2remove.volume) && ...
                                    (e.price == e2remove.price)
                                rmidx = kk;
                                strategy.helper_.condentrustspending_.removeByIndex(rmidx);
                                break
                            end
                        end
                    end
                    %
                    if isplacenewrequired
                        strategy.condlongopen(instrument.code_ctp,price,...
                            volume,'signalinfo',signal);
                    end
                elseif lasttrade > lowestcandle(3)
                    %market order
                    price = ask;
                    strategy.longopen(instrument.code_ctp,volume,...
                        'overrideprice',price,'time',ordertime,'signalinfo',signal);
                    %also we need to remove any pending conditional entrust
                    %associated with this instrument
                    condentrusts2remove = EntrustArray;
                    n = strategy.helper_.condentrustspending_.latest;
                    for jj = 1:n
                        e = strategy.helper_.condentrustspending_.node(jj);
                        if e.offsetFlag ~= 1, continue; end
                        if isempty(e.signalinfo_), continue; end
                        if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                        if e.direction ~= 1, continue;end %the same direction
                        if e.volume ~= volume,continue;end  %the same volume
                        if ~strcmpi(e.signalinfo_.wrmode,wrmode),continue;end %the same open signal
                        condentrusts2remove.push(e);
                    end
                    %now we first remove any conditional entrusts if required
                    n2remove = condentrusts2remove.latest;
                    for k = 1:n2remove
                        e2remove = condentrusts2remove.node(k);
                        npending = strategy.helper_.condentrustspending_.latest;
                        for kk = npending:-1:1
                            e = strategy.helper_.condentrustspending_.node(kk);
                            if strcmpi(e.instrumentCode,e2remove.instrumentCode) && ...
                                    (e.direction == e2remove.direction) && ...
                                    (e.volume == e2remove.volume) && ...
                                    (e.price == e2remove.price)
                                rmidx = kk;
                                strategy.helper_.condentrustspending_.removeByIndex(rmidx);
                                break
                            end
                        end
                    end             
                end
            end
            %
        elseif strcmpi(wrmode,'flashma')
            %note in mode 'flashma', we generate signals based on two
            %moving average of the WilliamsR% series
            %we try to open 1)long once the short wrma breaches above the
            %long wrma or 2)short once the short wrma breaches below the
            %long wrma
            checkflag = signal.checkflag;
            %rule:1)no new high is achieved with the tick
            %2)short ma moves lower than long ma
            %3)open a conditional entrust with short position at the
            %candle's low price
            if lasttrade <= highestprice && checkflag == 1
            end
            %
            %rule:1)no new low is achieved with the tick
            %2)short ma moves higher than long ma
            %3)place a entrust with long position at the market price
            if lasttrade >= lowestprice && checkflag == -1
            end
            %
        elseif strcmpi(wrmode,'follow')
            %note in mode 'follow', we generate signals based on the
            %candle which contains either the latest max or min prices
            %then we try to open 1)short once the latest price breaches
            %below the latest min price with stoploss at that candle's
            %high price or open 2)long once the latest price breaches
            %above the latest max price with stoploss at that candle's
            %low price
            threshold = (lasttrade - lowestprice)/(highestprice-lowestprice);
            if threshold >= 0.7
                placelong = true;
                placeshort = false;
            elseif threshold <= 0.3
                placelong = false;
                placeshort = true;
            else
                placelong = false;
                placeshort = false;
            end
            
            if placelong
                price =  highestprice + askopenspread*instrument.tick_size;
                isplacenewrequired = true;
                n = strategy.helper_.condentrustspending_.latest;
                for jj = 1:n
                    e = strategy.helper_.condentrustspending_.node(jj);
                    if e.offsetFlag ~= 1, continue; end
                    if isempty(e.signalinfo_), continue; end
                    if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                    if e.direction ~= 1, continue;end %the same direction
                    if e.volume ~= volume,continue;end  %the same volume
                    if ~strcmpi(e.signalinfo_.wrmode,wrmode),continue;end %the same open signal
                    %is it a better long position deal?
                    if e.price <= price
                        isplacenewrequired = false;
                        continue;
                    end
                    %if the code reaches here, the existing conditional 
                    %entrust shall be canceled
                    strategy.helper_.condentrustspending_.removeByIndex(jj);
                end
                if isplacenewrequired
                    strategy.condlongopen(instrument.code_ctp,price,...
                        volume,'signalinfo',signal);
                end
            end
            
            if placeshort
                price =  lowestprice - bidopenspread*instrument.tick_size;
                isplacenewrequired = true;
                n = strategy.helper_.condentrustspending_.latest;
                for jj = 1:n
                    e = strategy.helper_.condentrustspending_.node(jj);
                    if e.offsetFlag ~= 1, continue; end
                    if isempty(e.signalinfo_), continue; end
                    if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                    if e.direction ~= -1, continue;end %the same direction
                    if e.volume ~= volume,continue;end  %the same volume
                    if ~strcmpi(e.signalinfo_.wrmode,wrmode),continue;end %the same open signal
                    %is it a better long position deal?
                    if e.price >= price
                        isplacenewrequired = false;
                        continue;
                    end
                    %if the code reaches here, the existing conditional 
                    %entrust shall be canceled
                    strategy.helper_.condentrustspending_.removeByIndex(jj);
                end
                if isplacenewrequired
                    strategy.condshortopen(instrument.code_ctp,price,...
                        volume,'signalinfo',signal);
                end          
            end
            
            
        elseif strcmpi(wrmode,'all')
        end


    end

end
%end of autoplacenewentrusts