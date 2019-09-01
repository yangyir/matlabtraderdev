function [is2closetrade,entrustplaced] = riskmanagement_semiperfectbs(strategy,tradein,varargin)
%cStratFutMultiTDSQ
    is2closetrade = false;
    entrustplaced = false;
    
    if isempty(tradein), return; end
    
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
    lvlup = strategy.tdstlevelup_{idx};
    lvldn = strategy.tdstleveldn_{idx};
    macdvec = strategy.macdvec_{idx};
    sigvec = strategy.nineperma_{idx};
    
    tag = tdsq_lastss(bs,ss,lvlup,lvldn,bc,sc,p);
    
    if strcmpi(tag,'perfectss9')
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx('semiperfectbs');
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    
    if (macdvec(end) < sigvec(end) || bs(end) >= 4)
        is2closetrade = true;
        entrustplaced = strategy.unwindtrade(tradein);
        typeidx = cTDSQInfo.gettypeidx('semiperfectbs');
        strategy.targetportfolio_(idx,typeidx) = 0;
        return
    end
    

end