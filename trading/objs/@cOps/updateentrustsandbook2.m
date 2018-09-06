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
                f0 = obj.book_.counter_.queryEntrust(e);
                %note:if e.volume == 0, it is closed. or if e.dealVolume +
                %e.cancleVolume == e.volume
                f1 = e.is_entrust_closed;
                f2 = e.dealVolume > 0;
                if f0 && f1 && f2
                    %note:yangyiran 20180810:we update the complete_time_
                    %here manually as the queryEntrust function doesn't
                    %return this information.
                    e.complete_time_ = now;
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
                        f1 = ticks(2) < e.price;
                    catch
                        f1 = 0;
                    end
                else
                    try
                        f1 = ticks(2) > e.price;
                    catch
                        f1 = 0;
                    end
                end
                f2 = f1;
                if f1
                    %once the entrust is executed
                    e.dealVolume = e.volume;
                    e.dealPrice = e.price;
                    e.complete_time_ = ticks(1);
                end
            end
            if f0 && f1 && f2
                entrusts.push(e);
                fprintf('executed entrust: %d at %s......\n',e.entrustNo,datestr(e.complete_time_,'yyyy-mm-dd HH:MM:SS'));
                
                %this entrust is fully placed and we shall update the book
%                 obj.book_.addpositions('code',e.instrumentCode,'price',e.price,...
%                     'volume',e.direction*e.dealVolume,'time',e.complete_time_,...
%                     'closetodayflag',e.closetodayFlag);

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
                        'openvolume',e.volume,...
                        'openprice',e.price,...
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
                    %close long or close short
                    tradeid = e.tradeid_;
                    ntrades = obj.trades_.latest_;
                    for itrade = 1:ntrades
                        trade_i = obj.trades_.node_(itrade);
                        if strcmpi(trade_i.id_,tradeid)
                            instrument = trade_i.instrument_;
                            trade_i.closedatetime1_ = e.complete_time_;
                            trade_i.closeprice_ = e.price;
                            trade_i.runningpnl_ = 0;
                            trade_i.closepnl_ = trade_i.opendirection_*trade_i.openvolume_*(e.price-trade_i.openprice_)/ instrument.tick_size * instrument.tick_value;
                        end
                    end
                end
                
                positions = obj.trades_.convert2positions;
                obj.book_.setpositions(positions);    
                
            elseif f0 && f1 && ~f2
                % this entrust is canceled
                fprintf('cancelled entrust: %d......\n',e.entrustNo);
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