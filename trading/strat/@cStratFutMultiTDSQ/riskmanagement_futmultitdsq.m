function [] = riskmanagement_futmultitdsq(strategy,dtnum)
%cStratFutMultiTDSQ
    % one minute before market open to refresh targetportfolio_ with loaded
    % trades information
    runningmm = hour(dtnum)*60+minute(dtnum);
    if (runningmm >= 539 && runningmm < 540) || ...
            (runningmm >= 779 && runningmm < 780) || ...
            (runningmm >= 1259 && runningmm < 1260)
        trades = strategy.helper_.trades_;
        for itrade = 1:trades.latest_
            trade_i = trades.node_(itrade);
            if strcmpi(trade_i.status_,'closed'), continue;end
            if isa(trade_i.opensignal_,'cTDSQInfo')
                [~,idxrow] = strategy.hasinstrument(trade_i.instrument_);
                idxcol = cTDSQInfo.gettypeidx(trade_i.opensignal_.type_);
                volume_traded = trade_i.opendirection_*trade_i.openvolume_;
                volume_target = strategy.targetportfolio_(idxrow,idxcol);
                if volume_target == 0
                    strategy.targetportfolio_(idxrow,idxcol) = volume_traded;
                else
                    if volume_target ~= volume_traded
                        fprintf('%s:inconsistent traded and target volume found of %6s in %s\n',...
                            strategy.name_,trade_i.instrument_.code_ctp,trade_i.opensignal_.type_);
                    end
                end
            end
        end
    end
    %
    %
    % unwind all positions before public holidays
    if (runningmm == 899 || runningmm == 914) && second(dtnum) >= 56
        cobd = floor(dtnum);
        nextbd = businessdate(cobd);
        if nextbd - cobd > 3
            trades = strategy.helper_.trades_;
            for itrade = 1:trades.latest_
                trade_i = trades.node_(itrade);
                if strcmpi(trade_i.status_,'closed'), continue;end
                if isa(trade_i.opensignal_,'cTDSQInfo')
                    [~,idxrow] = strategy.hasinstrument(trade_i.instrument_);
                    idxcol = cTDSQInfo.gettypeidx(trade_i.opensignal_.type_);
                    if strategy.targetportfolio_(idxrow,idxcol) ~= 0
                        %avoid unwindtrade to be called several time as
                        %this function itself cannot guarantee that the
                        %placed entrust is filled and thus whether the real
                        %position is unwinded
                        strategy.unwindtrade(trade_i);
                        strategy.targetportfolio_(idxrow,idxcol) = 0;
                    end
                end
            end
        end 
    end

    % check whether there are any pending open orders every x seconds
    runpendingordercheck = mod(floor(second(dtnum)),3) == 0;
    % check target portfolio every minute
    runtargetportfoliocheck = second(dtnum) > 59;
    
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
                    case {'perfectss','semiperfectss','imperfectss'}
                        trade_signaltype = strategy.getlivetrade_tdsq(instruments{i}.code_ctp,'reverse',type);
                    otherwise
                        trade_signaltype = strategy.getlivetrade_tdsq(instruments{i}.code_ctp,'trend',type);
                end
                if isempty(trade_signaltype)
                    volume_traded = 0;
                else
                    volume_traded = trade_signaltype.openvolume_*trade_signaltype.opendirection_;
                end
                
                if volume_target == volume_traded, continue;end
                
                if volume_target == 0 && volume_traded ~= 0
                    %unwind trade is required
                    %1.to check whether there is any unwind entrust(s)
                    %associated with the trade itself
                    ne = strategy.helper_.entrusts_.latest;
                    isunwindfinished = false;
                    isunwindpending = false;
                    for jj = 1:ne
                        e = strategy.helper_.entrusts_.node(jj);
                        if e.offsetFlag ~= -1, continue;end
                        if isempty(e.tradeid_), continue;end
                        if ~strcmpi(e.tradeid_, trade_signaltype.tradeid_), continue;end
                        if e.is_entrust_filled && ~strcmpi(trade_signaltype.status,'closed')
                            %in case the entrust is filled but trade info
                            %failed to be updated
                            trade_signaltype.status_ = 'closed';
                            trade_signaltype.closedatetime1_ = e.complete_time_;
                            trade_signaltype.closeprice_ = e.price;
                            trade_signaltype.runningpnl_ = 0;
                            trade_signaltype.closepnl_ = trade_signaltype.opendirection_*trade_signaltype.openvolume_*(e.price-trade_signaltype.openprice_)/ instrument.tick_size * instrument.tick_value; 
                            isunwindfinished = true;
                            break
                        end
