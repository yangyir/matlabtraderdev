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
                obj.trade_.closepnl_ = direction*volume*(closeprice-trade.openprice_)/instrument.tick_size * instrument.tick_value;
                obj.trade_.closedatetime1_ = closetime;
                obj.trade_.closeprice_ = closeprice;
            end
            %
            return
        end
    end
    
    if direction == 1 
        %1.stop the trade if price falls below alligator's lips
        if candleClose < extrainfo.lips(end)
            closeflag = 1;
        %2.stop the trade if price breaches stoploss
        elseif candleClose < obj.pxstoploss2_
            closeflag = 1;
        %3.stop the trade if it fails to breaches TDST-lvlup,i.e.the high
        %price fell below lvlup
        elseif extrainfo.p(end-1,5)>extainfo.lvlup(end-1) && extrainfo.p(end,3)<extrainfo.lvlup(end-1)
            closeflag = 1;
        %4.if it finishes TD Sell Sequential, then stop the trade once it
        %falles below the low of the bar with the true high of the
        %sequential
        elseif extrainfo.ss(end) >= 9
            ssreached = extrainfo.ss(end);
            tdhigh = max(extrainfo.p(end-ssreached+1:end,3));
            tdidx = find(extrainfo.p(end-ssreached+1:end,3)==tdhigh,1,'last')+length(extrainfo.ss)-ssreached;
            tdlow = extrainfo.p(tdidx,4);
            if candleClose < tdlow && (tdhigh - trade.openprice_) > 0.236*(obj.hh1_-obj.ll1_)
                closeflag = 1;
            else
                closeflag = 0;
                obj.updatestoploss('extrainfo',extrainfo);
            end
        else
            closeflag = 0;
            obj.updatestoploss('extrainfo',extrainfo);
        end     
        %   
    elseif direction == -1
        %1.stop the trade if price breaches above alligator's lips
        if candleClose > extrainfo.lips(end)
            closeflag = 1;
        %2.stop the trade if price breaches stoploss
        elseif candleClose > obj.pxstoploss2_
            closeflag = 1;
        %3.stop the trade if it fails to breaches TDST-lvldn,i.e.the low
        %price stayed above lvldn
        elseif extrainfo.p(end-1,5)<extrainfo.lvldn(end-1) && extrainfo.p(end,4)>extrainfo.lvldn(end-1)
            closeflag = 1;
        %4.if it finishes TD Buy Sequential, then stop the trade once it
        %stayed above the high of the bar with the true low of the
        %sequential
        elseif extrainfo.bs(end) >= 9
            bsreached = extrainfo.bs(end);
            tdlow = min(extrainfo.p(end-bsreached+1:end,4));
            tdidx = find(extrainfo.p(end-bsreached+1:end,4)==tdlow,1,'last')+length(extrainfo.bs)-bsreached;
            tdhigh = extrainfo.p(tdidx,3);
            if candleClose > tdhigh && (trade.openprice_ - tdlow) > 0.236*(obj.hh1_-obj.ll1_);
                closeflag = 1;
            else
                closeflag = 0;
                obj.updatestoploss('extrainfo',extrainfo);
            end
        else
            closeflag = 0;
            obj.updatestoploss('extrainfo',extrainfo);
        end
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
            obj.trade_.closepnl_ = direction*volume*(candleClose-trade.openprice_)/instrument.tick_size * instrument.tick_value;
            obj.trade_.closedatetime1_ = candleTime;
            obj.trade_.closeprice_ = candleClose;
        end
        return
    else
        obj.trade_.runningpnl_ = direction*volume*(candleClose-trade.openprice_)/instrument.tick_size * instrument.tick_value;
    end
end
