function [] = riskmanagement_futmultiwrplusbatman_sunq(obj,dtnum)
%     error('cStratFutMultiWRPlusBatman:riskmanagement_futmultiwrplusbatman not implemented')
    instruments = obj.instruments_.getinstrument;
    for i = 1:obj.count
        %firstly to check whether this is in trading hours
        ismarketopen = istrading(dtnum,instruments{i}.trading_hours,...
            'tradingbreak',instruments{i}.trading_break);
        if ~ismarketopen, continue; end
 
        %secondly to check whether the instrument has been traded
        %and recorded in the embedded portfolio
        isinstrumenttraded = obj.bookrunning_.hasposition(instruments{i});
        if ~isinstrumenttraded, continue; end
        
        instrument = instruments{i};
        code = instrument.code_ctp;
        tick_size = instrument.tick_size;
        tick_value = instrument.tick_value;
        %
        tick = obj.mde_fut_.getlasttick(instrument);
        tick_time = tick(1);
        tick_bid = tick(2);
        tick_ask = tick(3);
        %
%         candle = obj.mde_fut_.getlastcandle(instrument);
%         candle = candle{1};
            lasttickincandle = obj.mde_fut_.newset_ ;
        %filter out trades associated with this particular futures
        %instrument
        trades = obj.helper_.trades_.filterbycode(code);
        ntrades = trades.latest_;
        for j = 1:ntrades
            trade_j = trades.node_(j);
            timeopen = trade_j.opendatetime1_;
            direction = trade_j.opendirection_;
            volume = trade_j.openvolume_;
            pxopen = trade_j.openprice_; 
            if strcmpi(trade_j.status_,'unset')
                %
                lowestp = obj.getlownperiods(instrument);
                highestp = obj.gethighnperiods(instrument);

                pxstoploss = pxopen-direction*(highestp-lowestp) * trade_j.batman_.bandstoploss_;
                pxtarget = pxopen+direction*(highestp-lowestp) * trade_j.batman_.bandtarget_;
                %
                %round to tradeable price
                pxstoploss = round(pxstoploss/tick_size)*tick_size;
                pxtarget = round(pxtarget/tick_size)*tick_size;
                %
                trade_j.targetprice_ = pxtarget;
                trade_j.stoplossprice_ = pxstoploss;
                if lasttickincandle == 1
                    trade_j.status_ = 'set';
                end
                trade_j.riskmanagementmethod_ = 'batman';
                %
                trade_j.batman_.pxtarget_ = pxtarget;
                trade_j.batman_.pxstoploss_ = pxstoploss;
                trade_j.batman_.pxopen_ = pxopen;
                trade_j.batman_.checkflag_ = 0;
                trade_j.batman_.pxsupportmin_ = -1;
                trade_j.batman_.pxsupportmax_ = -1;
            elseif strcmpi(trade_j.status_,'set')
                if ~strcmpi(trade_j.batman_.status_,'closed')
                    %note:if the trade is set but not closed yet, as per
                    %backtest, 1)we check whether the tick price breaches
                    %the stoploss and 2)whether the last candles close
                    %breaches the relavent levels
                    if (trade_j.batman_.pxsupportmin_ == -1 && trade_j.batman_.pxsupportmax_ == -1)
                        if direction == 1
                            if tick_bid <= trade_j.stoplossprice_
                                trade_j.batman_.status_ = 'closed';
                                %we use dtnum and timeopen to set the
                                %closetodayflag
                                if strcmpi(obj.mode_,'replay')
                                    closetodayFlag = 0;
                                else
                                    closetodayFlag = isclosetoday(timeopen,tick_time);
                                end
                                spread = 0;
                                ret = obj.shortclosesingleinstrument(code,volume,closetodayFlag,spread,'time',tick_time);
                                if ret
                                    trade_j.closetime1_ = tick_time;
                                    trade_j.closetime2_ = datestr(tick_time);
                                    trade_j.closeprice_ = trade_j.stoplossprice_;
                                    trade_j.runningpnl_ = 0;
                                    trade_j.closepnl_ = direction*volume*(trade_j.closeprice_-trade_j.openprice_)/ tick_size * tick_value;
                                end
                                continue;
                            elseif tick_bid < trade_j.targetprice_ && tick_bid > trade_j.stoplossprice_
                                %do nothing and wait for the next trade price
                            elseif tick_bid >= trade_j.targetprice_
                                trade_j.batman_.pxresistence_ = tick_bid;
                                %here I am not sure to use tick_bid as be highprice????????????????
                                trade_j.batman_.pxsupportmin_ = trade_j.batman_.pxresistence_ - (trade_j.batman_.pxresistence_ - trade_j.batman_.pxopen_)*trade_j.batman_.bandwidthmin_;
                                trade_j.batman_.pxsupportmax_ = trade_j.batman_.pxresistence_ - (trade_j.batman_.pxresistence_ - trade_j.batman_.pxopen_)*trade_j.batman_.bandwidthmax_;
                            end
                        elseif direction == -1
                            if tick_ask >= trade_j.stoplossprice_
                                trade_j.batman_.status_ = 'closed';
                                %stop the trade
                                %we use dtnum and timeopen to set the
                                %closetodayflag 
                                if strcmpi(obj.mode_,'replay')
                                    closetodayFlag = 0;
                                else
                                    closetodayFlag = isclosetoday(timeopen,tick_time);
                                end
                                spread = 0;
                                ret = obj.longclosesingleinstrument(code,volume,closetodayFlag,spread,'time',tick_time);
                                if ret
                                    trade_j.closetime1_ = tick_time;
                                    trade_j.closetime2_ = datestr(tick_time);
                                    trade_j.closeprice_ = trade_j.stoplossprice_;
                                    trade_j.runningpnl_ = 0;
                                    trade_j.closepnl_ = direction*volume*(trade_j.closeprice_-trade_j.openprice_)/ tick_size * tick_value;
                                end
                                continue;
                            elseif tick_ask > trade_j.targetprice_ && tick_ask < trade_j.stoplossprice_
                                %do nothing and wait for the next trade price
                            elseif tick_ask <= trade_j.targetprice_
                                trade_j.batman_.pxresistence_ = tick_ask;
                                trade_j.batman_.pxsupportmin_ = trade_j.batman_.pxresistence_ + (trade_j.batman_.pxopen_ - trade_j.batman_.pxresistence_)*trade_j.batman_.bandwidthmin_;
                                trade_j.batman_.pxsupportmax_ = trade_j.batman_.pxresistence_ + (trade_j.batman_.pxopen_ - trade_j.batman_.pxresistence_)*trade_j.batman_.bandwidthmax_;
                            end
                        else
                            error('cStratFutMultiWRBatman:riskmanagement:invalid direction of position')
                        end
                        %
                        trade_j.batman_.checkflag_ = 0;
                        continue
                    end

                    % to stop loss using trade_j.stoplossprice_ (using ticks value)
                    if direction == 1
                        if tick_bid <= trade_j.stoplossprice_
                            trade_j.batman_.status_ = 'closed';
                            if strcmpi(obj.mode_,'replay')
                                closetodayFlag = 0;
                            else
                                closetodayFlag = isclosetoday(timeopen,tick_time);
                            end
                            spread = 0;
                            ret = obj.shortclosesingleinstrument(code,volume,closetodayFlag,spread,'time',tick_time);
                            if ret
                                trade_j.closetime1_ = tick_time;
                                trade_j.closetime2_ = datestr(tick_time);
                                trade_j.closeprice_ = trade_j.stoplossprice_;
                                trade_j.runningpnl_ = 0;
                                trade_j.closepnl_ = direction*volume*(trade_j.closeprice_-trade_j.openprice_)/ tick_size * tick_value;
                            end
                            continue;
                        end
                    elseif direction == -1
                        if tick_ask >= trade_j.stoplossprice_
                            trade_j.batman_.status_ = 'closed';
                            if strcmpi(obj.mode_,'replay')
                                closetodayFlag = 0;
                            else
                                closetodayFlag = isclosetoday(timeopen,tick_time);
                            end
                            spread = 0;
                            ret = obj.longclosesingleinstrument(code,volume,closetodayFlag,spread,'time',tick_time);
                            if ret
                                trade_j.closetime1_ = tick_time;
                                trade_j.closetime2_ = datestr(tick_time);
                                trade_j.closeprice_ = trade_j.stoplossprice_;
                                trade_j.runningpnl_ = 0;
                                trade_j.closepnl_ = direction*volume*(trade_j.closeprice_-trade_j.openprice_)/ tick_size * tick_value;
                            end
                            continue;
                        end
                    else
                        error('cStratFutMultiWRBatman:riskmanagement:invalid direction of position')
                    end   
                    %  we will run the following code until lasttickincandle equals 1
                    if lasttickincandle == 1
                        % long up_slope trend
                        if direction == 1
                            if trade_j.batman_.checkflag_ == 0
                                if tick_bid <= trade_j.batman_.pxsupportmax_
                                    trade_j.batman_.status_ = 'closed';
                                    if strcmpi(obj.mode_,'replay')
                                        closetodayFlag = 0;
                                    else
                                        closetodayFlag = isclosetoday(timeopen,tick_time);
                                    end
                                    spread = 0;
                                    ret = obj.shortclosesingleinstrument(code,volume,closetodayFlag,spread,'time',tick_time);
                                    if ret
                                        trade_j.closetime1_ = tick_time;
                                        trade_j.closetime2_ = datestr(tick_time);
                                        trade_j.closeprice_ = trade_j.batman_.pxsupportmax_;
                                        trade_j.runningpnl_ = 0;
                                        trade_j.closepnl_ = direction*volume*(trade_j.closeprice_-trade_j.openprice_)/ tick_size * tick_value;
                                    end
                                    continue;
                                elseif tick_bid >= trade_j.batman_.pxresistence_
                                    trade_j.batman_.pxresistence_ = tick_bid;
                                    trade_j.batman_.pxsupportmin_ = trade_j.batman_.pxresistence_ -(trade_j.batman_.pxresistence_ - trade_j.batman_.pxopen_)*trade_j.batman_.bandwidthmin_;
                                    trade_j.batman_.pxsupportmax_ = trade_j.batman_.pxresistence_ -(trade_j.batman_.pxresistence_ - trade_j.batman_.pxopen_)*trade_j.batman_.bandwidthmax_;
                                    trade_j.batman_.checkflag_ = 0;
                                elseif  tick_bid < trade_j.batman_.pxresistence_ && tick_bid > trade_j.batman_.pxsupportmin_
                                    trade_j.batman_.checkflag_ = 0;
                                elseif tick_bid <= trade_j.batman_.pxsupportmin_ && tick_bid > trade_j.batman_.pxsupportmax_
                                    %indicating the first round of trend is over but we
                                    %may have a second trend in case withdrawmax is not
                                    %breahed from the top.now we need to update the
                                    %open price
                                    trade_j.batman_.pxopen_ = tick_bid;
                                    trade_j.batman_.pxsupportmin_ = trade_j.batman_.pxresistence_ -(trade_j.batman_.pxresistence_ - trade_j.batman_.pxopen_)*trade_j.batman_.bandwidthmin_;
                                    trade_j.batman_.pxsupportmax_ = trade_j.batman_.pxresistence_ -(trade_j.batman_.pxresistence_ - trade_j.batman_.pxopen_)*trade_j.batman_.bandwidthmax_;
                                    trade_j.batman_.checkflag_ = 1;
                                end
                            elseif trade_j.batman_.checkflag_ == 1
                                if tick_bid <= trade_j.batman_.pxsupportmax_
                                    trade_j.batman_.status_ = 'closed';
                                    if strcmpi(obj.mode_,'replay')
                                        closetodayFlag = 0;
                                    else
                                        closetodayFlag = isclosetoday(timeopen,tick_time);
                                    end
                                    spread = 0;
                                    ret = obj.shortclosesingleinstrument(code,volume,closetodayFlag,spread,'time',tick_time);
                                    if ret
                                        trade_j.closetime1_ = tick_time;
                                        trade_j.closetime2_ = datestr(tick_time);
                                        trade_j.closeprice_ = trade_j.batman_.pxsupportmax_;
                                        trade_j.runningpnl_ = 0;
                                        trade_j.closepnl_ = direction*volume*(trade_j.closeprice_-trade_j.openprice_)/ tick_size * tick_value;
                                    end
                                    continue;
                                elseif tick_bid >= trade_j.batman_.pxresistence_
                                    trade_j.batman_.pxresistence_ = tick_bid;
                                    trade_j.batman_.pxsupportmin_ = trade_j.batman_.pxresistence_ -(trade_j.batman_.pxresistence_ - trade_j.batman_.pxopen_)*trade_j.batman_.bandwidthmin_;
                                    trade_j.batman_.pxsupportmax_ = trade_j.batman_.pxresistence_ -(trade_j.batman_.pxresistence_ - trade_j.batman_.pxopen_)*trade_j.batman_.bandwidthmax_;
                                    trade_j.batman_.checkflag_ = 0;
                                elseif tick_bid <= trade_j.batman_.pxsupportmin_ && tick_bid > trade_j.batman_.pxsupportmax_
                                    trade_j.batman_.pxopen_ = min(trade_j.batman_.pxopen_,tick_bid);
                                    trade_j.batman_.pxsupportmin_ = trade_j.batman_.pxresistence_ -(trade_j.batman_.pxresistence_ - trade_j.batman_.pxopen_)*trade_j.batman_.bandwidthmin_;
                                    trade_j.batman_.pxsupportmax_ = trade_j.batman_.pxresistence_ -(trade_j.batman_.pxresistence_ - trade_j.batman_.pxopen_)*trade_j.batman_.bandwidthmax_;
                                    trade_j.batman_.checkflag_ = 1;
                                elseif tick_bid < trade_j.batman_.pxresistence_ && tick_bid > trade_j.batman_.pxsupportmin_
                                    trade_j.batman_.checkflag = 1;
                                end
                            end
                            continue;
                        end


                        % short down-slope trend
                        if direction == -1
                            if trade_j.batman_.checkflag_ == 0
                                if tick_ask >= trade_j.batman_.pxsupportmax_
                                    trade_j.batman_.status_ = 'closed';
                                    if strcmpi(obj.mode_,'replay')
                                        closetodayFlag = 0;
                                    else
                                        closetodayFlag = isclosetoday(timeopen,tick_time);
                                    end
                                    spread = 0;
                                    ret = obj.longclosesingleinstrument(code,volume,closetodayFlag,spread,'time',tick_time);
                                    if ret
                                        trade_j.closetime1_ = tick_time;
                                        trade_j.closetime2_ = datestr(tick_time);
                                        trade_j.closeprice_ = trade_j.batman_.pxsupportmax_;
                                        trade_j.runningpnl_ = 0;
                                        trade_j.closepnl_ = direction*volume*(trade_j.closeprice_-trade_j.openprice_)/ tick_size * tick_value;
                                    end
                                    continue;
                                elseif tick_ask <= trade_j.batman_.pxresistence_
                                    trade_j.batman_.pxresistence_ = tick_ask;
                                    trade_j.batman_.pxsupportmin_ = trade_j.batman_.pxresistence_ + (trade_j.batman_.pxopen_ - trade_j.batman_.pxresistence_)*trade_j.batman_.bandwidthmin_;
                                    trade_j.batman_.pxsupportmax_ = trade_j.batman_.pxresistence_ + (trade_j.batman_.pxopen_ - trade_j.batman_.pxresistence_)*trade_j.batman_.bandwidthmax_;
                                    trade_j.batman_.checkflag_ = 0;
                                elseif  tick_ask > trade_j.batman_.pxresistence_ && tick_ask < trade_j.batman_.pxsupportmin_
                                    trade_j.batman_.checkflag_ = 0;
                                elseif tick_ask >= trade_j.batman_.pxsupportmin_ && tick_ask < trade_j.batman_.pxsupportmax_
                                    %indicating the first round of trend is over but we
                                    %may have a second trend in case withdrawmax is not
                                    %breahed from the top.now we need to update the
                                    %open price
                                    trade_j.batman_.pxopen_ = tick_ask;
                                    trade_j.batman_.pxsupportmin_ = trade_j.batman_.pxresistence_ + (trade_j.batman_.pxopen_ - trade_j.batman_.pxresistence_)*trade_j.batman_.bandwidthmin_;
                                    trade_j.batman_.pxsupportmax_ = trade_j.batman_.pxresistence_ + (trade_j.batman_.pxopen_ - trade_j.batman_.pxresistence_)*trade_j.batman_.bandwidthmax_;
                                    trade_j.batman_.checkflag_ = 1;
                                end 
                            elseif trade_j.batman_.checkflag_ == 1
                                if tick_ask >= trade_j.batman_.pxsupportmax_
                                    trade_j.batman_.status_ = 'closed';
                                    if strcmpi(obj.mode_,'replay')
                                        closetodayFlag = 0;
                                    else
                                        closetodayFlag = isclosetoday(timeopen,tick_time);
                                    end
                                    spread = 0;
                                    ret = obj.longclosesingleinstrument(code,volume,closetodayFlag,spread,'time',tick_time);
                                    if ret
                                        trade_j.closetime1_ = tick_time;
                                        trade_j.closetime2_ = datestr(tick_time);
                                        trade_j.closeprice_ = trade_j.batman_.pxsupportmax_;
                                        trade_j.runningpnl_ = 0;
                                        trade_j.closepnl_ = direction*volume*(trade_j.closeprice_-trade_j.openprice_)/ tick_size * tick_value;
                                    end
                                    continue;
                                elseif tick_ask <= trade_j.batman_.pxresistence_
                                    trade_j.batman_.pxresistence_ = tick_ask;
                                    trade_j.batman_.pxsupportmin_ = trade_j.batman_.pxresistence_ + (trade_j.batman_.pxopen_ - trade_j.batman_.pxresistence_)*trade_j.batman_.bandwidthmin_;
                                    trade_j.batman_.pxsupportmax_ = trade_j.batman_.pxresistence_ + (trade_j.batman_.pxopen_ - trade_j.batman_.pxresistence_)*trade_j.batman_.bandwidthmax_;
                                    trade_j.batman_.checkflag_ = 0;
                                elseif tick_ask >= trade_j.batman_.pxsupportmin_ && tick_ask < trade_j.batman_.pxsupportmax_
                                    trade_j.batman_.pxopen_ = max(trade_j.batman_.pxopen_,tick_ask);
                                    trade_j.batman_.pxsupportmin_ = trade_j.batman_.pxresistence_ + (trade_j.batman_.pxopen_ - trade_j.batman_.pxresistence_)*trade_j.batman_.bandwidthmin_;
                                    trade_j.batman_.pxsupportmax_ = trade_j.batman_.pxresistence_ + (trade_j.batman_.pxopen_ - trade_j.batman_.pxresistence_)*trade_j.batman_.bandwidthmax_;
                                    trade_j.batman_.checkflag_ = 1;
                                elseif tick_ask > trade_j.batman_.pxresistence_ && tick_ask < trade_j.batman_.pxsupportmin_
                                    trade_j.batman_.checkflag = 1;
                                end
                            end
                            continue
                        end
                        %
                        %
                    end
                end
            end
        end
    end
end
                        
                        
                        
                        
                        
