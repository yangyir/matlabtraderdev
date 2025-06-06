function [ closeflag,closestr ] = tdsq_riskmanagement( trade,extrainfo )
    if ~isa(trade,'cTradeOpen')
        error('tdsq_riskmanagement:invalid trade input')
    end
    
    if ~isstruct(extrainfo)
        error('tdsq_riskmanagement:invalid extrainfo input')
    end
    
    if strcmpi(trade.opensignal_.frequency_,'daily')
        idxopen = find(extrainfo.p(:,1) <= trade.opendatetime1_,1,'last');
    else
        if isempty(strfind(trade.opensignal_.mode_,'conditional'))
            idxopen = find(extrainfo.p(:,1) <= trade.opendatetime1_,1,'last');
        else
            idxopen = find(extrainfo.p(:,1) <= trade.opendatetime1_,1,'last');
        end
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
    
    try
        ticksize = trade.instrument_.tick_size;
    catch
        ticksize = 0;
    end
       
    if direction == 1
%         if ~isnan(trade.riskmanager_.tdlow_) && extrainfo.ss(end) > 9
        if ~isnan(trade.riskmanager_.tdlow_)
            if p(end,5) - trade.riskmanager_.tdlow_+2*ticksize < 1e-6
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:ssbreak';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        %
        if isnan(trade.riskmanager_.td13low_)
            sc13last = find(extrainfo.sc == 13,1,'last');
            idxhhlast = find(extrainfo.idxhh == 1,1,'last');
            if idxhhlast <= sc13last
                trade.riskmanager_.td13low_ = extrainfo.p(sc13last,4);
            end
        end
        %
        if ~isnan(trade.riskmanager_.td13low_) && extrainfo.sc(end) ~= 13
            if p(end,5) < trade.riskmanager_.td13low_-ticksize
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:sc13break';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        lvlup = extrainfo.lvlup;
        %STOP the trade if it fails to breaches TDST-lvlup,i.e.the high
        %price fell below lvlup
        if ~isempty(find(p(idxopen:end-1,5)>lvlup(end-1),1,'first')) && ...
                p(end,3)<lvlup(end-1)
            if strcmpi(trade.opensignal_.mode_,'conditional-uptrendconfirmed-1')
                 closeflag = 1;
                 trade.riskmanager_.closestr_ = 'tdsq:candle failed to breach TDST lvlup';
                 closestr = trade.riskmanager_.closestr_;
                 return
            else
                if p(end,4)<lips(end)
                    closeflag = 1;
                    trade.riskmanager_.closestr_ = 'tdsq:candle failed to breach TDST lvlup';
                    closestr = trade.riskmanager_.closestr_;
                    return
                end
            end
