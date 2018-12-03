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

%         %check wheter we've already executed trades within the
%         %bucket and if so check whether the maximum executed number
%         %is breached or not
%         maxexecutionperbucket = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','maxexecutionperbucket');
%         candlebucketnum = strategy.mde_fut_.getcandlecount(instrument);
%         executionbucketnum = strategy.getexecutionbucketnumber(instrument);
%         if candlebucketnum > 0 && candlebucketnum == executionbucketnum;
%             executionfinished = strategy.getexecutionperbucket(instrument);
%             if executionfinished >=  maxexecutionperbucket
%                 %note: if the maximum execution time is reached we
%                 %won't open up new positions for this bucket
%                 continue;
%             end
%         end

        %note:there is a maximum limit of 500 entrust placement/withdrawn. as
        %a result, we try to make sure the same entrust, i.e. same underlier
        %futures, entrust price, volume and direction are not repeatly
        %placed.

        bidopenspread = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bidopenspread');
        askopenspread = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','askopenspread');
        wrmode = signal.wrmode;
        highestprice = signal.highesthigh;
        lowestprice = signal.lowestlow;
        
        %
        if strcmpi(wrmode,'classic')
            direction = signal.direction;
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
        elseif strcmpi(wrmode,'reverse1')
            tick = strategy.mde_fut_.getlasttick(instrument);
            if isempty(tick),continue;end
            ordertime = tick(1);
            lasttrade = tick(4);
            threshold = (lasttrade - lowestprice)/(highestprice-lowestprice);
            if threshold >= 0.7
                placelong = false;
                placeshort = true;
            elseif threshold <= 0.3
                placelong = true;
                placeshort = false;
            else
                placelong = true;
                placeshort = true;
            end
            
            if placelong
                price =  lowestprice - askopenspread*instrument.tick_size;
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
                price =  highestprice + bidopenspread*instrument.tick_size;
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
        elseif strcmpi(wrmode,'reverse2')
        elseif strcmpi(wrmode,'follow')
            tick = strategy.mde_fut_.getlasttick(instrument);
            if isempty(tick),continue;end
            lasttrade = tick(4);
            threshold = (lasttrade - lowestprice)/(highestprice-lowestprice);
            if threshold >= 0.7
                placelong = true;
                placeshort = false;
            elseif threshold <= 0.3
                placelong = false;
                placeshort = true;
            else
                placelong = true;
                placeshort = true;
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