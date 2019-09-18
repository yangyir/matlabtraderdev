function [is2closetrade,entrustplaced] = riskmanagement_singlelvlup(strategy,tradein,varargin)
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
    
%     tag = tdsq_lastss(bs,ss,lvlup,lvldn,bc,sc,p);
    riskmode = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','riskmode');
    usesetups = strcmpi(riskmode,'macd-setup');

    if tradein.opendirection_ == -1
        if strcmpi(tag,'perfectbs')
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
                typeidx = cTDSQInfo.gettypeidx('single-lvlup');
                strategy.targetportfolio_(idx,typeidx) = 0;
                return
            end
        end
        %
        if macdvec(end) > sigvec(end) || (usesetups && ss(end) >= 4) || ...
                bs(end) >= 24 || bc(end) == 13 || ...
                p(end,4) > tradein.opensignal_.lvlup_
            entrustplaced = strategy.unwindtrade(tradein);
            is2closetrade = true;
            typeidx = cTDSQInfo.gettypeidx('single-lvlup');
            strategy.targetportfolio_(idx,typeidx) = 0;
            return
        end
        %
    elseif tradein.opendirection_ == 1
        if ss(end) == 9
            high6 = p(end-3,3);
            high7 = p(end-2,3);
            high8 = p(end-1,3);
            high9 = p(end,3);
            close8 = p(end-1,5);
            close9 = p(end,5);
            %unwind the trade if the sellsetup sequential itself is perfect
            hasperfectss = (high8 > max(high6,high7) || high9 > max(high6,high7)) && (close9>close8);
            if hasperfectss && (p(end,4)<tradein.opensignal_.lvlup_)
                entrustplaced = strategy.unwindtrade(tradein);
                is2closetrade = true;
                typeidx = cTDSQInfo.gettypeidx('single-lvlup');
                strategy.targetportfolio_(idx,typeidx) = 0;
                return
            end
        end
        %
        if macdvec(end) < sigvec(end) || (usesetups && ss(end) >= 4) || ...
                ss(end) >= 24 || sc(end) == 13 || ...
                p(end,3) < tradein.opensignal_.lvlup_
            entrustplaced = strategy.unwindtrade(tradein);
            is2closetrade = true;
            typeidx = cTDSQInfo.gettypeidx('single-lvlup');
            strategy.targetportfolio_(idx,typeidx) = 0;
            return
        end
        %
    end
end