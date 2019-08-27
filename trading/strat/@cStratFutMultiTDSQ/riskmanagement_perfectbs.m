function [] = riskmanagement_perfectbs(strategy,tradein,varargin)
%cStratFutMultiTDSQ
    instrument = tradein.instrument_;
    [~,idx] = strategy.hasinstrument(instrument);
    if idx < 0, return;end
    
    includelastcandle = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','includelastcandle');
    candlesticks = strategy.mde_fut_.getallcandles(instrument);
    p = candlesticks{1};
    if ~includelastcandle, p = p(1:end-1,:);end
    idxkeep = ~(p(:,2)==p(:,3)&p(:,2)==p(:,4)&p(:,2)==p(:,5));
    p = p(idxkeep,:);
    
    %case 1 stop
    risklvl = tradein.opensignal_.risklvl_;
    if p(end,5) < risklvl
        strategy.unwindtrade(tradein);
        return
    end

    %case 2 any ss scenario afterwards when macd turns bearish
    bs = strategy.tdbuysetup_{idx};
    ss = strategy.tdsellsetup_{idx};
    macdvec = strategy.macdvec_{idx};
    sigvec = strategy.nineperma_{idx};
    
    bsidxlatest = find(bs == 9,1,'last');
    ssidxlatest = find(ss == 9,1,'last');
    if ssidxlatest > bsidxlatest && (macdvec(end) < sigvec(end) || bs(end) >= 4)
        strategy.unwindtrade(tradein);
        return
    end
    
    %case 3:any breach of lvlup afterwards when macd turns bearish
    tradeopentime = tradein.opendatetime1_;
    idxstart2check = find(p(:,1) <= tradeopentime,1,'last');
    lvlup = tradein.opensignal_.lvlup_;
    breachlvlup = false;
    breachidx = [];
    for i = idxstart2check:size(p,1)
        if p(i,5) > lvlup
            breachlvlup = true;
            breachidx = i;
            break
        end
    end
    if breachlvlup
        wasmacdbullish = false;
        for i = breachidx:size(p,1)
            if macdvec(i) > sigvec(i)
                wasmacdbullish = true;
                break
            end
        end
        if wasmacdbullish && (macdvec(end) < sigvec(end) || bs(end) >= 4)
            strategy.unwindtrade(tradein);
            return
        end
    end 
    
end