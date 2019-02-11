function [unwindtrade] = riskmanagementwithcandle(obj,candlek,wr,varargin)
%method of cWRStep(cTradeRiskManager)
%output is a struct variable which shall be later processed to process the
%trade
%note:the input variable candlek is a fully set candle
%optional input control variables:
%   UseCandleLastOnly:TRUE means using last price only for risk management
%   whereas FALSE means using high/low/open for risk management

%   Debug:print log on the screen

%   UpdatePnLForClosedTrade:TRUE means computing closed pnl for unwinded
%   trades. Default value is FALSE as risk manager doesn't have the
%   authorities to close positions while he can only inform the trader or
%   strat to do so. At this point, we are not guaranteed that the trade is
%   closed as per risk management requirement. However, we can use TRUE for
%   backtesing purposes.

%   UseOpenCandle:TRUE means risk managmement takes effect once the trade
%   is executed within the candle, e.g.the trade keeps alive if the low of
%   the candle is above the stoploss and lower than the open if it is a
%   long position trade. FALSE means we will start risk management from the
%   second candle onwards

    unwindtrade = {};
    if strcmpi(obj.status_,'closed'), return; end
    
    if ~(strcmpi(obj.trade_.opensignal_.wrmode_,'classic') || ...
            strcmpi(obj.trade_.opensignal_.wrmode_,'flash'))
        %only classic and flash mode is supported with wrstep risk
        %management approach for now
        return
    end
    
    openbucket = gettradeopenbucket(obj.trade_,obj.trade_.opensignal_.frequency_);
    candleTime = candlek(1);
    % return in case the candle happened in the past
    if openbucket > candleTime, return; end
    candleOpen = candlek(2);
    candleHigh = candlek(3);
    candleLow = candlek(4);
    candleLast = candlek(5);
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('UseCandleLastOnly',false,@islogical);
    p.addParameter('Debug',false,@islogical)
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.addParameter('UseOpenCandle',true,@islogical);
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    doprint = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    wrsteps = -100:obj.stepvalue_:0;
    
    % set the trade once the openbucket is finished
    if openbucket == candleTime
        %note:normally the trade is open at the open price of that candle
        if strcmpi(obj.trade_.status_,'unset')
            obj.trade_.status_ = 'set';
            if obj.trade_.opendirection_ == 1
                obj.criticalvalue1_ = -100;
                obj.criticalvalue2_ = wrsteps(2);
                obj.status_ = 'set';
                if doprint, fprintf('reset critical line at:%2.0f\n',obj.criticalvalue2_);end
            elseif obj.trade_.opendirection_ == -1
                obj.criticalvalue1_ = 0;
                obj.criticalvalue2_ = wrsteps(end-1);
                obj.status_ = 'set';
                if doprint, fprintf('reset critical line at:%2.0f\n',obj.criticalvalue2_);end
            end
        end
    end
    
    if strcmpi(obj.trade_.status_,'closed'), return; end
    
    %1.check with time stop if it is necessary
    if ~isempty(obj.trade_.stopdatetime1_) && obj.trade_.stopdatetime1_ < candleTime
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        %note:the status_ and values of other properties shall be updated
        %if and only if the unwind trade has been successfully executed.
        %here we only export the information for the trader to use
        unwindtrade = obj.trade_;
        if doprint
            fprintf('%s:wrstep closed as time breaches stop time at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                obj.trade_.stopdatetime2_);
        end
        if updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(candleOpen-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.closedatetime1_ = obj.trade_.stopdatetime1_ + 1/86400;
            obj.trade_.closeprice_ = candleOpen;
        end
        return
    end
    %
    
    if strcmpi(obj.trade_.status_,'unset') 
        error('cWRStep:riskmanagementwithcandle:internal error');
    end
    
    %in case the stoploss is breached with any price in the candle, we stop
    %the riskmanager and inform the trader or strategy to unwind the trade
    if ~usecandlelastonly && obj.trade_.opendirection_ == 1
        if candleOpen < obj.pxstoploss_
            obj.status_ = 'closed';
            unwindtrade = obj.trade_;
            closeprice = candleOpen;
            %we record the closetime as of the open time of the candle
            closetime = candleTime + 1/86400;
        end
        %
        if candleOpen >= obj.pxstoploss_ && candleLow < obj.pxstoploss_
            obj.status_ = 'closed';
            unwindtrade = obj.trade_;
            closeprice = obj.pxstoploss_;
            %we record the close time as of the close time of the candle
            freq = str2double(obj.trade_.opensignal_.frequency_(1:end-1));
            closetime = candleTime + freq/1440;
        end
        %
        if strcmpi(obj.status_,'closed') && doprint
            fprintf('%s:wrsetp closed as tick price breaches stoploss price at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                num2str(closeprice));
        end
        %
        if strcmpi(obj.status_,'closed') && updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(closeprice-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.closedatetime1_ = closetime;
            obj.trade_.closeprice_ = closeprice;
        end
        
        if strcmpi(obj.status_,'closed'), return; end
    end
    
    if ~usecandlelastonly && obj.trade_.opendirection_ == -1
        if candleOpen > obj.pxstoploss_
            obj.status_ = 'closed';
            unwindtrade = obj.trade_;
            closeprice = candleOpen;
            %we record the closetime as of the open time of the candle
            closetime = candleTime + 1/86400;
        end
        %
        if candleOpen <= obj.pxstoploss_ && candleHigh > obj.pxstoploss_
            obj.status_ = 'closed';
            unwindtrade = obj.trade_;
            closeprice = obj.pxstoploss_;
            %we record the close time as of the close time of the candle
            freq = str2double(obj.trade_.opensignal_.frequency_(1:end-1));
            closetime = candleTime + freq/1440;
        end
        %
        if strcmpi(obj.status_,'closed') && doprint
            fprintf('%s:wrsetp closed as tick price breaches stoploss price at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                num2str(closeprice));
        end
        %
        if strcmpi(obj.status_,'closed') && updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(closeprice-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.closedatetime1_ = closetime;
            obj.trade_.closeprice_ = closeprice;
        end
        
        if strcmpi(obj.status_,'closed'), return; end
        
    end
    
%     pmax = obj.trade_.opensignal_.highesthigh_;
%     pmin = obj.trade_.opensignal_.lowestlow_;
%     instrument = obj.trade_.instrument_;
    

   if strcmpi(obj.status_,'unset')
       error('cWRStep:riskmanagementwithcandle:internal error');
   end
   
   if ~obj.breachmidline_
        if obj.trade_.opendirection_ == 1
            if wr > obj.criticalvalue2_ + obj.buffer_
                if wr > -50
                    obj.breachmidline_ = 1;
                end
                wr_idx = find(wrsteps < wr,1,'last');
                wrcheck = wrsteps(wr_idx);
                if wrcheck > obj.criticalvalue2_
                    obj.criticalvalue1_ = obj.criticalvalue2_;
                    obj.criticalvalue2_ = wrcheck;
                    if doprint, fprintf('reset critical line at:%2.0f\n',obj.criticalvalue2_);end
                end
                if ~obj.breachmidline_
                    obj.criticalvalue1_ = -100 + 0.5*(obj.criticalvalue2_ + 100);
                end        
            end
        elseif obj.trade_.opendirection_ == -1
            if wr < obj.criticalvalue2_ - obj.buffer_
                if wr < -50
                    obj.breachmidline_ = 1;
                end
                wr_idx = find(wrsteps > wr,1,'first');
                wrcheck = wrsteps(wr_idx);
                if wrcheck < obj.criticalvalue2_
                    obj.criticalvalue1_ = obj.criticalvalue2_;
                    obj.criticalvalue2_ = wrcheck;
                    if doprint, fprintf('reset critical line at:%2.0f\n',obj.criticalvalue2_);end
                end
                if ~obj.breachmidline_
                    obj.criticalvalue1_ = 0.5*obj.criticalvalue2_;
                end
            end
        end
   else
       %we have breach the critical 50 line already
       if obj.trade_.opendirection_ == 1 
           if wr > obj.criticalvalue2_ + obj.buffer_
               wr_idx = find(wrsteps < wr,1,'last');
               wrcheck = wrsteps(wr_idx);
               if wrcheck > obj.criticalvalue2_
                   obj.criticalvalue2_ = wrcheck;
                   if doprint, fprintf('reset critical line at:%2.0f\n',obj.criticalvalue2_);end
                   obj.criticalvalue1_ = -75 + 0.5*(obj.criticalvalue2_ + 75);
               end
           end
       elseif obj.trade_.opendirection_ == -1
           if wr < obj.criticalvalue2_ - obj.buffer_
               wr_idx = find(wrsteps > wr,1,'first');
               wrcheck = wrsteps(wr_idx);
               if wrcheck < obj.criticalvalue2_
                   obj.criticalvalue2_ = wrcheck;
                   if doprint, fprintf('reset critical line at:%2.0f\n',obj.criticalvalue2_);end
                   obj.criticalvalue1_ = -50 - (obj.criticalvalue2_+50)/2;
               end
           end
       end
   end
   %
   if obj.trade_.opendirection_ == 1 && wr < obj.criticalvalue1_ - obj.buffer_
       if doprint, fprintf('close wr:%2.1f\n',wr);end
       obj.status_ = 'closed';
       obj.trade_.status_ = 'closed';
       unwindtrade = obj.trade_;
       return
   elseif obj.trade_.opendirection_ == -1 && wr > obj.criticalvalue1_ + obj.buffer_
       if doprint, fprintf('close wr:%2.1f\n',wr);end
       obj.status_ = 'closed';
       obj.trade_.status_ = 'closed';
       unwindtrade = obj.trade_;
       return
   end
   %
   if obj.trade_.opendirection_ == 1 && abs(wr) <= 1e-4
       obj.breachlimitline_ = 1;
       if doprint, fprintf('hit wr:%2.1f\n',wr);end
   elseif obj.trade_.opendirection_ == -1 && abs(wr+100) <= 1e-4
       obj.breachlimitline_ = 1;
       if doprint, fprintf('hit wr:%2.1f\n',wr);end
   end
   %
   if obj.breachlimitline_
       if obj.trade_.opendirection_ == 1 && wr < obj.criticalvalue2_ - obj.buffer_
           if doprint, fprintf('close wr:%2.1f\n',wr);end
           obj.status_ = 'closed';
           obj.trade_.status_ = 'closed';
           unwindtrade = obj.trade_;
           return
       elseif obj.trade_.opendirection_ == -1 && wr > obj.criticalvalue2_ + obj.buffer_
           if doprint, fprintf('close wr:%2.1f\n',wr);end
           obj.status_ = 'closed';
           obj.trade_.status_ = 'closed';
           unwindtrade = obj.trade_;
           return
       end
   end
   % 
   obj.trade_.runningpnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
   obj.trade_.closepnl_ = 0;

end