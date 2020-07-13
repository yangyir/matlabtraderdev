function [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
%cSpiderman
    variablenotused(candlek);
    unwindtrade = {};
%     if strcmpi(obj.status_,'closed'), return; end
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
    
    candleTime = extrainfo.p(end,1);
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
        
    if strcmpi(trade.status_,'unset') || strcmpi(obj.status_,'unset')
        obj.setspiderman('extrainfo',extrainfo);
    end
    
    if ~usecandlelastonly
        unwindtrade = obj.candlehighlow(candleTime,candleOpen,candleHigh,candleLow,updatepnlforclosedtrade);
        if ~isempty(unwindtrade), return;end  
    end
    
    if strcmpi(obj.trade_.opensignal_.frequency_,'daily')
        unwindtrade = obj.riskmanagement_daily(varargin{:});
    end
    
    if direction == 1
        closeflag = 0;
        if strcmpi(trade.opensignal_.frequency_,'daily')
            idxstart2check = find(extrainfo.p(:,1)>=trade.opendatetime1_,1,'first')+1;
        else
%             openbucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
%             idxstart2check = find(extrainfo.p(:,1)>=openbucket,1,'first');
            idxstart2check = find(extrainfo.p(:,1)<=trade.opendatetime1_,1,'last')-1;
        end
        if isempty(idxstart2check), return; end
        
        %STOP the trade if price breaches stoploss
%         if closeflag == 0 && candleClose < obj.pxstoploss2_-2*ticksize
%             closeflag = 1;
%             obj.closestr_ = 'candle breach stoploss2';
%             if doprint, fprintf('point %4s:spiderman closed as %s...\n',num2str(length(extrainfo.lips)),obj.closestr_);end
%         end
%         %
%         if closeflag == 0 && candleClose < extrainfo.teeth(end)-2*ticksize
%             closeflag = 1;
%             obj.closestr_ = 'candle breach teeth';
%             if doprint, fprintf('point %4s:spiderman closed as %s...\n',num2str(length(extrainfo.lips)),obj.closestr_);end
%         end
        
%         %STOP the trade if it fails to breaches TDST-lvlup,i.e.the high
%         %price fell below lvlup
%         if closeflag == 0 && ...
%                 ~isempty(find(extrainfo.p(idxstart2check:end-1,5)>extrainfo.lvlup(end-1),1,'first')) && ...
%                 extrainfo.p(end,3)<extrainfo.lvlup(end-1)
%             closeflag = 1;
%             obj.closestr_ = 'candle failed to breach TDST lvlup';
%             if doprint, fprintf('point %4s:spiderman closed as %s...\n',num2str(length(extrainfo.lips)),obj.closestr_);end
%         end
%         %IF TDST-lvlup exists and is higher then HH at open
%         %then one of the candle's high price has breached TDST-lvlup but
%         %its close price is below TDST-lvlup,STOP the trade is the close
%         %price falls below HH again
%         if closeflag == 0 && ...
%                 extrainfo.lvlup(idxstart2check-1) > extrainfo.hh(idxstart2check-1) && ...
%                 extrainfo.p(end,5) < extrainfo.lvlup(idxstart2check-1)
%             lvlupopen = extrainfo.lvlup(idxstart2check-1);
%             hhopen = extrainfo.hh(idxstart2check-1);
%             conditionsatisfied = false;
%             for ii = idxstart2check:size(extrainfo.p,1)
%                 if extrainfo.p(ii,3) > lvlupopen && extrainfo.p(ii,5) < lvlupopen
%                     conditionsatisfied = true;
%                     break
%                 end
%             end
%             if conditionsatisfied && extrainfo.p(end,5) < hhopen && extrainfo.p(end,5)<max(max(extrainfo.lips(end),extrainfo.teeth(end)),extrainfo.jaw(end))
%                 closeflag = 1;
%                 obj.closestr_ = 'candle fell from above TDST lvlup to below HH again';
%                 if doprint
%                     fprintf('point %4s:spiderman closed as %s...\n',num2str(length(extrainfo.lips)),obj.closestr_);
%                 end
%             end
%         end
        %
%         if closeflag == 0 && extrainfo.ss(end) >= 9 && isnan(obj.tdlow_)
%             ssreached = extrainfo.ss(end);
%             obj.tdhigh_ = max(extrainfo.p(end-ssreached+1:end,3));
%             tdidx = find(extrainfo.p(end-ssreached+1:end,3)==obj.tdhigh_,1,'last')+length(extrainfo.p)-ssreached;
%             obj.tdlow_ = extrainfo.p(tdidx,4);
%         end
%         %
%         if closeflag == 0 && ~isnan(obj.tdlow_) && extrainfo.ss(end) > 0
%             if extrainfo.p(end,3) >= obj.tdhigh_
%                 obj.tdhigh_ = extrainfo.p(end,3);
%                 if extrainfo.p(end,4) < obj.tdlow_ && extrainfo.p(end,5) > obj.tdlow_
%                     obj.tdlow_ = min(extrainfo.p(end,5),extrainfo.p(end,3)-0.5*(extrainfo.p(end,3)-extrainfo.p(end,4)));
%                 else
%                     obj.tdlow_ = max(obj.tdlow_,extrainfo.p(end,4));
%                 end
%             end
%         end
        %
%         if closeflag == 0 && extrainfo.ss(end) == 9
%             high9 = extrainfo.p(end,3);
%             high8 = extrainfo.p(end-1,3);
%             high7 = extrainfo.p(end-2,3);
%             high6 = extrainfo.p(end-3,3);
%             close9 = extrainfo.p(end,5);
%             close8 = extrainfo.p(end-1,5);
%             if (high8 > max(high6,high7) || ...
%                     high9 > max(high6,high7)) && ...
%                     close9>close8 && ....
%                     extrainfo.wad(end)-extrainfo.wad(end-1)>close9-close8
%                 closeflag = 1;
%                 obj.closestr_ = 'perfectss9';
%             end 
%         end
%         %
%         if closeflag == 0 && extrainfo.ss(end) >= 16
%             closeflag = 1;
%             obj.closestr_ = 'sshighvalue-16';
%         end
%         %
%         if closeflag == 0 && extrainfo.sc(end) == 13
%             if extrainfo.p(end,5)-obj.cpopen_ > extrainfo.wad(end)-obj.wadopen_
%                 closeflag = 1;
%                 obj.closestr_ = 'sc13';
%             end
%         end
        if closeflag == 0
            [ unwindtrade ] = obj.riskmanagement_fibonacci('extrainfo',extrainfo,...
                'updatepnlforclosedtrade',updatepnlforclosedtrade);
            if ~isempty(unwindtrade)
                return
            end
        end
        %
        if closeflag == 0
            [ unwindtrade ] = obj.riskmanagement_fractal('extrainfo',extrainfo,...
                'updatepnlforclosedtrade',updatepnlforclosedtrade);
            if ~isempty(unwindtrade)
                return
            end
        end
        %
        if closeflag == 0
            [ unwindtrade ] = obj.riskmanagement_tdsq('extrainfo',extrainfo,...
                'updatepnlforclosedtrade',updatepnlforclosedtrade);
            if ~isempty(unwindtrade)
                return
            end
        end
        %
        if closeflag == 0
            [ unwindtrade ] = obj.riskmanagement_wad('extrainfo',extrainfo, ...
                'updatepnlforclosedtrade',updatepnlforclosedtrade);
            if ~isempty(unwindtrade)
                return
            end
        end
        %
        if closeflag == 0, obj.updatestoploss('extrainfo',extrainfo); end
        %   
    elseif direction == -1
        closeflag = 0;
        if strcmpi(trade.opensignal_.frequency_,'daily')
            idxstart2check = find(extrainfo.p(:,1)>=trade.opendatetime1_,1,'first');
        else
%             openbucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
%             idxstart2check = find(extrainfo.p(:,1)>=openbucket,1,'first');
            idxstart2check = find(extrainfo.p(:,1)<=trade.opendatetime1_,1,'last')-1;
        end
        if isempty(idxstart2check), return; end
        
        %STOP the trade if price breaches stoploss
        if closeflag == 0 && candleClose > obj.pxstoploss2_+2*ticksize
            closeflag = 1;
            obj.closestr_ = 'candle breach stoploss2';
            if doprint, fprintf('point %4s:spiderman closed as %s...\n',num2str(length(extrainfo.lips)),obj.closestr_);end
        end
        %
        if closeflag == 0 && candleClose > extrainfo.teeth(end)+2*ticksize
            closeflag = 1;
            obj.closestr_ = 'candle breach teeth';
            if doprint, fprintf('point %4s:spiderman closed as %s...\n',num2str(length(extrainfo.lips)),obj.closestr_);end
        end
            
        %STOP the trade if it fails to breaches TDST-lvldn,i.e.the low
        %price stayed above lvldn
        if closeflag == 0 && ....
                ~isempty(find(extrainfo.p(idxstart2check:end-1,5)<extrainfo.lvldn(end-1),1,'first')) && ...
                extrainfo.p(end,4)>extrainfo.lvldn(end-1)
            closeflag = 1;
            obj.closestr_ = 'candle failed to breach TDST lvldn';
            if doprint, fprintf('point %4s:spiderman closed as %s...\n',num2str(length(extrainfo.lips)),obj.closestr_);end
        end
        %IF TDST-lvldn exists and is lower then LL at open
        %then one of the candle's low price has breached TDST-lvldn but
        %its close price is be above TDST-lvldn,STOP the trade is the close
        %price rallies above LL again
        if closeflag == 0 && ...
                extrainfo.lvldn(idxstart2check) < extrainfo.ll(idxstart2check) && ...
                extrainfo.p(end,5) > extrainfo.lvldn(idxstart2check)
            lvldnopen = extrainfo.lvldn(idxstart2check);
            llopen = extrainfo.ll(idxstart2check);
            conditionsatisfied = false;
            for ii = idxstart2check:size(extrainfo.p,1)
                if extrainfo.p(ii,4) < lvldnopen && extrainfo.p(ii,5) > lvldnopen
                    conditionsatisfied = true;
                    break
                end
            end
            if conditionsatisfied && extrainfo.p(end,5) > llopen && extrainfo.p(end,5)>min(min(extrainfo.lips(end),extrainfo.teeth(end)),extrainfo.jaw(end))
                closeflag = 1;
                obj.closestr_ = 'candle fell from below TDST lvldn to above LL again';
                if doprint
                    fprintf('point %4s:spiderman closed as %s...\n',num2str(length(extrainfo.lips)),obj.closestr_);
                end
            end
        end
        %
        if closeflag == 0 && extrainfo.bs(end) >= 9 && isnan(obj.tdhigh_)
            bsreached = extrainfo.bs(end);
            obj.tdlow_ = min(extrainfo.p(end-bsreached+1:end,4));
            tdidx = find(extrainfo.p(end-bsreached+1:end,4)==obj.tdlow_,1,'last')+length(extrainfo.p)-bsreached;
            obj.tdhigh_ = extrainfo.p(tdidx,3);
        end
%       %
        if closeflag == 0 && ~isnan(obj.tdhigh_) && extrainfo.bs(end) > 0
           if extrainfo.p(end,4) <= obj.tdlow_
               obj.tdlow_ = extrainfo.p(end,4);               
               if extrainfo.p(end,3) > obj.tdhigh_ && extrainfo.p(end,5) < obj.tdhigh_
                   obj.tdhigh_ = max(extrainfo.p(end,5),extrainfo.p(end,4)+0.5*(extrainfo.p(end,3)-extrainfo.p(end,4)));
               else
                   obj.tdhigh_ = min(obj.tdhigh_,extrainfo.p(end,3));
               end
           end
        end
        %
        if closeflag == 0 && extrainfo.bs(end) == 9
            low9 = extrainfo.p(end,4);
            low8 = extrainfo.p(end-1,4);
            low7 = extrainfo.p(end-2,4);
            low6 = extrainfo.p(end-3,4);
            close9 = extrainfo.p(end,5);
            close8 = extrainfo.p(end-1,5);
            if (low8 < min(low6,low7) || ...
                    low9 < min(low6,low7)) && ...
                    close9<close8 && ....
                    extrainfo.wad(end-1)-extrainfo.wad(end)>close9-close8
                closeflag = 1;
                obj.closestr_ = 'perfectbs9';
            end 
        end
        %
        if closeflag == 0 && extrainfo.bs(end) >= 16
            closeflag = 1;
            obj.closestr_ = 'sshighvalue-16';
        end
        %
        if closeflag == 0 && extrainfo.bc(end) == 13
            if obj.cpopen_ - extrainfo.p(end,5) < obj.wadopen_ - extrainfo.wad(end)
                closeflag = 1;
                obj.closestr_ = 'bc13';
            end
        end
        if closeflag == 0
            [ unwindtrade ] = obj.riskmanagement_wad( 'extrainfo',extrainfo,...
                'updatepnlforclosedtrade',updatepnlforclosedtrade);
            if ~isempty(unwindtrade)
                return
            end
        end
        %
        if closeflag == 0;obj.updatestoploss('extrainfo',extrainfo);end
        %
    end
    %
    if closeflag
        obj.status_ = 'closed';
        unwindtrade = obj.trade_;
        if updatepnlforclosedtrade
            obj.trade_.status_ = 'closed';
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
