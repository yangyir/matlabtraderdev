function [is2closetrade,entrustplaced] = riskmanagement_semiperfectss(strategy,tradein,varargin)
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
%     bs = strategy.tdbuysetup_{idx};
    ss = strategy.tdsellsetup_{idx};
%     bc = strategy.tdbuycountdown_{idx};
%     sc = strategy.tdsellcountdown_{idx};
%     lvlup = strategy.tdstlevelup_{idx};
%     lvldn = strategy.tdstleveldn_{idx};
    macdvec = strategy.macdvec_{idx};
    sigvec = strategy.nineperma_{idx};
    tag = strategy.tags_{idx};
    
    if strcmpi(tag,'perfectbs')
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx('semiperfectss');
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    riskmode = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','riskmode');
    usesetups = strcmpi(riskmode,'macd-setup');
    
    if (macdvec(end) > sigvec(end) || (ss(end) >= 4 && usesetups))
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx('semiperfectss');
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    %additional risk management for imperfectbs/semi-perfectbs trade
    if strcmpi(tradein.opensignal_.scenario_,'doublerange-breachdnlvlup') && ...
            p(end,4) > tradein.opensignal_.lvlup_
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx('semiperfectss');
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    %
    if ~isempty(strfind(tradein.opensignal_.scenario_,'breachdnlvldn')) && ...
            p(end,4) > tradein.opensignal_.lvldn_
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx('semiperfectss');
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    isdoublerange = ~isempty(strfind(tradein.opensignal_.scenario_,'doublerange'));
    issinglebullish = ~isempty(strfind(tradein.opensignal_.scenario_,'singlebullish'));
    isdoublebullish = ~isempty(strfind(tradein.opensignal_.scenario_,'doublebullish'));
    
    if isdoublerange || issinglebullish
        openidx = find(p(:,1) <= tradein.opendatetime1_,1,'last')-1;
        if isempty(openidx),openidx = 1;end
        if openidx == 0, openidx = 1;end
        lvldn = tradein.opensignal_.lvldn_;
        hasbreachedlvldn = ~isempty(find(p(openidx:end,5) < lvldn,1,'first'));
        if hasbreachedlvldn && p(end,5) - lvldn >= 4*tradein.instrument_.tick_size
            is2closetrade = true;
            entrustplaced = strategy.unwindtrade(tradein);
            typeidx = cTDSQInfo.gettypeidx('semiperfectss');
            strategy.targetportfolio_(idx,typeidx) = 0;
        end
        return
    end
    %
    if isdoublebullish
        openidx = find(p(:,1) <= tradein.opendatetime1_,1,'last')-1;
        if isempty(openidx),openidx = 1;end
        if openidx == 0, openidx = 1;end
        lvlup = tradein.opensignal_.lvlup_;
        hasbreachedlvlup = ~isempty(find(p(openidx:end,5) < lvlup,1,'first'));
        if hasbreachedlvlup && p(end,5) - lvlup >= 4*tradein.instrument_.tick_size
            is2closetrade = true;
            entrustplaced = strategy.unwindtrade(tradein);
            typeidx = cTDSQInfo.gettypeidx('semiperfectss');
            strategy.targetportfolio_(idx,typeidx) = 0;
        end
        return
    end

end