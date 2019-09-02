function [is2closetrade,entrustplaced] = riskmanagement_simpletrend(strategy,tradein,varargin)
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
    
    bs = strategy.tdbuysetup_{idx};
    ss = strategy.tdsellsetup_{idx};
    bc = strategy.tdbuycountdown_{idx};
    sc = strategy.tdsellcountdown_{idx};
    
    macdvec = strategy.macdvec_{idx};
    sigvec = strategy.nineperma_{idx};
    
    diffvec = macdvec - sigvec;
    
    if tradein.opendirection_ == 1
         if diffvec(end) < 0 || bs(end) >= 3 || ss(end) >= 24 || sc(end) >= 12
             is2closetrade = true;
             entrustplaced = strategy.unwindtrade(tradein);
             typeidx = cTDSQInfo.gettypeidx('simpletrend');
             strategy.targetportfolio_(idx,typeidx) = 0;
             return
         end
    elseif tradein.opendirection_ == -1
        if diffvec(end) > 0 || ss(end) >= 3 || bs(end) >= 24 || bc(end) >= 12
             is2closetrade = true;
             entrustplaced = strategy.unwindtrade(tradein);
             typeidx = cTDSQInfo.gettypeidx('simpletrend');
             strategy.targetportfolio_(idx,typeidx) = 0;
             return
        end
    end
    



end