%             trade.riskmanager_.pxstoploss_ = 0.382*lvlup(end-1)+0.618*trade.riskmanager_.hh0_;
            trade.riskmanager_.pxstoploss_ = 0.382*lvlup(end-1)+0.618*trade.riskmanager_.pxstoploss_;
            if ~isempty(trade.instrument_)
                ticksize = trade.instrument_.tick_size;
                trade.riskmanager_.pxstoploss_ = floor(trade.riskmanager_.pxstoploss_/ticksize)*ticksize;
            end
            trade.riskmanager_.closestr_ = 'tdsq:candle failed to breach TDST lvlup';
        end
        %STOP the trade if it was a conditional breachup-lvlup trade in
        %case it failed to breach fractal hh on open but its highest price
        %on open candle breached lvlup
        if (strcmpi(trade.opensignal_.mode_,'conditional-uptrendconfirmed-1') || ...
                strcmpi(trade.opensignal_.mode_,'conditional-breachuplvlup')) && ...
                p(idxopen,5)<hh(idxopen-1) && p(idxopen,3)>lvlup(idxopen-1) && p(idxopen-1,5)<lvlup(idxopen-1)
            if p(end,3) < lvlup(idxopen-1)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:candle failed to breach TDST lvlup';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        %STOP the trade if it opened below lvldn and breached up lvldn
        %afterwards but then fell back below lvldn again
        lvldn = extrainfo.lvldn;
        if p(idxopen,5)<lvldn(idxopen) && ~isempty(find(p(idxopen:end-1,5)>lvldn(idxopen:end-1),1,'first'))
            if p(end,3)<lvldn(end)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:candle failed to breach(up) TDST lvldn';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        %STOP the trade i
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
                    (p(end,5)<max([lips(end),teeth(end),jaw(end)])-2*ticksize || ...
                    p(end,3)<hhopen)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:candle fell from above TDST lvlup to below HH again';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        %
        ss = extrainfo.ss;
        if ss(end) >= 9
            high9 = extrainfo.p(end,3);
            high8 = extrainfo.p(end-1,3);
            high7 = extrainfo.p(end-2,3);
            high6 = extrainfo.p(end-3,3);
            close9 = extrainfo.p(end,5);
            close8 = extrainfo.p(end-1,5);
            if (high8 > max(high6,high7) || ...
                    high9 > max(high6,high7)) && ...
                    close9>close8 && ....
                    close9<extrainfo.lvlup(end) &&...
                    extrainfo.wad(end)-extrainfo.wad(end-1)>close9-close8
                %add another condition after carefully restudy the perfect
                %ss9 case, i.e. the market was below lvldn as the market
                %firstly rallied
                if extrainfo.lvldn(idxopen) > extrainfo.hh(idxopen)
                    closeflag = 1;
                    trade.riskmanager_.closestr_ = 'tdsq:perfectss9';
                    closestr = trade.riskmanager_.closestr_;
                    return
                end
            end
            %
            if (high8 > max(high6,high7) || ...
                    high9 > max(high6,high7)) && ...
                    close9>=close8 && ...
                    strcmpi(trade.opensignal_.mode_,'breachup-highsc13') && ...
                    ~(extrainfo.p(end-1,5)<extrainfo.hh(end-1) && extrainfo.p(end,5)>extrainfo.hh(end-1))
                flag = tdsq_is9139sellcount(extrainfo.bs,ss,extrainfo.bc,extrainfo.sc);
                if flag
                    closeflag = 1;
                    trade.riskmanager_.closestr_ = 'tdsq:9139';
                    closestr = trade.riskmanager_.closestr_;
                    return
                end
            end
            %
        end
        %
        if ss(end) >= 16 && ...
                (strcmpi(trade.opensignal_.mode_,'breachup-highsc13') ||...
                (~isempty(find(extrainfo.sc==13,1,'last')) && find(extrainfo.sc==13,1,'last') >= idxopen-1))
            %no more than ss16 in case it breached sc13
%             closeflag = 1;
            trade.riskmanager_.pxstoploss_ = max(trade.riskmanager_.pxstoploss_,extrainfo.p(end,4)-(extrainfo.p(end,3)-extrainfo.p(end,4)));
            trade.riskmanager_.closestr_ = 'tdsq:ss16';
            if ss(end) >= 21
                trade.riskmanager_.pxstoploss_ = max(trade.riskmanager_.pxstoploss_,extrainfo.p(end,4));
                trade.riskmanager_.closestr_ = ['tdsq:ss',num2str(ss(end))];
            end
            closestr = trade.riskmanager_.closestr_;
            return
        end
        if ss(end) >= 21