%                         if e.is_entrust_canceled && strcmpi(trade_signaltype.status,'closed')
%                             break
%                         end
                        if ~e.is_entrust_canceled && e.dealVolume < e.volume
                            isunwindpending = true;
                            break
                        end
                    end
                    %do nothing if there is a unwind entrust pending or
                    %finished
                    if isunwindpending || isunwindfinished, continue;end
                    %2.unwind the trade if there is no unwind entrust
                    %pending
                    strategy.unwindtrade(trade_signaltype);
                    %
                elseif volume_target ~= 0 && volume_traded == 0
                    ne = strategy.helper_.entrusts_.latest;
                    isopenfinished = false;
                    isopenpending = false;
                    for jj = 1:ne
                        e = strategy.helper_.entrusts_.node(jj);
                        if e.offsetFlag ~= 1, continue;end
                        if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end
                        if isempty(e.signalinfo_), continue;end
                        if ~strcmpi(e.signalinfo_.name,'tdsq'), continue;end
                        if ~strcmpi(e.signalinfo_.type,type), continue;end
                        if volume_target ~= e.volume, continue;end
                        if e.is_entrust_filled
                            trade = cTradeOpen('id',e.tradeid_,...
                                'countername',strategy.helper_.book_.countername_,...
                                'bookname',strategy.helper_.book_.bookname_,...
                                'code',e.instrumentCode,...
                                'opendatetime',e.complete_time_,...
                                'openvolume',e.dealVolume,...
                                'openprice',e.dealPrice,...
                                'opendirection',e.direction);
                            trade.setsignalinfo('name',e.signalinfo_.name,'extrainfo',e.signalinfo_);
                            strategy.helper_.trades_.push(trade);
                            isopenfinished = true;
                            break
                        end
                        if e.is_entrust_canceled
                            %we may cancle more than one entrust
                        end
                        if ~e.is_entrust_canceled && e.dealVolume < e.volume
                            isopenpending = true;
                            break
                        end
                    end
                    %do nothing if there is a open entrust pending or
                    %finished
                    if isopenfinished || isopenpending, continue;end
                    %todo;
                    %place orders afterwards

                elseif volume_target ~= 0 && volume_traded ~= 0
                    %TODO
                    fprintf('NOT IMPLEMENTED!!!\n')
                else
                    fprintf('NOT IMPLEMENTED!!!\n')
                end
            end
        end
    end
    
    
    % check whether there are any pending open orders
    n = strategy.helper_.entrustspending_.latest;
    for jj = 1:n
        try
            e = strategy.helper_.entrustspending_.node(jj);
            if e.offsetFlag ~= 1, continue; end
            %signalinfo_ is a struct
            if isempty(e.signalinfo_), continue; end
            signalmode = e.signalinfo_.mode;
            signaltype = e.signalinfo_.type;
        
            trade_signaltype = strategy.getlivetrade_tdsq(e.instrumentCode,signalmode,signaltype);
            if isempty(trade_signaltype)
                ret = strategy.withdrawentrusts(e.instrumentCode,'time',dtnum,'tradeid',e.tradeid_);
                if ret
                    %the entrust has not been executed but canceled
                    %then we need to replace an order
                    strategy.helper_.updateentrustsandbook2;
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
    % check whether there are any pending close orders
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
                strategy.helper_.updateentrustsandbook2;
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