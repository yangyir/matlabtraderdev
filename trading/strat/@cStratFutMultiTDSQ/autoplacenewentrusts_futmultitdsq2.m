function [] = autoplacenewentrusts_futmultitdsq2(strategy,signals)
%cStratFutMultiTDSQ
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
        
        if strcmpi(strategy.mode_,'replay')
            runningt = strategy.replay_time1_;
        else
            runningt = now;
        end
        
        ismarketopen = istrading(runningt,instrument.trading_hours,...
            'tradingbreak',instrument.trading_break);
        if ~ismarketopen, continue;end
        
        volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','baseunits');
        if volume == 0, continue;end
        
        signalmode = signal.mode;
        signaltype = signal.type;
        if strcmpi(signalmode,'unset') || strcmpi(signaltype,'unset'), continue;end
                
        trade_signaltype = strategy.getlivetrade_tdsq(instrument.code_ctp,signalmode,signaltype);
        
        %do nothing if live trade still exist
        if ~isempty(trade_signaltype), continue;end
        
        %cancel any pending entrust with open offsetflag
        n = strategy.helper_.entrustspending_.latest;
        for jj = 1:n
            e = strategy.helper_.entrustspending_.node(jj);
            if e.offsetFlag ~= 1, continue; end
            if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
            if isempty(e.signalinfo_), continue; end
            if ~isa(e.signalinfo_,'cTDSQInfo'),continue;end
            %if the code reaches here, the existing entrust shall be canceled
            strategy.helper_.getcounter.withdrawEntrust(e);
        end
        
        if strcmpi(signaltype,'perfectbs') || ...
                strcmpi(signaltype,'semiperfectbs') || ...
                strcmpi(signaltype,'imperfectbs') 
            strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
        elseif strcmpi(signaltype,'perfectss') || ...
                strcmpi(signaltype,'semiperfectss') || ...
                strcmpi(signaltype,'imperfectss')
            strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
        else
            error('not implemented')
        end
        
    end
end