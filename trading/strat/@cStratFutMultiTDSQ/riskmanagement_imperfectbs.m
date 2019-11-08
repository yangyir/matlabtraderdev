function [is2closetrade,entrustplaced] = riskmanagement_imperfectbs(strategy,tradein,varargin)
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
    sc = strategy.tdsellcountdown_{idx};
    macdss = strategy.macdss_{idx};
    macdvec = strategy.macdvec_{idx};
    sigvec = strategy.nineperma_{idx};
    tag = strategy.tags_{idx};
    tradetype = tradein.opensignal_.type_;
    
    %perfectsetup
%     if strcmpi(tag,'perfectss')
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
    if (macdvec(end) - sigvec(end) < -5e-4 || (bs(end) >= 4 && usesetups)) ...
            || ss(end) >= 24 || sc(end) == 13
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx(tradetype);
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    %additional risk management for imperfectbs/semi-perfectbs trade
    israngereverse = ~isempty(strfind(tradein.opensignal_.scenario_,'range-reverse'));
    isbreach = strcmpi(tradein.opensignal_.scenario_,'breach');
    israngebreach = ~isempty(strfind(tradein.opensignal_.scenario_,'range-breach'));
    newlvlup = tradein.opensignal_.lvlup_;
    oldlvldn = tradein.opensignal_.lvldn_;
    isdoublebearish = false;
    if ~isnan(oldlvldn)
        isdoublebearish = newlvlup < oldlvldn;
    end
    
    %reverseback
    if israngereverse && p(end,3) < oldlvldn
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx(tradetype);
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    %breachbounceback1
    if isbreach && p(end,3) < newlvlup
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx(tradetype);
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    %rangebreachsetuplimit
    if israngebreach && ss(end) == 9
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
    if israngereverse && ~isempty(find(macdss(openidx:end) == 20,1,'last')) && macdss(end) == 0
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx(tradetype);
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    if ~isdoublebearish
        hasbreachedlvlup = ~isempty(find(p(openidx:end,5) > newlvlup,1,'first'));
        %breachbounceback2
        if hasbreachedlvlup && p(end,5) - newlvlup < -4*instrument.tick_size
            is2closetrade = true;
            entrustplaced = strategy.unwindtrade(tradein);
            typeidx = cTDSQInfo.gettypeidx(tradetype);
            strategy.targetportfolio_(idx,typeidx) = 0;
            return
        end
    else
        hasbreachedlvldn = ~isempty(find(p(openidx:end,5) > oldlvldn,1,'first'));
        %breachbounceback3
        if hasbreachedlvldn && p(end,5) - oldlvldn < -4*instrument.tick_size
            is2closetrade = true;
            entrustplaced = strategy.unwindtrade(tradein);
            typeidx = cTDSQInfo.gettypeidx(tradetype);
            strategy.targetportfolio_(idx,typeidx) = 0;
            return
        end
    end

end