function [] = autoplacenewentrusts_futmultitdsq2(strategy,signals)
%cStratFutMultiTDSQ
    if isempty(strategy.helper_), error('%s::autoplacenewentrusts::missing helper!!!',class(strategy));end
    %now check the signals
    instruments = strategy.getinstruments;
    
    for i = 1:strategy.count
        instrument = instruments{i};
        autotrade = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','autotrade');
        if ~autotrade,continue;end
        
        if strcmpi(strategy.mode_,'replay')
            runningt = strategy.replay_time1_;
        else
            runningt = now;
        end
        ismarketopen = istrading(runningt,instrument.trading_hours,'tradingbreak',instrument.trading_break);
        if ~ismarketopen, continue;end
        volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','baseunits');
        if volume == 0, continue;end
        
        for j = 1:size(signals,2)
            signal = signals{i,j};
            if isempty(signal), continue;end
            signalmode = signal.mode;
            signaltype = signal.type;
            if strcmpi(signalmode,'unset') || strcmpi(signaltype,'unset'), continue;end
            trade_signaltype = strategy.getlivetrade_tdsq(instrument.code_ctp,signalmode,signaltype);
            if ~isempty(trade_signaltype), continue;end
            %
            %cancel any pending entrust with open offsetflag
            n = strategy.helper_.entrustspending_.latest;
            for jj = 1:n
                e = strategy.helper_.entrustspending_.node(jj);
                if e.offsetFlag ~= 1, continue; end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end
                if isempty(e.signalinfo_), continue; end
                try
                    if ~strcmpi(e.signalinfo_.type_,signaltype),continue;end
                catch
                    continue;
                end
                %if the code reaches here, the existing entrust shall be canceled
                strategy.helper_.getcounter.withdrawEntrust(e);
            end
            %
            if strcmpi(signaltype,'perfectbs') || ...
                    strcmpi(signaltype,'semiperfectbs') || ...
                    strcmpi(signaltype,'imperfectbs')
                strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                %
            elseif strcmpi(signaltype,'perfectss') || ...
                    strcmpi(signaltype,'semiperfectss') || ...
                    strcmpi(signaltype,'imperfectss')
                strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                %
            elseif strcmpi(signaltype,'single-lvldn')
                strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                %
            elseif strcmpi(signaltype,'single-lvlup')
                strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                %
            elseif strcmpi(signaltype,'double-range')
                if signal.direction == 1
                    strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                else
                    strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                end
                %
            elseif strcmpi(signaltype,'double-bullish')
                strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                %
            elseif strcmpi(signaltype,'double-bearish')
                strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                %
            else
                error('signaltype not implemented')
            end
        end
    end
end