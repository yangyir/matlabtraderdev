function [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
%cSpiderman
    unwindtrade = {};
    if strcmpi(obj.status_,'closed'), return; end
    if strcmpi(obj.trade_.status_,'closed'), return; end
    if obj.pxstoploss_ == -9.99, return;end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('UseCandleLastOnly',false,@islogical);
    p.addParameter('Debug',false,@islogical)
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.addParameter('ExtraInfo',{},@isstruct);
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    doprint = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    extrainfo = p.Results.ExtraInfo;
    
    candleTime = candlek(1);
    %double-check candleTime is inline with candleTime in extrainfo
    if candleTime ~= extrainfo.p(end,1)
        error('cSpiderman:riskmanagementwithcandle:internal error!!!')
    end
    candleOpen = extrainfo.p(end,2);
    candleHigh = extrainfo.p(end,3);
    candleLow = extrainfo.p(end,4);
    candleClose = extrainfo.p(end,5);
    
    trade = obj.trade_;
    direction = trade.opendirection_;
    volume = trade.openvolume_;
    instrument = trade.instrument_;
    
    if ~isempty(instrument)
        ticksize = instrument.tick_size;
    else
        ticksize = 0;
    end
    
    if strcmpi(trade.status_,'unset')
        openbucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
        % return in case the candle happened in the past
        if openbucket > candleTime, return; end
        %
        % set the trade once the openbucket is finished
        if openbucket == candleTime        
            trade.status_= 'set';
            obj.status_ = 'set';
            
        elseif openbucket < candleTime
            %note:this shall never happen
            error('cStairs:riskmanagementwithcandle:internal error!!!')
        end
    end
    
    if ~usecandlelastonly
        if (candleLow < obj.pxstoploss_ && direction == 1) || ...
                (candleHigh > obj.pxstoploss_ && direction == -1)
            closeflag = 1;
        else
            closeflag = 0;
        end
        if closeflag
            obj.status_ = 'closed';
            unwindtrade = obj.trade_;
            if direction == 1 && candleOpen < obj.pxstoploss_
                closeprice = candleOpen;
            elseif direction == -1 && candleOpen > obj.pxstoploss_
                closeprice = candleOpen;
            else
                closeprice = obj.pxstoploss_;
            end
            closetime = candleTime;
            %
            if doprint
                fprintf('%s:stairs closed as tick price breaches stoploss price at %s...\n',...
                    datestr(closetime,'yyyy-mm-dd HH:MM'),...
                    num2str(closeprice));
            end
            %
            if updatepnlforclosedtrade
                obj.trade_.runningpnl_ = 0;
                if isempty(instrument)
                    obj.trade_.closepnl_ = direction*volume*(closeprice-trade.openprice_);
                else
                    obj.trade_.closepnl_ = direction*volume*(closeprice-trade.openprice_)/instrument.tick_size * instrument.tick_value;
                end
                obj.trade_.closedatetime1_ = closetime;
                obj.trade_.closeprice_ = closeprice;
            end
            %
            return
        end
    end
    
    if direction == 1
        closeflag = 0;
        idxstart2check = find(extrainfo.p(:,1)>=trade.opendatetime1_,1,'first');
        %1.stop the trade if price falls below alligator's lips
        if candleClose < extrainfo.lips(end)-ticksize
            closeflag = 1;
        %2.stop the trade if price breaches stoploss
        elseif candleClose < obj.pxstoploss2_-ticksize
            closeflag = 1;
        %3.stop the trade if it fails to breaches TDST-lvlup,i.e.the high
        %price fell below lvlup
        elseif ~isempty(find(extrainfo.p(idxstart2check:end-1,5)>extrainfo.lvlup(end-1),1,'first')) && extrainfo.p(end,3)<extrainfo.lvlup(end-1)
            closeflag = 1;
        end
        %4.if it finishes TD Sell Sequential, then stop the trade once it
        %falles below the low of the bar with the true high of the
        %sequential
        if closeflag == 0 && candleClose < obj.tdlow_ && ((obj.tdhigh_ - trade.openprice_) > 0.236*(obj.hh1_-obj.ll1_)||(ticksize>0&&(obj.tdhigh_ - trade.openprice_)>10*ticksize))
            closeflag = 1;
            obj.tdhigh_ = NaN;
            obj.tdlow_ = NaN;
        end
        if closeflag == 0 && extrainfo.ss(end) >= 9 && isnan(obj.tdlow_)
            ssreached = extrainfo.ss(end);
            obj.tdhigh_ = max(extrainfo.p(end-ssreached+1:end,3));
            tdidx = find(extrainfo.p(end-ssreached+1:end,3)==obj.tdhigh_,1,'last')+length(extrainfo.p)-ssreached;
            obj.tdlow_ = extrainfo.p(tdidx,4);
        end
        if closeflag == 0 && ~isnan(obj.tdlow_) && extrainfo.ss(end) > 9
            if extrainfo.p(end,3) > obj.tdhigh_
                obj.tdhigh_ = extrainfo.p(end,3);
                obj.tdlow_ = extrainfo.p(end,4); 
            end
        end
%         %5.a new condition that if ss9 or more is achieved with maximum
%         %close and high price also but teeth is below jaw
%         if closeflag == 0 && extrainfo.ss(end)>=9
%             ssreached = extrainfo.ss(end);
%             if extrainfo.p(end,5) >= max(extrainfo.p(end-ssreached+1:end,5)) &&...
%                     extrainfo.p(end,3) >= max(extrainfo.p(end-ssreached+1:end,3)) &&...
%                     extrainfo.teeth(end) < extrainfo.jaw(end)
%                 closeflag = 1;
%             end
%         end
        %
        if closeflag == 0, obj.updatestoploss('extrainfo',extrainfo); end
        %   
    elseif direction == -1
        closeflag = 0;
        idxstart2check = find(extrainfo.p(:,1)>=trade.opendatetime1_,1,'first');
        %1.stop the trade if price breaches above alligator's lips
        if candleClose > extrainfo.lips(end)+ticksize
            closeflag = 1;
        %2.stop the trade if price breaches stoploss
        elseif candleClose > obj.pxstoploss2_+ticksize
            closeflag = 1;
        %3.stop the trade if it fails to breaches TDST-lvldn,i.e.the low
        %price stayed above lvldn
        elseif ~isempty(find(extrainfo.p(idxstart2check:end-1,5)<extrainfo.lvldn(end-1),1,'first')) && extrainfo.p(end,4)>extrainfo.lvldn(end-1)
            closeflag = 1;
        end
        %4.if it finishes TD Buy Sequential, then stop the trade once it
        %stayed above the high of the bar with the true low of the
        %sequential
        if closeflag == 0 && candleClose > obj.tdhigh_ && ((trade.openprice_ - obj.tdlow_) > 0.236*(obj.hh1_-obj.ll1_)||(ticksize>0&&(trade.openprice_ - obj.tdlow_)>10*ticksize))
            closeflag = 1;
            obj.tdhigh_ = NaN;
            obj.tdlow_ = NaN;
        end
        if closeflag == 0 && extrainfo.bs(end) >= 9 && isnan(obj.tdhigh_)
            bsreached = extrainfo.bs(end);
            obj.tdlow_ = min(extrainfo.p(end-bsreached+1:end,4));
            tdidx = find(extrainfo.p(end-bsreached+1:end,4)==obj.tdlow_,1,'last')+length(extrainfo.p)-bsreached;
            obj.tdhigh_ = extrainfo.p(tdidx,3);
        end
        if closeflag == 0 && ~isnan(obj.tdhigh_) && extrainfo.bs(end) > 9
           if extrainfo.p(end,4) < obj.tdlow_
               obj.tdlow_ = extrainfo.p(end,4);
               obj.tdhigh_ = extrainfo.p(end,3);
           end
        end
        %
        if closeflag == 0;obj.updatestoploss('extrainfo',extrainfo);end
        %
    end
    %
    if closeflag
        if doprint, fprintf('close candle time:%s\n',datestr(candleTime,'yyyy-mm-dd HH:MM'));end
        obj.status_ = 'closed';
        obj.trade_.status_ = 'closed';
        unwindtrade = obj.trade_;
        if updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            if isempty(instrument)
                obj.trade_.closepnl_ = direction*volume*(candleClose-trade.openprice_);
            else
                obj.trade_.closepnl_ = direction*volume*(candleClose-trade.openprice_)/instrument.tick_size * instrument.tick_value;
            end
            obj.trade_.closedatetime1_ = candleTime;
            obj.trade_.closeprice_ = candleClose;
        end
        return
    else
        if isempty(instrument)
            obj.trade_.runningpnl_ = direction*volume*(candleClose-trade.openprice_);
        else
            obj.trade_.runningpnl_ = direction*volume*(candleClose-trade.openprice_)/instrument.tick_size * instrument.tick_value;
        end
    end
end
