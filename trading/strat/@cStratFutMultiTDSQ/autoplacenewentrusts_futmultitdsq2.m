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
%             trade_signaltype = strategy.getlivetrade_tdsq(instrument.code_ctp,signalmode,signaltype);
            %Note:20190901
            %add a control with a target portfolio
            typeidx = cTDSQInfo.gettypeidx(signaltype);
            targetholding = strategy.targetportfolio_(i,typeidx);
            
%             if ~isempty(trade_signaltype) || targetholding ~= 0, continue;end
            if targetholding ~= 0, continue;end
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
            if strcmpi(signaltype,'perfectbs')
                %20190916
                %further control:as we use the previous candle close to
                %pop-up the signal, we'd suggest to check whether the next
                %open still above the risklvl especially after some market
                %long break, e.g. long weekend
                tick = strategy.mde_fut_.getlasttick(instrument.code_ctp);
                lasttrade = tick(4);
                volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumeperfect');
                if lasttrade > signal.risklvl && volume > 0
                    strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = volume;
                end
                %
            elseif strcmpi(signaltype,'semiperfectbs') || strcmpi(signaltype,'imperfectbs')
                sn = signal.scenarioname;
                tick = strategy.mde_fut_.getlasttick(instrument.code_ctp);
                lasttrade = tick(4);
                if strcmpi(signaltype,'semiperfectbs')
                    volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumesemiperfect');
                else
                    volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumeimperfect');
                end
                if ~isempty(strfind(sn,'-breachuplvldn'))
                    stillopen = lasttrade > signal.lvldn;
                elseif ~isempty(strfind(sn,'-breachuplvlup'))
                    stillopen = lasttrade > signal.lvlup;
                else
                    stillopen = true;
                end
                if stillopen && volume > 0
                    strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = volume;
                end
                %
            elseif strcmpi(signaltype,'perfectss')
                 %20190916
                %further control:as we use the previous candle close to
                %pop-up the signal, we'd suggest to check whether the next
                %open still below the risklvl especially after some market
                %long break, e.g. long weekend
                tick = strategy.mde_fut_.getlasttick(instrument.code_ctp);
                lasttrade = tick(4);
                volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumeperfect');
                if lasttrade < signal.risklvl && volume > 0
                    strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = -volume;
                end
                %
            elseif strcmpi(signaltype,'semiperfectss') || strcmpi(signaltype,'imperfectss')
                sn = signal.scenarioname;
                tick = strategy.mde_fut_.getlasttick(instrument.code_ctp);
                lasttrade = tick(4);
                if strcmpi(signaltype,'semiperfectss')
                    volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumesemiperfect');
                else
                    volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumeimperfect');
                end
                if ~isempty(strfind(sn,'-breachdnlvldn'))
                    stillopen = lasttrade < signal.lvldn;
                elseif ~isempty(strfind(sn,'-breachdnlvlup'))
                    stillopen = lasttrade < signal.lvlup;
                else
                    stillopen = true;
                end
                if stillopen && volume > 0
                    strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = -volume;
                end
                %
            elseif strcmpi(signaltype,'single-lvldn')
                volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumesinglelvldn');
                if volume > 0
                    strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = -volume;
                end
                %
            elseif strcmpi(signaltype,'single-lvlup')
                volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumesinglelvlup');
                if volume > 0
                    strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = volume;
                end
                %
            elseif strcmpi(signaltype,'double-range')
                volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumedoublerange');
                if signal.direction == 1 && volume > 0
                    strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = volume;
                elseif signal.direction == -1 && volume > 0
                    strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = -volume;
                end
                %
            elseif strcmpi(signaltype,'double-bullish')
                volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumedoublebullish');
                if signal.direction == 1 && volume > 0
                    strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = volume;
                elseif signal.direction == -1 && volume > 0
                    strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = -volume;
                end
                %
            elseif strcmpi(signaltype,'double-bearish')
                volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumedoublebearish');
                if signal.direction == -1 && volume > 0
                    strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = -volume;
                elseif signal.direction == 1 && volume > 0
                    strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = volume;
                end
                %
            elseif strcmpi(signaltype,'simpletrend')
                volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','volumesimpletrend');
                if signal.direction == 1 && volume > 0
                    strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = volume;
                elseif signal.direction == -1 && volume > 0
                    strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
                    strategy.targetportfolio_(i,typeidx) = -volume;
                end
                %
            else
                error('signaltype not implemented')
            end
        end
    end
end