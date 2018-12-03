function [] = updateentrustsandbook2(obj)
%cOps
    updateentrust = true;
    try
        n = obj.entrusts_.latest;
    catch
        n = 0;
    end
    % in case there is no placed entrusts at all, we dont need to update
    % entrust
    if n == 0, updateentrust = false; end
    
    try
        npending = obj.entrustspending_.latest;
    catch
        npending = 0;
    end
    % in case there is no pending entrusts, we dont need to update entrust
    if npending == 0, updateentrust = false; end
    
    %注释：
    %根据委托订单成交的情况，我们将订单的状态分为下面的几种情况：
    %1.无效订单 (closed)
    %   e.volume <= 0
    %2:有效订单全部成交（closed)：
    %   e.volume > 0 & e.dealVolume == e.volume & e.cancelVolume = 0
    %3:有效订单部分成交且未成交部分未取消(not closed)：
    %   e.volume > 0 & 0 < e.dealVolume < e.volume & e.cancelVolume == 0
    %4.有效订单部分成交且未成交部分全部取消(closed)
    %   e.volume > 0 & 0 < e.dealVolume < e.volume & e.dealVolume + e.cancelVolume == e.volume    
    %5.有效订单全部未成交且未取消(not closed)：
    %   e.volume > 0 & e.dealVolume == 0 & cancelVolume == 0
    %6.有效订单全部未成交且全部取消(closed)：
    %   e.volume > 0 & e.cancelVolume == e.volume & e.dealVolume = 0
    %对于状态1，2，4，6，毫无疑问需要更新委托的状态从pending到finished
    %对于状态3，我们需要用dealVolume来更新持仓，但是同时我们需要保留该委托的状态
    %对于状态5，我们无需做任何事
    
    warning('off');
    entrusts = EntrustArray;
    if updateentrust
        %note: check three conditions for each pending entrust, i.e. 1) the
        %entrust is placed, 2)the entrust is closed(either fully filled or
        %cancled),3)processed volume bigger than 0
        for i = 1:npending
            e = obj.entrustspending_.node(i);
            if strcmpi(obj.mode_,'realtime')
                %note:in real-time trading, CounterCTP:queryEntrust update
                %the entrust with only FOUR properties, i.e. dealVolume,
                %dealAmount, dealPrice and cancelVolume
                counter = obj.getcounter;
                f0 = counter.queryEntrust(e);
                %note:if e.volume == 0, it is closed. or if e.dealVolume +
                %e.cancelVolume == e.volume
                f1 = e.is_entrust_closed;
                f2 = e.dealVolume > 0;
                flagCanceled = f1 & e.cancelVolume ~= 0 & e.cancelVolume <= e.volume;
                if f0 && f1 && (f2 || flagCanceled) 
                    %note:yangyiran 20180810:we update the complete_time_
                    %here manually as the queryEntrust function doesn't
                    %return this information.
                    e.complete_time_ = now;
                end
                if flagCanceled
                    e.complete_time_ = e.cancelTime;
                end
                %
                %note:here we need to double check the dealprice of the
                %entrust returned by the queryEntrus function
                if f0 && f1 && f2 && ~flagCanceled && e.dealVolume > 1
                    codestr = e.instrumentCode;
                    isopt = isoptchar(codestr);
                    if isopt
                        ticks = obj.mdeopt_.getlasttick(codestr);
                    else
                        ticks = obj.mdefut_.getlasttick(codestr);
                    end
                    if isempty(ticks), continue; end
                    if ticks(4) == 0, continue; end
                    ret = abs(log(e.dealPrice/ticks(4)));
                    if ret >= 0.1
                        %note:the dealPrice returned here is the multiple
                        %of the real dealPrice and the volume
                        fprintf('incorrect deal price returned\n');
                        e.dealPrice = e.price;
                    end
                end
            elseif strcmpi(obj.mode_,'replay')
                codestr = e.instrumentCode;
                isopt = isoptchar(codestr);
                if isopt
                    ticks = obj.mdeopt_.getlasttick(codestr);
                else
                    ticks = obj.mdefut_.getlasttick(codestr);
                end
                %note:the entrust is always placed in 'replay' mode
                f0 = 1;
                if e.direction == 1
                    %note:yangyiran 20180728
                    %the replay tick price is the trade price rather than the
                    %bid/ask price. as a result, we use less/greater than sign
                    %rather than lessorequal/greaterorequal sign here
                    try
                        f1 = ticks(2) <= e.price;
                        if f1
                            if strcmpi(e.entrustType,'limit') || strcmpi(e.entrustType,'market')
                                e.dealPrice = e.price;
                            elseif strcmpi(e.entrustType,'stop')
                                e.dealPrice = ticks(2);
                            else
                                error('cOps:updateentrustsandbook2:invalid entrust type');
                            end
                        end
                    catch
                        f1 = 0;
                    end
                else
                    try
                        f1 = ticks(2) >= e.price;
                        if f1
                            if strcmpi(e.entrustType,'limit') || strcmpi(e.entrustType,'market')
                                e.dealPrice = e.price;
                            elseif strcmpi(e.entrustType,'stop')
                                e.dealPrice = ticks(2);
                            else
                                error('cOps:updateentrustsandbook2:invalid entrust type');
                            end
                        end
                    catch
                        f1 = 0;
                    end
                end
                flagCanceled = f0 & e.cancelVolume ~= 0 & e.cancelVolume <= e.volume;
                if f1 && flagCanceled
                    error('cOps:updateentrustsandbook:internal error')
                end
                
                if ~f1 && flagCanceled
                    f1 = 1;
                end
                
                if f1 && ~flagCanceled
                    f2 = 1;
                elseif f1 && flagCanceled
                    f2 = 0;
                else
                    f2 = 0;
                end
                
                if f1 && ~flagCanceled
                    %once the entrust is executed
                    e.dealVolume = e.volume;
                    e.complete_time_ = ticks(1);
                end
                if flagCanceled
                    e.complete_time_ = e.cancelTime;
                end
            end
            
            if f0 && f1 && f2
                entrusts.push(e);
                fprintf('executed entrust: %d at %s......\n',e.entrustNo,datestr(e.complete_time_,'yyyy-mm-dd HH:MM:SS'));

                % update trades as well
                if e.offsetFlag == 1
                    %open long or open short
                    try
                        tradestopdatetime = gettradestoptime(e.instrumentCode,e.complete_time_,e.signalinfo_.frequency,floor(e.signalinfo_.lengthofperiod/2));
                    catch
                        tradestopdatetime = [];
                    end
                    trade = cTradeOpen('id',e.tradeid_,...
                        'countername',obj.book_.countername_,...
                        'bookname',obj.book_.bookname_,...
                        'code',e.instrumentCode,...
                        'opendatetime',e.complete_time_,...
                        'openvolume',e.dealVolume,...
                        'openprice',e.dealPrice,...
                        'opendirection',e.direction,...
                        'stopdatetime',tradestopdatetime);
                    if ~isempty(e.signalinfo_)
                       try 
                           trade.setsignalinfo('name',e.signalinfo_.name,'extrainfo',e.signalinfo_);
                       catch
                       end
                    end
                    obj.trades_.push(trade);
                elseif e.offsetFlag == -1
                    tradeid = e.tradeid_;
                    %note:yangyiran:20180907:tradeid_ are not assigned with
                    %the entrust in case we trades in manual mode and
                    %therefor one close trade might associated with more
                    %than one tradeopen
                    if ~isempty(tradeid)
                        %this entrust shall be generated automatically by
                        %the strategy
                        ntrades = obj.trades_.latest_;
                        for itrade = 1:ntrades
                            trade_i = obj.trades_.node_(itrade);
                            if strcmpi(trade_i.id_,tradeid)
                                instrument = trade_i.instrument_;
                                trade_i.status_ = 'closed';
                                trade_i.closedatetime1_ = e.complete_time_;
                                trade_i.closeprice_ = e.price;
                                trade_i.runningpnl_ = 0;
                                trade_i.closepnl_ = trade_i.opendirection_*trade_i.openvolume_*(e.price-trade_i.openprice_)/ instrument.tick_size * instrument.tick_value;
                            end
                        end
                    else
                        instrumentcode = e.instrumentCode;
                        dealvolume = e.dealVolume;
                        direction = e.direction;
                        ntrades = obj.trades_.latest_;
                        volumeremained = dealvolume;
                        for itrade = 1:ntrades
                            trade_i = obj.trades_.node_(itrade);
                            if strcmpi(trade_i.code_,instrumentcode) && ~strcmpi(trade_i.status_,'closed') ...
                                    && volumeremained > 0 && direction ~= trade_i.opendirection_ 
                                instrument = trade_i.instrument_;
                                volumeremained = volumeremained - trade_i.openvolume_;
                                if volumeremained >= 0
                                    trade_i.status_ = 'closed';
                                    trade_i.closedatetime1_ = e.complete_time_;
                                    trade_i.closeprice_ = e.price;
                                    trade_i.runningpnl_ = 0;
                                    trade_i.closepnl_ = trade_i.opendirection_*trade_i.openvolume_*(e.price-trade_i.openprice_)/ instrument.tick_size * instrument.tick_value;
                                else
                                    %note:partially closed
                                    %yangyiran:20180907:we take the
                                    %following steps
                                    %1.we hard copy a new trade from the
                                    %orignal trade
                                    %2.we set the new trade fully closed
                                    %with changing its open volume to the
                                    %volume closed
                                    %3.we set the orignal trade still open
                                    %but to change its open volume to the
                                    %volume still not closed
                                    newtrade = trade_i.copy;
                                    newtrade.openvolume_ = trade_i.openvolume_ + volumeremained; 
                                    newtrade.status_ = 'closed';
                                    newtrade.closedatetime1_ = e.complete_time_;
                                    newtrade.closeprice_ = e.price;
                                    newtrade.runningpnl_ = 0;
                                    newtrade.closepnl_ = newtrade.opendirection_*newtrade.openvolume_*(e.price-newtrade.openprice_)/ instrument.tick_size * instrument.tick_value; 
                                    %
                                    trade_i.openvolume_ = -volumeremained;
                                    obj.trades_.push(newtrade);                                    
                                    volumeremained = 0;
                                end
                            end
                        end
                    end
                end
                
                positions = obj.trades_.convert2positions;
                obj.book_.setpositions(positions);    
                
            elseif f0 && f1 && ~f2
                % this entrust is canceled
                entrusts.push(e);
            end
        end
        
    end
    
    nf = entrusts.latest;
    for i = 1:nf
        npending = obj.entrustspending_.latest;
        for j = npending:-1:1
            if obj.entrustspending_.node(j).entrustNo == entrusts.node(i).entrustNo
                rmidx = j;
                obj.entrustspending_.removeByIndex(rmidx);
                break
            end
        end
        nfinished = obj.entrustsfinished_.latest;
        flag = false;
        for j = 1:nfinished
            if obj.entrustsfinished_.node(j).entrustNo == entrusts.node(i).entrustNo
                flag = true;
                break
            end
        end
        if ~flag
            obj.entrustsfinished_.push(e);
        end
    end
end