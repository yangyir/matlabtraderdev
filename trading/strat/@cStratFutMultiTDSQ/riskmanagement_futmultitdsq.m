function [] = riskmanagement_futmultitdsq(strategy,dtnum)
%cStratFutMultiTDSQ
    runningmm = hour(dtnum)*60+minute(dtnum);
    if (runningmm >= 539 && runningmm < 540) || ...
            (runningmm >= 779 && runningmm < 780) || ...
            (runningmm >= 1259 && runningmm < 1260)
        trades = strategy.helper_.trades_;
        for itrade = 1:trades.latest_
            trade_i = trades.node_(itrade);
            if strcmpi(trade_i.status_,'unset') || strcmpi(trade_i.status_,'closed'), continue;end
            if isa(trade_i.opensignal_,'cTDSQInfo')
                [~,idxrow] = strategy.hasinstrument(trade_i.instrument_);
                idxcol = cTDSQInfo.gettypeidx(trade_i.opensignal_.type_);
                strategy.targetportfolio_(idxrow,idxcol) = trade_i.opendirection_*trade_i.openvolume_;
            end
        end
    end
    % check whether there are any pending open orders every 3 seconds
    runpendingordercheck = mod(floor(second(dtnum)),3) == 0;
    % check target portfolio every minute
    runtargetportfoliocheck = floor(second(dtnum)) == 59;
    
    if ~runpendingordercheck && ~runtargetportfoliocheck, return;end
    
    if runtargetportfoliocheck
        instruments = strategy.getinstruments;
        for i = 1:strategy.count
            instrument = instruments{i};
            ismarketopen = istrading(dtnum,instrument.trading_hours,'tradingbreak',instrument.trading_break);
            if ~ismarketopen, continue;end

            for j = 1:cTDSQInfo.numoftype
                volume_target = strategy.targetportfolio_(i,j);
                type = cTDSQInfo.idx2type(j);
                switch type
                    case {'perfectbs','semiperfectbs','imperfectbs'}
                        trade_signaltype = strategy.getlivetrade_tdsq(instruments{i}.code_ctp,'reverse',type);
                        mode = 'reverse';
                    case {'perfectss','semiperfectss','imperfectss'}
                        trade_signaltype = strategy.getlivetrade_tdsq(instruments{i}.code_ctp,'reverse',type);
                        mode = 'reverse';
                    otherwise
                        trade_signaltype = strategy.getlivetrade_tdsq(instruments{i}.code_ctp,'trend',type);
                        mode = 'trend';
                end
                if isempty(trade_signaltype)
                    volume_traded = 0;
                else
                    volume_traded = trade_signaltype.openvolume_*trade_signaltype.opendirection_;
                end
                if volume_target == volume_traded, continue;end
                
                if volume_target == 0 && volume_traded ~= 0
                    %unwind trade is required
                    %1.to check whether there is any pending unwind
                    %entrust associated with the trade which shall be
                    %unwinded
                    npending = strategy.helper_.entrustspending_.latest;
                    isunwindpending = false;
                    for jj = 1:npending
                        try
                            e = strategy.helper_.entrustspending_.node(jj);
                            if e.offsetFlag ~= -1, continue;end
                            if isempty(e.tradeid_), continue;end
                            if strcmpi(e.tradeid_, trade_signaltype.tradeid_)
                                isunwindpending = true;
                                break
                            end
                        catch
                        end
                    end
                    %do nothing if there is a unwind entrust pending
                    if isunwindpending, continue;end
                    %2.unwind the trade if there is no unwind entrust
                    %pending
                    strategy.unwindtrade(trade_signaltype);
                    %
                elseif volume_target ~= 0 && volume_traded == 0
