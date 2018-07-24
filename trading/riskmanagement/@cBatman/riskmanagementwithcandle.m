function [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
%method of cBatman(cTradeRiskManager)
%output is a struct variable which shall be later processed to process the
%trade
%note:the input variable candlek is a fully set candle
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
        return
    end
    %
    
    if strcmpi(obj.trade_.status_,'unset'), error('cBatman:riskmanagementwithcandle:internal error');end
    
    %in case the stoploss is breached with any price in the candle, we stop
    %the riskmanager and inform the trader or strategy to unwind the trade
    if (obj.trade_.opendirection_ == 1 && candleLow <= obj.trade_.pxstoploss_) ||...
            (obj.trade_.opendirection_ == -1 && candleHigh >= obj.trade_.pxstoploss_)
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        unwindtrade = obj.trade_;
        %todo:we need closetodayflag as well
        return
    end
        
    %2.check whether Batman is set
    if strcmpi(obj.status_,'unset')
        if obj.trade_.opendirection_ == 1
            if candleLast >= obj.trade_.pxtarget_
                obj.status_ = 'set';
                obj.pxdynamicopen_ = obj.trade_.openprice_;
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = candleLast - (candleLast-obj.pxdynamicopen_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = candleLast - (candleLast-obj.pxdynamicopen_)*obj.bandwidthmax_;
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
                obj.pxsupportmin_ = candleLast + (obj.pxdynamicopen_-candleLast)*obj.bandwidthmin_;
                obj.pxsupportmax_ = candleLast + (obj.pxdynamicopen_-candleLast)*obj.bandwidthmax_;
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
                obj.pxsupportmin_ = candleLast - (candleLast-obj.trade_.openprice_)*obj.bandwidthmin_;
                obj.pxsupportmax_ = candleLast - (candleLast-obj.trade_.openprice_)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
                obj.trade_.pnlrunning_ = obj.trade_.direction_*obj.trade_.volume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
                obj.trade_.pnlclosed_ = 0;
            elseif candleLast < obj.pxresistence_ && candleLast > obj.pxsupportmin_
                obj.checkflag_ = 2;
                obj.trade_.pnlrunning_ = obj.trade_.direction_*obj.trade_.volume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
                obj.trade_.pnlclosed_ = 0;
            elseif candleLast <= obj.pxsupportmin_ && candleLast > obj.pxsupportmax_
                %indicating the first round of trend is over but we
                %may have a second trend in case pxsupportmax is not
                %breahed from the top.now we need to update the
                %open price
                obj.pxdynamicopen_ = candleLast;
                obj.checkflag_ = 3;
                obj.trade_.pnlrunning_ = obj.trade_.direction_*obj.trade_.volume_*(candleLast-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
                obj.trade_.pnlclosed_ = 0;
            end
        elseif obj.checkflag_ == 2 && obj.trade_.direction_ == -1
            if candleLast >= obj.pxsupportmax_
                obj.status_ = 'closed';
                obj.checkflag_ = 0;
                unwindtrade = obj.trade_;
%                 return
            elseif candleLast <= obj.pxresistence_
                obj.pxresistence_ = candleLast;
                obj.pxsupportmin_ = candleLast + (obj.pxopen_-candleLast)*obj.bandwidthmin_;
                obj.pxsupportmax_ = candleLast + (obj.pxopen_-candleLast)*obj.bandwidthmax_;
                obj.checkflag_ = 2;
                obj.pnlrunning_ = obj.direction_*obj.volume_*(candleLast-obj.pxopenreal_)/ obj.instrument_.tick_size * obj.instrument_.tick_value;
                obj.pnlclosed_ = 0;
            elseif candleLast > obj.pxresistence_ && candleLast < obj.pxsupportmin_
                obj.checkflag_ = 2;
                obj.pnlrunning_ = obj.direction_*obj.volume_*(candleLast-obj.pxopenreal_)/ obj.instrument_.tick_size * obj.instrument_.tick_value;
                obj.pnlclosed_ = 0;
            elseif candleLast >= obj.pxsupportmin_ && candleLast < obj.pxsupportmax_
                obj.pxopen_ = candleLast;
                %indicating the first round of trend is over but we
                %may have a second trend in case withdrawmax is not
                %breahed from below.now we need to update the
                %open price
                obj.checkflag_ = 3;
                obj.pnlrunning_ = obj.direction_*obj.volume_*(candleLast-obj.pxopenreal_)/ obj.instrument_.tick_size * obj.instrument_.tick_value;
                obj.pnlclosed_ = 0;
            end
        elseif obj.checkflag_ == 3 && obj.trade_.direction_ == 1
        elseif obj.checkflag_ == 3 && obj.trade_.direction_ == -1
        else
            error('cBatman:riskmanagementwithcandle:internal error')
        end
    end
        
    
    
        
end