%             closeflag = 1;
            trade.riskmanager_.pxstoploss_ = max(trade.riskmanager_.pxstoploss_,extrainfo.p(end,4));
            trade.riskmanager_.closestr_ = ['tdsq:ss',num2str(ss(end))];
            closestr = trade.riskmanager_.closestr_;
            return
        end
        sc = extrainfo.sc;
        if sc(end) == 13
            if isnan(trade.riskmanager_.td13low_)
                trade.riskmanager_.td13low_ = extrainfo.p(end,4);
            else
                if extrainfo.p(end,4) < trade.riskmanager_.td13low_
                    trade.riskmanager_.td13low_ = extrainfo.p(end,4);
                end
            end
            %
            if ~isempty(strfind(trade.opensignal_.mode_,'conditional')) && ...
                p(idxopen,5)<hh(idxopen-1) && p(idxopen,3)>hh(idxopen-1) && ...
                p(end,5)<p(end,2)      
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:sc13break';
                closestr = trade.riskmanager_.closestr_;
                return
            end
            %
            idx_ss_last = find(ss>=9,1,'last');
            if  ~isempty(idx_ss_last)
                ss_last = ss(idx_ss_last);
                idx_ss_start = idx_ss_last-ss_last+1;
                if ss_last >= 22 &&...
                    idx_ss_start < size(sc,1) && idx_ss_last <= size(sc,1)
                    closeflag = 1;
                    trade.riskmanager_.closestr_ = 'tdsq:sc13break';
                    closestr = trade.riskmanager_.closestr_;
                end
            end
        end
        %
        if ss(end) >= 9 && isnan(trade.riskmanager_.tdhigh_)
            k = ss(end);
            trade.riskmanager_.tdhigh_ = max(extrainfo.p(end-k+1:end,3));
            tdidx = find(extrainfo.p(end-k+1:end,3)==trade.riskmanager_.tdhigh_,1,'last')+length(extrainfo.p)-k;
            trade.riskmanager_.tdlow_ = extrainfo.p(tdidx,4);
            if (k > 9 && p(end,5) - trade.riskmanager_.tdlow_+2*ticksize < 1e-6) || ...
                    (k == 9 && p(end,5) - (2*trade.riskmanager_.tdlow_-trade.riskmanager_.tdhigh_)+2*ticksize < 1e-6)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:ssbreak';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        if ~isnan(trade.riskmanager_.tdhigh_) && ss(end) >= 9
            if ss(end) == 9
                %it must be a new sell-setup
                highpx = max(extrainfo.p(end-8:end,3));
                highidx = find(extrainfo.p(end-8:end,3)==highpx,1,'last')+size(extrainfo.p,1)-9;
            else
                highpx = extrainfo.p(end,3);
                highidx = size(extrainfo.p,1);
            end
            if ~strcmpi(trade.opensignal_.frequency_,'5m')
                if highpx > trade.riskmanager_.tdhigh_ + 2*ticksize
                    trade.riskmanager_.tdhigh_ = highpx;
                    trade.riskmanager_.tdlow_ = extrainfo.p(highidx,4);
                end
            else
                if highpx > trade.riskmanager_.tdhigh_
                    trade.riskmanager_.tdhigh_ = highpx;
                    trade.riskmanager_.tdlow_ = extrainfo.p(highidx,4);
                end
            end
            if (ss(end) > 9 && p(end,5) - trade.riskmanager_.tdlow_+2*ticksize < 1e-6) || ...
                    (ss(end) == 9 && p(end,5) - (2*trade.riskmanager_.tdlow_-trade.riskmanager_.tdhigh_)+2*ticksize < 1e-6)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:ssbreak';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
    elseif direction == -1
        if ~isnan(trade.riskmanager_.tdhigh_)
