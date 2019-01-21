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
    unwindtrade = {};
    if strcmpi(obj.status_,'closed'), return; end
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
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    debug = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    % set the trade once the openbucket is finished
    if openbucket == candleTime
        %note:normally the trade is open at the open price of that candle
        if strcmpi(obj.trade_.status_,'unset')
            obj.trade_.status_ = 'set';
            wrsteps = -100:obj.stepvalue_:0;
            nsteps = length(wrsteps);
            idx = find(wrsteps(1:end) < wr,1,'last');
            if obj.trade_.opendirection_ == 1
                obj.criticalvalue1_ = wrsteps(max(nsteps,idx+1));
                obj.criticalvalue2_ = min(obj.criticalvalue1_ + obj.stepvalue_,0);
            elseif obj.trade_.opendirection_ == -1
                obj.criticalvalue1_ = wrsteps(idx);
                obj.criticalvalue2_ = max(obj.criticalvalue1_ - obj.stepvalue_,-100);
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
        if debug
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
        if candleOpen <= obj.pxstoploss_
            obj.status_ = 'closed';
            unwindtrade = obj.trade_;
            closeprice = candleOpen;
            %we record the closetime as of the open time of the candle
            closetime = candleTime + 1/86400;
        end
        %
        if candleOpen > obj.pxstoploss_ && candleLow <= obj.pxstoploss_
            obj.status_ = 'closed';
            unwindtrade = obj.trade_;
            closeprice = obj.pxstoploss_;
            %we record the close time as of the close time of the candle
            freq = str2double(obj.trade_.opensignal_.frequency_(1:end-1));
            closetime = candleTime + freq/1440;
        end
        %
        if strcmpi(obj.status_,'closed') && debug
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
        if candleOpen >= obj.pxstoploss_
            obj.status_ = 'closed';
            unwindtrade = obj.trade_;
            closeprice = candleOpen;
            %we record the closetime as of the open time of the candle
            closetime = candleTime + 1/86400;
        end
        %
        if candleOpen < obj.pxstoploss_ && candleHigh >= obj.pxstoploss_
            obj.status_ = 'closed';
            unwindtrade = obj.trade_;
            closeprice = obj.pxstoploss_;
            %we record the close time as of the close time of the candle
            freq = str2double(obj.trade_.opensignal_.frequency_(1:end-1));
            closetime = candleTime + freq/1440;
        end
        %
        if strcmpi(obj.status_,'closed') && debug
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
    
    pmax = obj.trade_.opensignal_.highesthigh_;
    pmin = obj.trade_.opensignal_.lowestlow_;
    instrument = obj.trade_.instrument_;
    
    %2.check whether WRStep is set
    if strcmpi(obj.status_,'unset')
        if obj.trade_.opendirection_ == 1
            if wr > obj.criticalvalue2_
                if debug, fprintf('breach critical line:%2.0f\n',obj.criticalvalue2_);end
                obj.status_ = 'set';
                obj.criticalvalue1_ = obj.criticalvalue2_;
                obj.criticalvalue2 = min(obj.criticalvalue2_ + obj.stepvalue_,0);
            end
        elseif obj.trade_.opendirection_ == -1
            if wr < obj.criticalvalue2_
                if debug, fprintf('breach critical line:%2.0f\n',obj.criticalvalue2_);end
                obj.status_ = 'set';
                obj.criticalvalue1_ = obj.criticalvalue2_;
                obj.criticalvalue2_ = max(obj.criticalvalue2_ - obj.stepvalue_,-100);
            end
        end
    elseif strcmpi(obj.status_,'set')
        if obj.trade_.opendirection_ == 1
            if wr > obj.criticalvalue2_
                if debug, fprintf('breach critical line:%2.0f\n',obj.criticalvalue2_);end
                obj.criticalvalue1_ = obj.criticalvalue2_;
                obj.criticalvalue2 = min(obj.criticalvalue2_ + obj.stepvalue_,0);        
            end
        elseif obj.trade_.opendirection_ == -1
            if wr < obj.criticalvalue2_
                if debug, fprintf('breach critical line:%2.0f\n',obj.criticalvalue2_);end
                obj.criticalvalue1_ = obj.criticalvalue2_;
                obj.criticalvalue2_ = max(obj.criticalvalue2_ - obj.stepvalue_,-100);
            end
        end
        %
        if obj.trade_.opendirection_ == 1 
            if wr < obj.criticalvalue1_ - 0.5*obj.stepvalue_
                obj.status_ = 'closed';
                closetime = candleTime + freq/1440;
            elseif abs(wr) <= instrument.tick_size/(pmax-pmin)
                % if wr reaches up/down limit, the trade is closed
                obj.status_ = 'closed';
                closetime = candleTime + freq/1440;
            end
            if debug, fprintf('close wr:%2.1f\n',wr);end
        elseif obj.opendirection_ == -1
            if wr > criticalvalue1 + 0.5*obj.stepvalue_
                obj.status_ = 'closed';
                closetime = candleTime + freq/1440;
            elseif abs(wr+100) <= instrument.tick_size/(pmax-pmin)
                obj.status_ = 'closed';
                closetime = candleTime + freq/1440;
            end
            if debug, fprintf('close wr:%2.1f\n',wr);end
        end
    end
    %
    if strcmpi(obj.status_,'closed')
        if updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.closedatetime1_ = closetime;
            obj.trade_.closeprice_ = candleLast;
        end
        unwindtrade = obj.trade_;
    else
        obj.trade_.runningpnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
        obj.trade_.closepnl_ = 0;
    end

end