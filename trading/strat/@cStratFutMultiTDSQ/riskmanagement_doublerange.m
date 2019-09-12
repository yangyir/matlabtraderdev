function [is2closetrade,entrustplaced] = riskmanagement_doublerange(strategy,tradein,varargin)
%cStratFutMultiTDSQ
    is2closetrade = false;
    entrustplaced = false;
    
    if isempty(tradein), return;end
    
    instrument = tradein.instrument_;
    [~,idx] = strategy.hasinstrument(instrument);
    if idx < 0, return;end
    
    includelastcandle = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','includelastcandle');
    candlesticks = strategy.mde_fut_.getallcandles(instrument);
    p = candlesticks{1};
    if ~includelastcandle, p = p(1:end-1,:);end
    idxkeep = ~(p(:,2)==p(:,3)&p(:,2)==p(:,4)&p(:,2)==p(:,5));
    p = p(idxkeep,:);
    
    %case 2 any ss scenario afterwards when macd turns bearish
    bs = strategy.tdbuysetup_{idx};
    ss = strategy.tdsellsetup_{idx};
    bc = strategy.tdbuycountdown_{idx};
    sc = strategy.tdsellcountdown_{idx};
%     lvlup = strategy.tdstlevelup_{idx};
%     lvldn = strategy.tdstleveldn_{idx};
    macdvec = strategy.macdvec_{idx};
    sigvec = strategy.nineperma_{idx};
    tag = strategy.tags_{idx};
    
    if tradein.opendirection_ == 1
        if strcmpi(tag,'perfectss')
            %check whether perfectss is still valid
            iss = find(ss == 9,1,'last');
            truehigh = max(p(iss-8:iss,3));
            idxtruehigh = find(p(iss-8:iss,3) == truehigh,1,'first');
            idxtruehigh = idxtruehigh + iss - 9;
            truehighbarsize = truehigh - p(idxtruehigh,4);
            stoploss = truehigh + truehighbarsize;
            if ~isempty(find(p(iss+1:end,5) > stoploss,1,'first'))
                stillvalid = false;
            else
                stillvalid = true;
            end
            if stillvalid
                entrustplaced = strategy.unwindtrade(tradein);
                is2closetrade = true;
                typeidx = cTDSQInfo.gettypeidx('double-range');
                strategy.targetportfolio_(idx,typeidx) = 0;
                return
            end
        end
        %
        if (macdvec(end) < sigvec(end) || (false && bs(end) >= 4)) || sc(end) == 13
            entrustplaced = strategy.unwindtrade(tradein);
            is2closetrade = true;
            typeidx = cTDSQInfo.gettypeidx('double-range');
            strategy.targetportfolio_(idx,typeidx) = 0;
            return
        end
        %
        sn = tradein.opensignal_.scenario_;
        if strcmpi(sn,'isbetween')
            openidx = find(p(:,1) <= tradein.opendatetime1_,1,'last')-1;
            hasbreachlvlup = ~isempty(find(p(openidx:end,5) > tradein.opensignal_.lvlup_,1,'first'));
            if hasbreachlvlup && p(end,3)<tradein.opensignal_.lvlup_
                entrustplaced = strategy.unwindtrade(tradein);
                is2closetrade = true;
                typeidx = cTDSQInfo.gettypeidx('double-range');
                strategy.targetportfolio_(idx,typeidx) = 0;
                return
            end
            %
        elseif strcmpi(sn,'isabove')
            if p(end,3)<tradein.opensignal_.lvlup_
                entrustplaced = strategy.unwindtrade(tradein);
                is2closetrade = true;
                typeidx = cTDSQInfo.gettypeidx('double-range');
                strategy.targetportfolio_(idx,typeidx) = 0;
                return
            end
            %
        elseif strcmpi(sn,'isbelow')
            %donothing
        else
            error('unknown sceanrio name in double-range')
        end
        %
    elseif tradein.opendirection_ == -1
        if strcmpi(tag,'perfectbs9')
            %check whether perfectbs is still valid
            ibs = find(bs == 9,1,'last');
            truelow= min(p(ibs-8:ibs,4));
            idxtruelow = find(p(ibs-8:ibs,4) == truelow,1,'first');
            idxtruelow = idxtruelow + ibs - 9;
            truelowbarsize_j = p(idxtruelow,3) - truelow;
            stoploss_j = truelow - truelowbarsize_j;
            if ~isempty(find(p(ibs+1:end,5) < stoploss_j,1,'first'))
                stillvalid = false;
            else
                stillvalid = true;
            end
            if stillvalid
                entrustplaced = strategy.unwindtrade(tradein);
                is2closetrade = true;
                typeidx = cTDSQInfo.gettypeidx('double-range');
                strategy.targetportfolio_(idx,typeidx) = 0;
                return
            end
        end
        %
        if (macdvec(end) > sigvec(end) || (false && ss(end) >= 4)) || bc(end) == 13
            entrustplaced = strategy.unwindtrade(tradein);
            is2closetrade = true;
            typeidx = cTDSQInfo.gettypeidx('double-range');
            strategy.targetportfolio_(idx,typeidx) = 0;
            return
        end
        %
        sn = tradein.opensignal_.scenario_;
        if strcmpi(sn,'isbetween')
            openidx = find(p(:,1) <= tradein.opendatetime1_,1,'last')-1;
            hasbreachlvldn = ~isempty(find(p(openidx:end,5) < tradein.opensignal_.lvldn_,1,'first'));
            if hasbreachlvldn && p(end,4)>tradein.opensignal_.lvldn_
                entrustplaced = strategy.unwindtrade(tradein);
                is2closetrade = true;
                typeidx = cTDSQInfo.gettypeidx('double-range');
                strategy.targetportfolio_(idx,typeidx) = 0;
                return
            end
            %
        elseif strcmpi(sn,'isabove')
            %do nothing
            %
        elseif strcmpi(sn,'isbelow')
            if p(end,4)>tradein.opensignal_.lvldn_
                entrustplaced = strategy.unwindtrade(tradein);
                is2closetrade = true;
                typeidx = cTDSQInfo.gettypeidx('double-range');
                strategy.targetportfolio_(idx,typeidx) = 0;
                return
            end           
        else
            error('unknown sceanrio name in double-range')
        end
    end        
end