%             if p(end,5) > trade.riskmanager_.tdhigh_+ticksize && extrainfo.bs(end) > 9
            if p(end,5) - trade.riskmanager_.tdhigh_-2*ticksize > -1e-6
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:bsbreak';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        %
        if isnan(trade.riskmanager_.td13high_)
            bc13last = find(extrainfo.bc == 13,1,'last');
            idxlllast = find(extrainfo.idxll == -1,1,'last');
            if idxlllast <= bc13last
                trade.riskmanager_.td13high_ = extrainfo.p(bc13last,5);
            end
        end
        %
        if ~isnan(trade.riskmanager_.td13high_) && extrainfo.bc(end) ~= 13
            if p(end,5) > trade.riskmanager_.td13high_+ticksize
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:bc13break';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        lvldn = extrainfo.lvldn;
        %STOP the trade if it fails to breaches TDST-lvldn,i.e.the low
        %price stayed above lvldn
        if ~isempty(find(p(idxopen:end-1,5)<lvldn(end-1),1,'first')) && ...
                p(end,4)>lvldn(end-1)
            if p(end,3)>lips(end)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:candle failed to breach TDST lvldn';
                closestr = trade.riskmanager_.closestr_;
                return
            end
%             trade.riskmanager_.pxstoploss_ = 0.382*lvldn(end-1)+0.618*trade.riskmanager_.ll0_;
            trade.riskmanager_.pxstoploss_ = 0.382*lvldn(end-1)+0.618*trade.riskmanager_.pxstoploss_;
            if ~isempty(trade.instrument_)
                ticksize = trade.instrument_.tick_size;
                trade.riskmanager_.pxstoploss_ = ceil(trade.riskmanager_.pxstoploss_/ticksize)*ticksize;
            end
            trade.riskmanager_.closestr_ = 'tdsq:candle failed to breach TDST lvldn';
        end
        %STOP the trade if it was a conditional breachdn-lvldn trade in
        %case it failed to breach fractal ll on open but its lowest price
        %on open candle breached lvldn
        if (strcmpi(trade.opensignal_.mode_,'conditional-dntrendconfirmed-1') || ...
                strcmpi(trade.opensignal_.mode_,'conditional-breachdnlvldn')) && ...
                p(idxopen,5)>ll(idxopen-1) && p(idxopen,4)<lvldn(idxopen-1) && p(idxopen-1,5)>lvldn(idxopen-1)
            if p(end,4) > lvldn(idxopen-1)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:candle failed to breach TDST lvldn';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        %STOP the trade if it opened above lvlup and breached down lvlup
        %afterwards but then rallied back above lvlup again
        lvlup = extrainfo.lvlup;
        if p(idxopen,5)>lvlup(idxopen) && ~isempty(find(p(idxopen:end-1,5)<lvlup(idxopen:end-1),1,'first'))
            if p(end,4)>lvlup(end)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:candle failed to breach(dn) TDST lvlup';
                closestr = trade.riskmanager_.closestr_;
                return
            end
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
                    (p(end,5)>min([lips(end),teeth(end),jaw(end)])+2*ticksize || ...
                    p(end,4)>llopen)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:candle fell from below TDST lvldn to above LL again';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        %   
        bs = extrainfo.bs;
        if bs(end) >= 9
            low9 = extrainfo.p(end,4);
            low8 = extrainfo.p(end-1,4);
            low7 = extrainfo.p(end-2,4);
            low6 = extrainfo.p(end-3,4);
            close9 = extrainfo.p(end,5);
            close8 = extrainfo.p(end-1,5);
            if (low8 < min(low6,low7) || ...
                    low9 < min(low6,low7)) && ...
                    close9<close8 && ....
                    close8-close9 > extrainfo.wad(end-1)-extrainfo.wad(end)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:perfectbs9';
                closestr = trade.riskmanager_.closestr_;
            end
            %
            if (low8 < min(low6,low7) || ...
                    low9 < min(low6,low7)) && ...
                    close9<=close8 && ...
                    ~(extrainfo.p(end-1,5)>extrainfo.ll(end-1) && extrainfo.p(end,5)<extrainfo.ll(end-1))
                flag = tdsq_is9139buycount(bs,extrainfo.ss,extrainfo.bc,extrainfo.sc);
                if flag
