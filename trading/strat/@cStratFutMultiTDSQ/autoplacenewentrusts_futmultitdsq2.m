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
        
        signalmode = signal.mode_;
        if strcmpi(signalmode,'reverse')
            signaltype = signal.reversetype_;
        elseif strcmpi(signalmode,'trend')
            signaltype = signal.trendtype_;
        else
            signaltype = 'unset';
        end
        
        if strcmpi(signaltype,'unset'), continue;end
        
        volume = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','baseunits');
        if volume == 0, continue;end
        
        volume_exit = strategy.getlivetradevolume(signalmode,signaltype);
        prevdirection = sign(volume_exit);
        
        if strcmpi(signaltype,'perfectbs')
            if volume_exist == 0
                %open a new trade
            elseif volume_exit > 0
            elseif volume_exit < 0
                error('%s:autoplacenewentrusts:error\n',class(strategy))
            end
        else
            continue;
        end
        

        %to check whether position for the instrument exists,
                
        macdvec = strategy.macdvec_{i};
        sigvec = strategy.nineperma_{i};
        
        scenarioname = signal.scenarioname;
        
        scenarionamebreakups = regexp(scenarioname,'-','split');
        isperfect = strfind(scenarionamebreakups{3},'perfect')== 1;
        
        if strcmpi(scenarionamebreakups{1},'bsonly') || strcmpi(scenarionamebreakups{1},'bslast')
            if isperfect
                direction = 1;
            else
                if macdvec(end) > sigvec(end)
                    direction = 1;
                else
                    if prevdirection == -1
                        direction = -1;
                    else
                        direction = 0;
                    end
                end
            end 
        elseif strcmpi(scenarionamebreakups{1},'ssonly') || strcmpi(scenarionamebreakups{1},'sslast')
            if isperfect
                direction = -1;
            else
                if macdvec(end) < sigvec(end)
                    direction = -1;
                else
                    if prevdirection == 1
                        direction = 1;
                    else
                        direction = 0;
                    end
                end
            end
        end
        %
        %
        if sign(prevdirection) == sign(direction), continue;end
        
        
        
        tick = strategy.mde_fut_.getlasttick(instrument);
        if isempty(tick),continue;end
        bid = tick(2);
        ask = tick(3);
        %in case the market is stopped when the upper or lower limit is
        %breached
        if abs(bid) > 1e10 || abs(ask) > 1e10, continue; end
%         ordertime = tick(1);
        
        if prevdirection == 0
            %withdraw any pending entrust with the same open direction
            n = strategy.helper_.entrustspending_.latest;
            for jj = 1:n
                e = strategy.helper_.entrustspending_.node(jj);
                if e.offsetFlag ~= 1, continue; end
                if isempty(e.signalinfo_), continue; end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                if e.direction ~= direction, continue;end %the same direction
                if e.volume ~= volume,continue;end  %the same volume
                if ~strcmpi(e.signalinfo_.scenario,scenarioname),continue;end %the same open signal
                %if the code reaches here, the existing entrust shall be canceled
                strategy.helper_.getcounter.withdrawEntrust(e);
            end
            
            if direction < 0
                strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
            else
                strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
            end
            
        elseif prevdirection == 1
            %withdraw any pending entrust with the same short close direction
            n = strategy.helper_.entrustspending_.latest;
            for jj = 1:n
                e = strategy.helper_.entrustspending_.node(jj);
                if e.offsetFlag ~= -1, continue; end
                if isempty(e.signalinfo_), continue; end
                if ~isa(e.signalinfo_,'cTDSQInfo'),continue;end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                if e.direction ~= -1, continue;end %the same direction
                if e.volume ~= volume_exist,continue;end  %the same volume
                %if the code reaches here, the existing entrust shall be canceled
                strategy.helper_.getcounter.withdrawEntrust(e);
            end
                        
            n = strategy.helper_.trades_.latest_;
            for jj = 1:n
                td = strategy.helper_.trades_.node_(jj);
                if ~strcmpi(td.code_,instrument.code_ctp), continue;end
                if isempty(td.opensignal_),continue;end
                if ~isa(td.opensignal_,'cTDSQInfo'),continue;end
                if td.opendirection_ ~= 1,continue;end
                %if the code reaches here, the trade shall be unwinded
                strategy.unwindtrade(td);
            end
            
            %withdraw any pending entrust with the same short open direction
            if direction == -1
                n = strategy.helper_.entrustspending_.latest;
                for jj = 1:n
                    e = strategy.helper_.entrustspending_.node(jj);
                    if e.offsetFlag ~= 1, continue; end
                    if isempty(e.signalinfo_), continue; end
                    if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                    if e.direction ~= direction, continue;end %the same direction
                    if e.volume ~= volume,continue;end  %the same volume
                    if ~strcmpi(e.signalinfo_.scenario,scenarioname),continue;end %the same open signal
                    %if the code reaches here, the existing entrust shall be canceled
                    strategy.helper_.getcounter.withdrawEntrust(e);
                end
                strategy.shortopen(instrument.code_ctp,volume,'signalinfo',signal);
            end
            
            
        elseif prevdirection == -1
            %withdraw any pending entrust with the same long close direction
            n = strategy.helper_.entrustspending_.latest;
            for jj = 1:n
                e = strategy.helper_.entrustspending_.node(jj);
                if e.offsetFlag ~= -1, continue; end
                if isempty(e.signalinfo_), continue; end
                if ~isa(e.signalinfo_,'cTDSQInfo'),continue;end
                if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                if e.direction ~= 1, continue;end %the same direction
                if e.volume ~= volume_exist,continue;end  %the same volume
                %if the code reaches here, the existing entrust shall be canceled
                strategy.helper_.getcounter.withdrawEntrust(e);
            end
            
            n = strategy.helper_.trades_.latest_;
            for jj = 1:n
                td = strategy.helper_.trades_.node_(jj);
                if ~strcmpi(td.code_,instrument.code_ctp), continue;end
                if isempty(td.opensignal_),continue;end
                if ~isa(td.opensignal_,'cTDSQInfo'),continue;end
                if td.opendirection_ ~= -1,continue;end
                %if the code reaches here, the trade shall be unwinded
                strategy.unwindtrade(td);
            end
            
            %withdraw any pending entrust with the same long open direction
            if direction == 1
                n = strategy.helper_.entrustspending_.latest;
                for jj = 1:n
                    e = strategy.helper_.entrustspending_.node(jj);
                    if e.offsetFlag ~= 1, continue; end
                    if isempty(e.signalinfo_), continue; end
                    if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
                    if e.direction ~= direction, continue;end %the same direction
                    if e.volume ~= volume,continue;end  %the same volume
                    if ~strcmpi(e.signalinfo_.scenario,scenarioname),continue;end %the same open signal
                    %if the code reaches here, the existing entrust shall be canceled
                    strategy.helper_.getcounter.withdrawEntrust(e);
                end
                strategy.longopen(instrument.code_ctp,volume,'signalinfo',signal);
            end
            
        end
    
    
        
    end
end