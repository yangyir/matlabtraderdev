function [unwindtrade] = candlehighlow( obj,t,openp,highp,lowp,updateinfo )
%FOR BACKTEST PURPOSE ONLY AND SHALL BE SWITCHED OFF IN REALTIME
%TRADING OR REPLAY
    unwindtrade = {};
    trade = obj.trade_;
    if ~isempty(strfind(trade.opensignal_.mode_,'conditional'))
        if t <= trade.opendatetime1_
            %in case the candle time is before the open time
            return
        end
    end
    
    
    direction = trade.opendirection_;
    instrument = trade.instrument_;
    try
        ticksize = instrument.tick_size;
    catch
        ticksize = 0;
    end
    
    if (lowp - obj.pxstoploss_ < -2*ticksize && direction == 1) || ...
            (highp - obj.pxstoploss_ > 2*ticksize && direction == -1)
        closeflag = 1;
    elseif (lowp < obj.pxtarget_ && direction == -1) ||...
            (highp > obj.pxtarget_ && direction == 1)
%         closeflag = 2;
        closeflag = 0;
    else
        closeflag = 0;
    end
    
    if ~closeflag, return, end
    
    unwindtrade = obj.trade_;
    if closeflag == 1
        if direction == 1 && openp < obj.pxstoploss_ - 2*ticksize
            closeprice = openp;
        elseif direction == -1 && openp > obj.pxstoploss_ + 2*ticksiz
            closeprice = openp;
        else
            if direction == 1
                closeprice = obj.pxstoploss_ -3*ticksize;
            else
                closeprice = obj.pxstoploss_ +3*ticksize;
            end
        end
        if strcmpi(obj.closestr_,'n/a')
            obj.closestr_ = 'fractal:teeth';
        end
    elseif closeflag == 2
        if direction == 1 && openp > obj.pxtarget_
            closeprice = openp;
        elseif direction == -1 && openp < obj.pxtarget_
            closeprice = openp;
        else
            closeprice = obj.pxtarget_;
        end
        obj.closestr_ = 'fibonacci:1.618';
    end

    closetime = t;
    obj.trade_.closedatetime1_ = closetime;
    obj.trade_.closeprice_ = closeprice;
    
    %
    if updateinfo
        volume = trade.openvolume_;
        obj.status_ = 'closed';
        obj.trade_.status_ = 'closed';
        obj.trade_.runningpnl_ = 0;
        if isempty(instrument)
            obj.trade_.closepnl_ = direction*volume*(closeprice-trade.openprice_);
        else
            obj.trade_.closepnl_ = direction*volume*(closeprice-trade.openprice_)/ticksize * instrument.tick_value;
        end
    end
    %
end