%                     closeflag = 1;
                    if extrainfo.p(end,3) < trade.riskmanager_.pxstoploss_
                        trade.riskmanager_.pxstoploss_ = extrainfo.p(end,3);
                    end
                    trade.riskmanager_.closestr_ = 'tdsq:9139';
                    closestr = trade.riskmanager_.closestr_;
                    return
                end
            end
            %
        end
        
        if bs(end) >= 16
            closeflag = 1;
            trade.riskmanager_.closestr_ = 'tdsq:bs16';
            closestr = trade.riskmanager_.closestr_;
            return
        end
        bc = extrainfo.bc;
        if bc(end) == 13
            if isnan(trade.riskmanager_.td13high_)
                trade.riskmanager_.td13high_ = extrainfo.p(end,3);
            else
                if extrainfo.p(end,3) > trade.riskmanager_.td13high_
                    trade.riskmanager_.td13high_ = extrainfo.p(end,3);
                end
            end
            %
            if ~isempty(strfind(trade.opensignal_.mode_,'conditional')) && ...
                p(idxopen,5)>ll(idxopen-1) && p(idxopen,4)<hh(idxopen-1) && ...
                p(end,5)>p(end,2)      
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:sc13break';
                closestr = trade.riskmanager_.closestr_;
                return
            end
            %
            idx_bs_last = find(bs>=9,1,'last');
            if  ~isempty(idx_bs_last)
                bs_last = bs(idx_bs_last);
                idx_bs_start = idx_bs_last-bs_last+1;
                if bs_last >= 22 &&...
                    idx_bs_start < size(bc,1) && idx_bs_last <= size(bc,1)
                    closeflag = 1;
                    trade.riskmanager_.closestr_ = 'tdsq:bc13break';
                    closestr = trade.riskmanager_.closestr_;
                end
            end
        end
        %
        if bs(end) >= 9 && isnan(trade.riskmanager_.tdlow_)
            k = bs(end);
            trade.riskmanager_.tdlow_ = min(extrainfo.p(end-k+1:end,4));
            tdidx = find(extrainfo.p(end-k+1:end,4)==trade.riskmanager_.tdlow_,1,'last')+length(extrainfo.p)-k;
            trade.riskmanager_.tdhigh_ = extrainfo.p(tdidx,3);
            if (bs(end) > 9 && p(end,5) - trade.riskmanager_.tdhigh_-2*ticksize > -1e-6) || ...
                    (bs(end) == 9 && p(end,5)-(2*trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_)-2*ticksize > -1e-6)
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:bsbreak';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end
        if ~isnan(trade.riskmanager_.tdlow_) && bs(end)>=9
            if bs(end) == 9
                %it must be a new buy-setup
                lowpx = min(extrainfo.p(end-8:end,4));
                lowidx = find(extrainfo.p(end-8:end,4) == lowpx,1,'last')+size(extrainfo.p,1)-9;
            else
                lowpx = extrainfo.p(end,4);
                lowidx = size(extrainfo.p,1);
            end
            if ~strcmpi(trade.opensignal_.frequency_,'5m')
                if lowpx < trade.riskmanager_.tdlow_ - 2*ticksize
                    trade.riskmanager_.tdlow_ = lowpx;
                    trade.riskmanager_.tdhigh_ = extrainfo.p(lowidx,3);
                end
            else
                if lowpx < trade.riskmanager_.tdlow_
                    trade.riskmanager_.tdlow_ = lowpx;
                    trade.riskmanager_.tdhigh_ = extrainfo.p(lowidx,3);
                end
            end
            if (bs(end) > 9 && p(end,5) - trade.riskmanager_.tdhigh_-2*ticksize > -1e-6) || ...
                   (bs(end) == 9 && p(end,5)-(2*trade.riskmanager_.tdhigh_-trade.riskmanager_.tdlow_)-2*ticksize > -1e-6) 
                closeflag = 1;
                trade.riskmanager_.closestr_ = 'tdsq:bsbreak';
                closestr = trade.riskmanager_.closestr_;
                return
            end
        end

    end


end

