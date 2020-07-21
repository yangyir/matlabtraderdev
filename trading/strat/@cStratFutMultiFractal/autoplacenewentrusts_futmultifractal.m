function [] = autoplacenewentrusts_futmultifractal(stratfractal,signals)
    %cStratFutMultiFractal
    if isempty(stratfractal.helper_), error('%s::autoplacenewentrusts::missing helper!!!',class(stratfractal));end

    n = stratfractal.count;
    instruments = stratfractal.getinstruments;
    for i = 1:n
        signal = signals(i,1);
        %to check whether there is a valid signal
        if isempty(signal), continue; end
        if signal == 0, continue;end
        if signals(i,4) == 0, continue;end

        %to check whether the instrument is set with autotrade flag
        instrument = instruments{i};
        autotrade = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','autotrade');
        if ~autotrade,continue;end

        %to check whether the instrument is allowed to trade with valid size
        volume = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','baseunits');
        maxvolume = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','maxunits');
        if volume == 0 || maxvolume == 0, continue;end

        %to check whether running time is tradable
        if strcmpi(stratfractal.mode_,'replay')
            runningt = stratfractal.replay_time1_;
        else
            runningt = now;
        end        
        ismarketopen = istrading(runningt,instrument.trading_hours,'tradingbreak',instrument.trading_break);    
        if ~ismarketopen, continue;end

        %to check whether there is a valid tick price
        tick = stratfractal.mde_fut_.getlasttick(instrument);
        if isempty(tick),continue;end
        bid = tick(2);
        ask = tick(3);
        %in case the market is stopped when the upper or lower limit is breached
        if abs(bid) > 1e10 || abs(ask) > 1e10, continue; end
        if bid <= 0 || ask <= 0, continue;end

        %to check whether position for the instrument exists,
        try
            [flag,idx] = stratfractal.helper_.book_.hasposition(instrument);
        catch
            flag = false;
            idx = 0;
        end
        if ~flag
            volume_exist = 0;
        else
            pos = stratfractal.helper_.book_.positions_{idx};
            volume_exist = pos.position_total_;
        end

        %to check whether maximum volume has been reached
        if volume_exist >= maxvolume, continue;end

        %here below we are about to place an order
        %but we shall withdraw any pending entrust with the same direction
        ne = stratfractal.helper_.entrustspending_.latest;
        for jj = 1:ne
            e = stratfractal.helper_.entrustspending_.node(jj);
            if e.offsetFlag ~= 1, continue; end
            if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
            if e.direction ~= direction, continue;end %the same direction
            if e.volume ~= volume,continue;end  %the same volume
            %if the code reaches here, the existing entrust shall be canceled
            stratfractal.helper_.getcounter.withdrawEntrust(e);
        end

        if signal < 0
            if signal == -1
                type = 'breachdn-S';
            else
                error('unknown signal');
            end
            if signals(i,4) == 1
                mode = 'breachdn-lvldn';
            else
                mode = 'unset';
            end
            if bid < signals(i,3) && bid > signals(i,3)-1.618*(signals(i,2)-signals(i,3))
                nfractals = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','nfractals');
                info = struct('name','fractal','type',type,...
                    'hh',signals(i,2),'ll',signals(i,3),'mode',mode,'nfractal',nfractals,...
                    'hh1',signals(i,5),'ll1',signals(i,6));
                stratfractal.shortopen(instrument.code_ctp,volume,'signalinfo',info);
            end
        else
            if signal == 1
                type = 'breachup-B';
            else
                error('unknown signal')
            end
            if signals(i,4) == 1
                mode = 'breachup-lvlup';
            else
                mode = 'unset';
            end
            if ask > signals(i,2) && ask < signals(i,2)+1.618*(signals(i,2)-signals(i,3))
                nfractals = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','nfractals');
                info = struct('name','fractal','type',type,...
                    'hh',signals(i,2),'ll',signals(i,3),'mode',mode,'nfractal',nfractals,...
                    'hh1',signals(i,5),'ll1',signals(i,6));
                stratfractal.longopen(instrument.code_ctp,volume,'signalinfo',info);
            end
        end

    end    
    
end