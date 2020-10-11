function [unwindtrade] = candlehighlow( obj,t,openp,highp,lowp,updateinfo )
%FOR BACKTEST PURPOSE ONLY AND SHALL BE SWITCHED OFF IN REALTIME
%TRADING OR REPLAY
    unwindtrade = {};
    trade = obj.trade_;
    direction = trade.opendirection_;
    
    if (lowp < obj.pxstoploss_ && direction == 1) || ...
            (highp > obj.pxstoploss_ && direction == -1)
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
        if direction == 1 && openp < obj.pxstoploss_
            closeprice = openp;
        elseif direction == -1 && openp > obj.pxstoploss_
            closeprice = openp;
        else
            closeprice = obj.pxstoploss_;
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
    instrument = trade.instrument_;
    %
    if updateinfo
        volume = trade.openvolume_;
        obj.status_ = 'closed';
        obj.trade_.status_ = 'closed';
        obj.trade_.runningpnl_ = 0;
        if isempty(instrument)
            obj.trade_.closepnl_ = direction*volume*(closeprice-trade.openprice_);
        else
            obj.trade_.closepnl_ = direction*volume*(closeprice-trade.openprice_)/instrument.tick_size * instrument.tick_value;
        end
    end
    %
end

