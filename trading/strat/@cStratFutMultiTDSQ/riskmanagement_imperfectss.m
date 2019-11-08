function [is2closetrade,entrustplaced] = riskmanagement_imperfectss(strategy,tradein,varargin)
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
    ss = strategy.tdsellsetup_{idx};
    bs = strategy.tdbuysetup_{idx};
    bc = strategy.tdbuycountdown_{idx};
    macdvec = strategy.macdvec_{idx};
    sigvec = strategy.nineperma_{idx};
    macdbs = strategy.macdbs_{idx};
    tag = strategy.tags_{idx};
    tradetype = tradein.opensignal_.type_;
    
    %perfectsetup
%     if strcmpi(tag,'perfectbs')
%         is2closetrade = true;
%         entrustplaced = strategy.unwindtrade(tradein);
%         typeidx = cTDSQInfo.gettypeidx(tradetype);
%         strategy.targetportfolio_(idx,typeidx) = 0;
%         return
%     end
    
    riskmode = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','riskmode');
    usesetups = strcmpi(riskmode,'macd-setup');
    
    %macd
    %setuplimit
    %countdown13
    if (macdvec(end) - sigvec(end) > 5e-4 || (ss(end) >= 4 && usesetups)) ...
            || bs(end) >= 24 || bc(end) == 13
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx(tradetype);
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    %additional risk management for imperfectss/semi-perfectss trade
    israngereverse = ~isempty(strfind(tradein.opensignal_.scenario_,'range-reverse'));
    isbreach = strcmpi(tradein.opensignal_.scenario_,'breach');
    israngebreach = ~isempty(strfind(tradein.opensignal_.scenario_,'range-breach'));
    oldlvlup = tradein.opensignal_.lvlup_;
    newlvldn = tradein.opensignal_.lvldn_;
    isdoublebullish = false;
    if ~isnan(oldlvlup)
        isdoublebullish = newlvldn > oldlvlup;
    end
    
    %reversebounceback
    if israngereverse && p(end,4) > oldlvlup
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx(tradetype);
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    %breachbounceback1
    if isbreach && p(end,4) > newlvldn
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx(tradetype);
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    %rangebreachsetuplimit
    if israngebreach && bs(end) == 9
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx(tradetype);
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    openidx = find(p(:,1) <= tradein.opendatetime1_,1,'last')-1;
    if isempty(openidx),openidx = 1;end
    if openidx == 0, openidx = 1;end
    
    %macdlimit
    if israngereverse && ~isempty(find(macdbs(openidx:end) == 20,1,'last')) && macdbs(end) == 0
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx(tradetype);
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    if ~isdoublebullish
        hasbreachedlvldn = ~isempty(find(p(openidx:end,5) < newlvldn,1,'first'));
        %breachbounceback2
        if hasbreachedlvldn && p(end,5) - newlvldn > 4*instrument.tick_size
            is2closetrade = true;
            entrustplaced = strategy.unwindtrade(tradein);
            typeidx = cTDSQInfo.gettypeidx(tradetype);
            strategy.targetportfolio_(idx,typeidx) = 0;
            return
        end
    else
        hasbreachedlvlup = ~isempty(find(p(openidx:end,5) < oldlvlup,1,'first'));
        %breachbounceback3
        if hasbreachedlvlup && p(end,5) - oldlvlup > 4*instrument.tick_size
            is2closetrade = true;
            entrustplaced = strategy.unwindtrade(tradein);
            typeidx = cTDSQInfo.gettypeidx(tradetype);
            strategy.targetportfolio_(idx,typeidx) = 0;
            return
        end
    end
    
end