function [ closeflag,closestr ] = tdsq_riskmanagement( trade,extrainfo )
    if ~isa(trade,'cTradeOpen')
        error('tdsq_riskmanagement:invalid trade input')
    end
    
    if ~isstruct(extrainfo)
        error('tdsq_riskmanagement:invalid extrainfo input')
    end
    
    if strcmpi(obj.trade_.opensignal_.frequency_,'daily')
        idxopen = find(extrainfo.p(:,1) <= trade.opendatetime1_,1,'last');
    else
        idxopen = find(extrainfo.p(:,1) <= trade.opendatetime1_,1,'last')-1;
    end
    
    if isempty(idxopen)
        error('tdsq_riskmanagement:mismatch between trade and extrainfo')
    end
    
    closeflag = 0;
    closestr = 'n/a';
    
    if strcmpi(trade.status_,'closed') || strcmpi(trade.riskmanager_.status_,'closed')
        closeflag = 1;
        closestr = trade.riskmanager_.closestr_;
        return
    end
    
    direction = trade.opendirection_;
    
    p = extrainfo.p;
    hh = extrainfo.hh;
    ll = extrainfo.ll;
    lips = extrainfo.lips;
    teeth = extrainfo.teeth;
    jaw = extrainfo.jaw;
    
    if direction == 1
        lvlup = extrainfo.lvlup;
        %STOP the trade if it fails to breaches TDST-lvlup,i.e.the high
        %price fell below lvlup
        if ~isempty(find(p(idxopen:end-1,5)>lvlup(end-1),1,'first')) && ...
                p(end,3)<lvlup(end-1)
            closeflag = 1;
            closestr = 'candle failed to breach TDST lvlup';
            return
        end
        %IF TDST-lvlup exists and is higher then HH at open
        %then one of the candle's high price has breached TDST-lvlup but
        %its close price is below TDST-lvlup,STOP the trade is the close
        %price falls below HH again      
        if lvlup(idxopen-1) > hh(idxopen-1) && p(end,5) < lvlup(idxopen-1)
            lvlupopen = lvlup(idxopen-1);
            hhopen = hh(idxopen-1);
            conditionsatisfied = false;
            for ii = idxopen:size(p,1)
                if p(ii,3) > lvlupopen && p(ii,5) < lvlupopen
                    conditionsatisfied = true;
                    break
                end
            end
            if conditionsatisfied && p(end,5) < hhopen && ...
                    p(end,5)<max([lips(end),teeth(end),jaw(end)])
                closeflag = 1;
                closestr = 'candle fell from above TDST lvlup to below HH again';
                return
            end
        end
        %
        
    elseif direction == -1
        lvldn = extrainfo.lvldn;
        %STOP the trade if it fails to breaches TDST-lvldn,i.e.the low
        %price stayed above lvldn
        if ~isempty(find(p(idxopen:end-1,5)<lvldn(end-1),1,'first')) && ...
                p(end,4)>lvldn(end-1)
            closeflag = 1;
            closestr = 'candle failed to breach TDST lvldn';
            return
        end
        %IF TDST-lvldn exists and is lower then LL at open
        %then one of the candle's low price has breached TDST-lvldn but
        %its close price is be above TDST-lvldn,STOP the trade is the close
        %price rallies above LL again
        if lvldn(idxopen-1) < ll(idxopen-1) && p(end,5) > lvldn(idxopen-1)
            lvldnopen = lvldn(idxopen-1);
            llopen = ll(idxopen-1);
            conditionsatisfied = false;
            for ii = idxopen:size(p,1)
                if p(ii,4) < lvldnopen && p(ii,5) > lvldnopen
                    conditionsatisfied = true;
                    break
                end
            end
            if conditionsatisfied && p(end,5) > llopen && ...
                    p(end,5)>min([lips(end),teeth(end),jaw(end)])
                closeflag = 1;
                closestr = 'candle fell from below TDST lvldn to above LL again';
                return
            end
        end
        
    end


end

