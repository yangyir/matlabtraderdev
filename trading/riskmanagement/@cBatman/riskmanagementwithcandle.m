function [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
%method of cBatman(cTradeRiskManager)
%output is a struct variable which shall be later processed to process the
%trade
%note:the input variable candlek is a fully set candle
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('UseCandleLastOnly',false,@islogical);
    p.addParameter('Debug',false,@islogical)
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    debug = p.Results.Debug;
    
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
    
    candleHigh = candlek(3);
    candleLow = candlek(4);
    candleLast = candlek(5);
        
    %1.check with time stop if it is necessary
    if ~isempty(obj.trade_.stopdatetime1_) && obj.trade_.stopdatetime1_ <= candleTime
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
        return
    end
    %
    
    if strcmpi(obj.trade_.status_,'unset'), error('cBatman:riskmanagementwithcandle:internal error');end
    
    %in case the stoploss is breached with any price in the candle, we stop
    %the riskmanager and inform the trader or strategy to unwind the trade
    if ~usecandlelastonly && ((obj.trade_.opendirection_ == 1 && candleLow <= obj.pxstoploss_) ||...
            (obj.trade_.opendirection_ == -1 && candleHigh >= obj.pxstoploss_))
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        unwindtrade = obj.trade_;
        if debug
            fprintf('%s:batman closed as (tick)price breaches stoploss price at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                num2str(obj.pxstoploss_));
        end
        return
    end
    
    if usecandlelastonly && ((obj.trade_.opendirection_ == 1 && candleLast <= obj.pxstoploss_) ||...
            (obj.trade_.opendirection_ == -1 && candleLast >= obj.pxstoploss_))
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        unwindtrade = obj.trade_;
        if debug
            fprintf('%s:batman closed as last price breaches stoploss price at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                num2str(obj.pxstoploss_));
        end
        return
    end
        
    %2.check whether Batman is set
    if strcmpi(obj.status_,'unset')
        if obj.trade_.opendirection_ == 1
            if candleLast >= obj.trade_.pxtarget_
                obj.status_ = 'set';
                obj.pxdynamicopen_ = obj.trade_.openprice_;
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candleLast < obj.trade_.pxtarget_ && candleLast > obj.trade_.pxstoploss_
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
            elseif candleLast > obj.pxtarget_ && candleLast < obj.pxstoploss_
                obj.status_ = 'unset';
                obj.checkflag_ = 1;
            else
                error('cBatman:riskmanagementwithcandle:internal error')
            end
        end
        obj.trade_.pnlrunning_ = obj.trade_.direction_*obj.trade_.volume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
        obj.trade_.pnlclosed_ = 0;
    elseif strcmpi(obj.status_,'set')
        if obj.checkflag_ == 2 && obj.trade_.direction_ == 1
            if candleLast <= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                unwindtrade = obj.trade_;
            elseif candleLast >= obj.pxresistence_
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candleLast < obj.pxresistence_ && candleLast > obj.pxsupportmin_
                obj.checkflag_ = 2;
            elseif candleLast <= obj.pxsupportmin_ && candleLast > obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case pxsupportmax is not
                %breahed from the top.now we need to update the
                %open price
                obj.pxdynamicopen_ = candleLast;
                obj.checkflag_ = 3;
            end
        elseif obj.checkflag_ == 2 && obj.trade_.direction_ == -1
            if candleLast >= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                unwindtrade = obj.trade_;
            elseif candleLast <= obj.pxresistence_
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxdynamicopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxdynamicopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candleLast > obj.pxresistence_ && candleLast < obj.pxsupportmin_
                obj.checkflag_ = 2;
            elseif candleLast >= obj.pxsupportmin_ && candleLast < obj.pxsupportmax_
                obj.pxdynamicopen_ = candleLast;
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from below.now we need to update the
                %open price
                obj.checkflag_ = 3;
            end
        elseif obj.checkflag_ == 3 && obj.trade_.direction_ == 1
            if candleLast <= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                unwindtrade = obj.trade_;
            elseif candleLast >= obj.pxresistence_
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ - (obj.pxresistence_-obj.pxdynamicopen_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candleLast < obj.pxresistence_ && candleLast > obj.pxsupportmin_
                obj.checkflag_ = 3;
            elseif candleLast <= obj.pxsupportmin_ && candleLast > obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from the top.now we need to update the
                %open price
                obj.pxdynamicopen_ = min(obj.pxdynamicopen_,candleLast);
                obj.checkflag_ = 3;  
            end
        elseif obj.checkflag_ == 3 && obj.trade_.direction_ == -1
            if candleLast >= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                unwindtrade = obj.trade_;
            elseif candleLast <= obj.pxresistence_
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = obj.pxresistence_ + (obj.pxdynamicopen_-obj.pxresistence_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = obj.pxresistence_ + (obj.pxdynamicopen_-obj.pxresistence_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
            elseif candleLast > obj.pxresistence_ && candleLast < obj.pxsupportmin_
                obj.checkflag_ = 3;
            elseif candleLast >= obj.pxsupportmin_ && candleLast < obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from below.now we need to update the
                %open price
                obj.pxdynamicopen_ = max(obj.pxdynamicopen_,candleLast);
                obj.checkflag_ = 3;
            end
        else
            error('cBatman:riskmanagementwithcandle:internal error')
        end
        
        if ~strcmpi(obj.status_,'closed')
            obj.trade_.pnlrunning_ = obj.trade_.direction_*obj.trade_.volume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
            obj.trade_.pnlclosed_ = 0;
        end
    end
        
end