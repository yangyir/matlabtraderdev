function [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
%method of cBatman(cTradeRiskManager)
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

%   ResetStopLossAndTargetOnOpenCandle:TRUE means the stoploss and target
%   prices are reset once the open candle is finished In case of a long
%   position, the target will be the highest price as of the open candle
%   and the stoploss will be the lowest price as of the open candle. For a
%   short postion, the target and stoploss will be the lowest and highest
%   price as of the open candle respectively. Since we need to use the open
%   candle for reset, risk management doesn't take effect on the open
%   candle

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('UseCandleLastOnly',false,@islogical);
    p.addParameter('Debug',false,@islogical)
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.addParameter('UseOpenCandle',false,@islogical);
    p.addParameter('ResetStopLossAndTargetOnOpenCandle',false,@islogical);
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    debug = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    useopencandle = p.Results.UseOpenCandle;
    resetwithopencandle = p.Results.ResetStopLossAndTargetOnOpenCandle;
    
    if useopencandle && resetwithopencandle
        error('cBatman::riskmanagementwithcandle:UseOpenCandle and ResetStopLossAndTargetOnOpenCandle cannot be used at the same time')
    end
    
    unwindtrade = {};
    openbucket = gettradeopenbucket(obj.trade_,obj.trade_.opensignal_.frequency_);
    candleTime = candlek(1);
    candleOpen = candlek(2);
    candleHigh = candlek(3);
    candleLow = candlek(4);
    candleLast = candlek(5);
    
    % return in case the candle happened in the past
    if openbucket > candleTime, return; end
    % set the trade once the openbucket is finished
    if openbucket == candleTime
        if ~useopencandle
            if strcmpi(obj.trade_.status_,'unset'),obj.trade_.status_ = 'set';end
            %
            if resetwithopencandle
                if obj.trade_.opendirection_ == 1
                    obj.setstoploss(candleLow);
                    obj.settarget(candleHigh);
                elseif obj.trade_.opendirection_ == -1
                    obj.setstoploss(candleHigh);
                    obj.settarget(candleLow);
                end
                if debug
                    fprintf('batman reset stoploss at %s and target at %s...\n',num2str(obj.pxstoploss_),num2str(obj.pxtarget_));
                end
            end
        else
            if (obj.trade_.opendirection_ == 1 && candleLow < obj.pxstoploss_) || ...
                    (obj.trade_.opendirection_ == -1 && candleHigh > obj.pxstoploss_)               
                obj.trade_.status_ = 'closed';
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                unwindtrade = obj.trade_;
                closeprice = obj.pxstoploss_;
                %we record the close time as of the close time of the candle
                freq = str2double(obj.trade_.opensignal_.frequency_(1:end-1));
                closetime = candleTime + freq/1440;
            else
                if strcmpi(obj.trade_.status_,'unset'),obj.trade_.status_ = 'set';end
            end
            %
            if ~isempty(unwindtrade) && debug
                fprintf('%s:batman closed as tick price breaches stoploss price at %s...\n',...
                    datestr(closetime,'yyyy-mm-dd HH:MM'),...
                    obj.pxstoploss_);
            end
            %
            if ~isempty(unwindtrade) && updatepnlforclosedtrade
                obj.trade_.runningpnl_ = 0;
                obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(closeprice-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
                obj.trade_.closedatetime1_ = closetime;
                obj.trade_.closeprice_ = closeprice;
            end
        end
        return
    end
     
    % return in case the associated trade is closed
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
            fprintf('%s:batman closed as time breaches stop time at %s...\n',...
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
            %we record the closetime as of the open time of the candle
            closetime = candleTime + 1/86400;
        end
        %
        if candleOpen > obj.pxstoploss_ && candleLow <= obj.pxstoploss_
            obj.status_ = 'closed';
            obj.checkflag_ = 0;
            unwindtrade = obj.trade_;
            closeprice = obj.pxstoploss_;
            %we record the close time as of the close time of the candle
            freq = str2double(obj.trade_.opensignal_.frequency_(1:end-1));
            closetime = candleTime + freq/1440;
        end
        %
        if strcmpi(obj.status_,'closed') && debug
            fprintf('%s:batman closed as tick price breaches stoploss price at %s...\n',...
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
            obj.checkflag_ = 0;
            unwindtrade = obj.trade_;
            closeprice = candleOpen;
            %we record the closetime as of the open time of the candle
            closetime = candleTime + 1/86400;
        end
        %
        if candleOpen < obj.pxstoploss_ && candleHigh >= obj.pxstoploss_
            obj.status_ = 'closed';
            obj.checkflag_ = 0;
            unwindtrade = obj.trade_;
            closeprice = obj.pxstoploss_;
            %we record the close time as of the close time of the candle
            freq = str2double(obj.trade_.opensignal_.frequency_(1:end-1));
            closetime = candleTime + freq/1440;
        end
        %
        if strcmpi(obj.status_,'closed') && debug
            fprintf('%s:batman closed as tick price breaches stoploss price at %s...\n',...
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
    
    
    if usecandlelastonly && ((obj.trade_.opendirection_ == 1 && candleLast <= obj.pxstoploss_) ||...
            (obj.trade_.opendirection_ == -1 && candleLast >= obj.pxstoploss_))
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        unwindtrade = obj.trade_;
        %we record the close time as of the close time of the candle
        freq = str2double(obj.trade_.opensignal_.frequency_(1:end-1));
        closetime = candleTime + freq/1440;
        if debug
            fprintf('%s:batman closed as last price breaches stoploss price at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                num2str(candleLast));
        end
        if updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.closedatetime1_ = closetime;
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
                freq = str2double(obj.trade_.opensignal_.frequency_(1:end-1));
                obj.trade_.closedatetime1_ = candleTime + freq/1440;
%                 obj.trade_.closedatetime2_ = datestr(obj.trade_.closedatetime1_,'yyyy-mm-dd HH:MM:SS');
                obj.trade_.closeprice_ = candleLast;
            end
        end
    end
        
end