%                     %place trade is required
%                     %1.to check whether there is any pending open
%                     %entrust
%                     npending = strategy.helper_.entrustspending_.latest;
%                     isopenpending = false;
%                     for jj = 1:npending
%                         try
%                             e = strategy.helper_.entrustspending_.node(jj);
%                             if e.offsetFlag ~= 1, continue; end
%                             if isempty(e.signalinfo_), continue; end
%                             if strcmpi(e.signalinfo_.type,type)
%                                 isopenpending = true;
%                                 break
%                             end
%                         catch
%                         end
%                     end
%                     %do nothing if there is a open entrust pending
%                     if isopenpending, continue;end
%                     %2.open the trade if there is no open entrust
%                     %pending
%                     samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
%                     bs = strategy.tdbuysetup_{i};
%                     ss = strategy.tdsellsetup_{i};
%                     bc = strategy.tdbuycountdown_{i};
%                     sc = strategy.tdsellcountdown_{i};
%                     levelup = strategy.tdstlevelup_{i};
%                     leveldn = strategy.tdstleveldn_{i};
%                     scenarioname = tdsq_getscenarioname(bs,ss,levelup,leveldn,bc,sc,p);
%                     signal = struct('name','tdsq',...
%                         'instrument',instruments{i},'frequency',samplefreqstr,...
%                         'scenarioname',scenarioname,...
%                         'mode',mode,'type',type,...
%                         'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99,...
%                         'direction',sign(volume_target));
%                     if strcmpi(type,'perfectbs')
%                         ibs = find(bs == 9,1,'last');
%                         truelow = min(p(ibs-8:ibs,4));
%                         idxtruelow = find(p(ibs-8:ibs,4) == truelow,1,'first');
%                         idxtruelow = idxtruelow + ibs - 9;
%                         truelowbarsize = p(idxtruelow,3) - truelow;
%                         risklvl = truelow - truelowbarsize;
%                         %TODO:consistent with the gensignalcode
%                         signal.risklvl = risklvl;                        
%                     elseif strcmpi(type,'perfectss')
%                         iss = find(ss == 9,1,'last');
%                         truehigh = min(p(iss-8:iss,3));
%                         idxtruehigh = find(p(iss-8:iss,3) == truehigh,1,'first');
%                         idxtruehigh = idxtruehigh + iss - 9;
%                         truehighbarsize = truehigh - p(idxtruehigh,4);
%                         risklvl = truehigh + truehighbarsize;
%                         %TODO:consistent with the gensignalcode
%                         signal.risklvl = risklvl;
%                     end
%                     %
%                     if volume_target > 0
%                         strategy.longopen(instruments{i}.code_ctp,volume_target,'spread',0,'signalinfo',signal);
%                     else
%                         strategy.shortopen(instruments{i}.code_ctp,volume_target,'spread',0,'signalinfo',signal);
%                     end
%                     %
                elseif volume_target ~= 0 && volume_traded ~= 0
                    %TODO
                    fprintf('NOT IMPLEMENTED!!!\n')
                else
                    fprintf('NOT IMPLEMENTED!!!\n')
                end
            end
        end
    end
    
    n = strategy.helper_.entrustspending_.latest;
    for jj = 1:n
        try
            e = strategy.helper_.entrustspending_.node(jj);
            if e.offsetFlag ~= 1, continue; end
            if isempty(e.signalinfo_), continue; end
            signalmode = e.signalinfo_.mode;
            signaltype = e.signalinfo_.type;
        
            trade_signaltype = strategy.getlivetrade_tdsq(e.instrumentCode,signalmode,signaltype);
            if isempty(trade_signaltype)
                ret = strategy.withdrawentrusts(e.instrumentCode,'time',dtnum,'direction',e.direction,'offset',1,'price',e.price,'volume',e.volume);
                if ret
                    %the entrust has not been executed but canceled
                    %then we need to replace an order
                    if e.direction == 1
                        strategy.longopen(e.instrumentCode,e.volume,'spread',0,'signalinfo',e.signalinfo_);
                    elseif e.direction == -1
                        strategy.shortopen(e.instrumentCode,e.volume,'spread',0,'signalinfo',e.signalinfo_);
                    end
                else
                    %the entrust has not been canceled
                end
            end
        catch
            %DONOTHING
        end
    end     

    %
    %
    % check whether there are any pending close orders every 3 seconds
    n = strategy.helper_.entrustspending_.latest;
    for jj = 1:n
        try
            e = strategy.helper_.entrustspending_.node(jj);
            if e.offsetFlag ~= -1, continue; end
            if isempty(e.tradeid_), continue;end
            ret = strategy.withdrawentrusts(e.instrumentCode,'time',dtnum,'tradeid',e.tradeid_);
            if ret == 1
                %the entrust has not been executed but canceled
                %then we need to replace an order
                if e.direction == 1
                    ret2 = strategy.longclose(e.instrumentCode,e.volume,e.closetodayFlag,'spread',0,'tradeid',e.tradeid_);
                    if ~ret2
                        fprintf('WARNING:UNWIND ENTRUST FAILED TO BE REPLACED,PLS CHECK!!!\n');
                    end
                elseif e.direction == -1
                    ret2 = strategy.shortclose(e.instrumentCode,e.volume,e.closetodayFlag,'spread',0,'tradeid',e.tradeid_);
                    if ~ret2
                        fprintf('WARNING:UNWIND ENTRUST FAILED TO BE REPLACED,PLS CHECK!!!\n');
                    end
                end
            elseif ret == -1
                %ONLY HAPPENS IN REALTIME MODE
                %TODO
            else
                %ONLY HAPPENS IN REALTIME MODE
                %the entrust has not been canceled
            end
        catch
            %DONOTHING
        end
    end        
    
end