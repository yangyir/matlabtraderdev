function [is2closetrade,entrustplaced] = riskmanagement_singlelvldn(strategy,tradein,varargin)
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
%     lvlup = strategy.tdstlevelup_{idx};
%     lvldn = strategy.tdstleveldn_{idx};
    bc = strategy.tdbuycountdown_{idx};
    sc = strategy.tdsellcountdown_{idx};
    macdvec = strategy.macdvec_{idx};
    sigvec = strategy.nineperma_{idx};
    tag = strategy.tags_{idx};
%     tag = tdsq_lastbs(bs,ss,lvlup,lvldn,bc,sc,p);
    
    riskmode = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','riskmode');
    usesetups = strcmpi(riskmode,'macd-setup');
    
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
                typeidx = cTDSQInfo.gettypeidx('single-lvldn');
                strategy.targetportfolio_(idx,typeidx) = 0;
                return
            end
        end
        %
        if macdvec(end) < sigvec(end) || (usesetups && bs(end) >= 4) || ...
                ss(end) >= 24 || sc(end) == 13 || ...
                p(end,3) < tradein.opensignal_.lvldn_
            entrustplaced = strategy.unwindtrade(tradein);
            is2closetrade = true;
            typeidx = cTDSQInfo.gettypeidx('single-lvldn');
            strategy.targetportfolio_(idx,typeidx) = 0;
            return
        end
        %
    elseif tradein.opendirection_ == -1 
        if bs(end) == 9
            low6 = p(end-3,4);
            low7 = p(end-2,4);
            low8 = p(end-1,4);
            low9 = p(end,4);
            close8 = p(end-1,5);
            close9 = p(end,5);
            %unwind the trade if the buysetup sequentia itself is perfect
            hasperfectbs = (low8 < min(low6,low7) || low9 < min(low6,low7)) && (close9<close8);
            if hasperfectbs && (p(end,3)>tradein.opensignal_.lvldn_)
                entrustplaced = strategy.unwindtrade(tradein);
                is2closetrade = true;
                typeidx = cTDSQInfo.gettypeidx('single-lvldn');
                strategy.targetportfolio_(idx,typeidx) = 0;
                return
            end
        end
        %
        if macdvec(end) > sigvec(end) || (usesetups && ss(end) >= 4) || ...
                bs(end) >= 24 || bc(end) == 13 || ...
                p(end,4) > tradein.opensignal_.lvldn_
            entrustplaced = strategy.unwindtrade(tradein);
            is2closetrade = true;
            typeidx = cTDSQInfo.gettypeidx('single-lvldn');
            strategy.targetportfolio_(idx,typeidx) = 0;
            return
        end
        %
    end
    
end