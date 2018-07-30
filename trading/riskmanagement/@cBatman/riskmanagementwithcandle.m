function [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
%method of cBatman(cTradeRiskManager)
%output is a struct variable which shall be later processed to process the
%trade
%note:the input variable candlek is a fully set candle
%optional input control variables:
%   UseCandleLastOnly:TRUE means using last price only for risk management
%   whereas FALSE means using high/low for tisk management

%   Debug:print log on the screen

%   UpdatePnLForClosedTrade:TRUE means computing closed pnl for unwinded
%   trades. Default value is FALSE as risk manager doesn't have the
%   authorities to close positions while he can only inform the trader or
%   strat to do so. At this point, we are not guaranteed that the trade is
%   closed as per risk management requirement. However, we can use TRUE for
%   backtesing purposes.

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('UseCandleLastOnly',false,@islogical);
    p.addParameter('Debug',false,@islogical)
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    debug = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    unwindtrade = {};
    openbucket = gettradeopenbucket(obj.trade_,obj.trade_.opensignal_.frequency_);
    candleTime = candlek(1);
    
    % return in case the candle happened in the past
    if openbucket > candleTime, return; end
    % set the trade once the openbucket is finished
    if openbucket == candleTime
        if strcmpi(obj.trade_.status_,'unset'),obj.trade_.status_ = 'set';end
        return
    end
     
    % return in case the associated trade is closed
    if strcmpi(obj.trade_.status_,'closed'), return; end
    
    candleOpen = candlek(2);
    candleHigh = candlek(3);
    candleLow = candlek(4);
    candleLast = candlek(5);
        
    %1.check with time stop if it is necessary
    if ~isempty(obj.trade_.stopdatetime1_) && obj.trade_.stopdatetime1_ < candleTime
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        %note:the status_ and values of other properties shall be updated
        %if and only if the unwind trade has been successfully executed.
        %here we only export the information for the trader to use
        unwindtrade = obj.trade_;
        if debug
            fprintf('%s:batman closed as time breaches stop time at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                obj.trade_.stopdatetime2_);
        end
        if updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(candleOpen-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.closedatetime1_ = candleTime;
            obj.trade_.closedatetime2_ = datestr(obj.trade_.closedatetime1_,'yyyy-mm-dd HH:MM:SS');
            obj.trade_.closeprice_ = candleOpen;
        end
        return
    end
    %
    
    if strcmpi(obj.trade_.status_,'unset') 
        error('cBatman:riskmanagementwithcandle:internal error');
    end
    
    %in case the stoploss is breached with any price in the candle, we stop
    %the riskmanager and inform the trader or strategy to unwind the trade
    if ~usecandlelastonly && obj.trade_.opendirection_ == 1
        if candleOpen <= obj.pxstoploss_
            obj.status_ = 'closed';
            obj.checkflag_ = 0;
            unwindtrade = obj.trade_;
            closeprice = candleOpen;
        end
        %
        if candleOpen > obj.pxstoploss_ && candleLow <= obj.pxstoploss_
            obj.status_ = 'closed';
            obj.checkflag_ = 0;
            unwindtrade = obj.trade_;
            closeprice = obj.pxstoploss_;
        end
        if strcmpi(obj.status_,'closed') && debug
            fprintf('%s:batman closed as tick price breaches stoploss price at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                num2str(closeprice));
        end
        if strcmpi(obj.status_,'closed') && updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(closeprice-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.closedatetime1_ = candleTime;
            obj.trade_.closedatetime2_ = datestr(obj.trade_.closedatetime1_,'yyyy-mm-dd HH:MM:SS');
            obj.trade_.closeprice_ = closeprice;
        end
        
        if strcmpi(obj.status_,'closed'), return; end
    end
    
    if ~usecandlelastonly && obj.trade_.opendirection_ == -1
        if candleOpen >= obj.pxstoploss_
            obj.status_ = 'closed';
            obj.checkflag_ = 0;
            unwindtrade = obj.trade_;
            closeprice = candleOpen;
        end
        %
        if candleOpen < obj.pxstoploss_ && candleHigh >= obj.pxstoploss_
            obj.status_ = 'closed';
            obj.checkflag_ = 0;
            unwindtrade = obj.trade_;
            closeprice = obj.pxstoploss_;
        end
        if strcmpi(obj.status_,'closed') && debug
            fprintf('%s:batman closed as tick price breaches stoploss price at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                num2str(closeprice));
        end
        if strcmpi(obj.status_,'closed') && updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(closeprice-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.closedatetime1_ = candleTime;
            obj.trade_.closedatetime2_ = datestr(obj.trade_.closedatetime1_,'yyyy-mm-dd HH:MM:SS');
            obj.trade_.closeprice_ = closeprice;
        end
        if strcmpi(obj.status_,'closed'), return; end
        
    end
    
%     if ~usecandlelastonly && ((obj.trade_.opendirection_ == 1 && candleLow <= obj.pxstoploss_) ||...
%             (obj.trade_.opendirection_ == -1 && candleHigh >= obj.pxstoploss_))
%         obj.status_ = 'closed';
%         obj.checkflag_ = 0;
%         unwindtrade = obj.trade_;
%         if debug
%             fprintf('%s:batman closed as tick price breaches stoploss price at %s...\n',...
%                 datestr(candleTime,'yyyy-mm-dd HH:MM'),...
%                 num2str(obj.pxstoploss_));
%         end
%         if updatepnlforclosedtrade
%             obj.trade_.runningpnl_ = 0;
%             obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(obj.pxstoploss_-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
%             obj.trade_.closedatetime1_ = candleTime;
%             obj.trade_.closedatetime2_ = datestr(obj.trade_.closedatetime1_,'yyyy-mm-dd HH:MM:SS');
%             obj.trade_.closeprice_ = obj.pxstoploss_;
%         end
%         return
%     end
    
    if usecandlelastonly && ((obj.trade_.opendirection_ == 1 && candleLast <= obj.pxstoploss_) ||...
            (obj.trade_.opendirection_ == -1 && candleLast >= obj.pxstoploss_))
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        unwindtrade = obj.trade_;
        if debug
            fprintf('%s:batman closed as last price breaches stoploss price at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                num2str(candleLast));
        end
        if updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.closedatetime1_ = candleTime;
            obj.trade_.closedatetime2_ = datestr(obj.trade_.closedatetime1_,'yyyy-mm-dd HH:MM:SS');
            obj.trade_.closeprice_ = candleLast;
        end
        return
    end
        
    %2.check whether Batman is set
    if strcmpi(obj.status_,'unset')
        if obj.trade_.opendirection_ == 1
            if candleLast >= obj.pxtarget_
                obj.status_ = 'set';
                obj.pxdynamicopen_ = obj.trade_.openprice_;
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
                if debug
                    fprintf('%s:batman set as last price breaches target price at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxtarget_));
                end
            elseif candleLast < obj.pxtarget_ && candleLast > obj.pxstoploss_
                obj.status_ = 'unset';
                obj.checkflag_ = 1;
            else
                error('cBatman:riskmanagementwithcandle:internal error')
            end    
        elseif obj.trade_.opendirection_ == -1
            if candleLast <= obj.pxtarget_
                obj.status_ = 'set';
                obj.pxdynamicopen_ = obj.trade_.openprice_;
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxdynamicopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxdynamicopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
                if debug
                    fprintf('%s:batman set as last price breaches target price at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxtarget_));
                end
            elseif candleLast > obj.pxtarget_ && candleLast < obj.pxstoploss_
                obj.status_ = 'unset';
                obj.checkflag_ = 1;
            else
                error('cBatman:riskmanagementwithcandle:internal error')
            end
        end
        obj.trade_.runningpnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
        obj.trade_.closepnl_ = 0;
    elseif strcmpi(obj.status_,'set')
        if obj.checkflag_ == 2 && obj.trade_.opendirection_ == 1
            if candleLast <= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                unwindtrade = obj.trade_;
                if debug
                    fprintf('%s:batman closed as last price breaches maximum support at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxsupportmax_));
                end
            elseif candleLast >= obj.pxresistence_
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
                if debug
                    fprintf('%s:batman reset as last price breaches resistence level at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxresistence_));
                end
            elseif candleLast < obj.pxresistence_ && candleLast > obj.pxsupportmin_
                obj.checkflag_ = 2;
            elseif candleLast <= obj.pxsupportmin_ && candleLast > obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case pxsupportmax is not
                %breahed from the top.now we need to update the
                %open price
                obj.pxdynamicopen_ = candleLast;
                obj.checkflag_ = 3;
                if debug
                    fprintf('%s:batman reset checkflag from 2 to 3 and dynamic open price at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxdynamicopen_));
                end
            end
        elseif obj.checkflag_ == 2 && obj.trade_.opendirection_ == -1
            if candleLast >= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                unwindtrade = obj.trade_;
                if debug
                    fprintf('%s:batman closed as last price breaches maximum support at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxsupportmax_));
                end                
            elseif candleLast <= obj.pxresistence_
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxdynamicopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxdynamicopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
                if debug
                    fprintf('%s:batman reset as last price breaches resistence level at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxresistence_));
                end
            elseif candleLast > obj.pxresistence_ && candleLast < obj.pxsupportmin_
                obj.checkflag_ = 2;
            elseif candleLast >= obj.pxsupportmin_ && candleLast < obj.pxsupportmax_
                obj.pxdynamicopen_ = candleLast;
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from below.now we need to update the
                %open price
                obj.checkflag_ = 3;
                if debug
                    fprintf('%s:batman reset checkflag from 2 to 3 and dynamic open price at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxdynamicopen_));
                end
            end
        elseif obj.checkflag_ == 3 && obj.trade_.opendirection_ == 1
            if candleLast <= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                unwindtrade = obj.trade_;
                if debug
                    fprintf('%s:batman closed as last price breaches maximum support at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxsupportmax_));
                end                
            elseif candleLast >= obj.pxresistence_
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
                if debug
                    fprintf('%s:batman reset checkflag from 3 to 2 as last price breaches resistence level at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxresistence_));
                end
            elseif candleLast < obj.pxresistence_ && candleLast > obj.pxsupportmin_
                obj.checkflag_ = 3;
            elseif candleLast <= obj.pxsupportmin_ && candleLast > obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from the top.now we need to update the
                %open price
                obj.pxdynamicopen_ = min(obj.pxdynamicopen_,candleLast);
                obj.checkflag_ = 3;
                if debug
                    fprintf('%s:batman reset dynamic open price at %s with checkflag staying at 3...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxdynamicopen_));
                end
            end
        elseif obj.checkflag_ == 3 && obj.trade_.opendirection_ == -1
            if candleLast >= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                unwindtrade = obj.trade_;
                if debug
                    fprintf('%s:batman closed as last price breaches maximum support at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxsupportmax_));
                end 
            elseif candleLast <= obj.pxresistence_
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxdynamicopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxdynamicopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
                if debug
                    fprintf('%s:batman reset checkflag from 3 to 2 as last price breaches resistence level at %s...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxresistence_));
                end                
            elseif candleLast > obj.pxresistence_ && candleLast < obj.pxsupportmin_
                obj.checkflag_ = 3;
            elseif candleLast >= obj.pxsupportmin_ && candleLast < obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from below.now we need to update the
                %open price
                obj.pxdynamicopen_ = max(obj.pxdynamicopen_,candleLast);
                obj.checkflag_ = 3;
                if debug
                    fprintf('%s:batman reset dynamic open price at %s with checkflag staying at 3...\n',...
                        datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                        num2str(obj.pxdynamicopen_));
                end
            end
        else
            error('cBatman:riskmanagementwithcandle:internal error')
        end
        
        if ~strcmpi(obj.status_,'closed')
            obj.trade_.runningpnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.closepnl_ = 0;
        else
            if updatepnlforclosedtrade
                obj.trade_.runningpnl_ = 0;
                obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
                obj.trade_.closedatetime1_ = candleTime;
                obj.trade_.closedatetime2_ = datestr(obj.trade_.closedatetime1_,'yyyy-mm-dd HH:MM:SS');
                obj.trade_.closeprice_ = candleLast;
            end
        end
    end
        
end