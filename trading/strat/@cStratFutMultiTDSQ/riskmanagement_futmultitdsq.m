function [] = riskmanagement_futmultitdsq(strategy,dtnum)
%cStratFutMultiTDSQ   
    % check whether there are any pending open orders every 3 seconds
    runpendingordercheck = mod(floor(second(dtnum)),3) == 0;
    % check target portfolio every minute
    runtargetportfoliocheck = floor(second(dtnum)) == 59;
    
    if ~runpendingordercheck && ~runtargetportfoliocheck, return;end
    
    if runtargetportfoliocheck
        instruments = strategy.getinstruments;
        for i = 1:strategy.count
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
                if volume_target ~= volume_traded
                    %TODO
                    fprintf('inconsistence between target and traded portfolio...\n');
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