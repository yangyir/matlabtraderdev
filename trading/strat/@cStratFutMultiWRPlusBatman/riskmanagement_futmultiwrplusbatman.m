function [] = riskmanagement_futmultiwrplusbatman(obj,dtnum)
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
        candle = obj.mde_fut_.getlastcandle(instrument);
        candle = candle{1};
        if (tick_time - candle(1)) * 24*60*60 - obj.samplefreq_(i)*60 <= 1
            lasttickincandle = 1;
        else
            lasttickincandle = 0;
        end
        
        %filter out trades associated with this particular futures
        %instrument
        trades = obj.helper_.trades_.filterbycode(code);
        ntrades = trades.latest_;
        for j = 1:ntrades
            trade_j = trades.node_(j);
            direction = trade_j.opendirection_;
            volume = trade_j.openvolume_;
            timeopen = trade_j.opendatetime1_;
            pxopen = trade_j.openprice_;
            if strcmpi(trade_j.status_,'unset')
                %
                lowestp = obj.getlownperiods(instrument);
                highestp = obj.gethighnperiods(instrument);
                
                %note:todo:0.02 and 0.05 are hard coded here and shall be
                %replaced with variables set elsewhere
                pxstoploss = pxopen-direction*(highestp-lowestp)*0.02;
                pxtarget = pxopen+direction*(highestp-lowestp)*0.05;
                %
                %round to tradeable price
                pxstoploss = round(pxstoploss/tick_size)*tick_size;
                pxtarget = round(pxtarget/tick_size)*tick_size;
                %
                trade_j.targetprice_ = pxtarget;
                trade_j.stoplossprice_ = pxstoploss;
                trade_j.status_ = 'set';
                trade_j.riskmanagementmethod_ = 'batman';
                %
                trade_j.batman_.pxtarget_ = pxtarget;
                trade_j.batman_.pxstoploss_ = pxstoploss;
            elseif strcmpi(trade_j.status_,'set')
                if ~strcmpi(trade_j.batman_.status_,'closed')
                    %note:if the trade is set but not closed yet, as per
                    %backtest, 1)we check whether the tick price breaches
                    %the stoploss and 2)whether the last candles close
                    %breaches the relavent levels
                    if direction == 1 && tick_bid <= trade_j.stoplossprice_
                        trade_j.batman_.status_ = 'closed';
                        trade_j.batman_.checkflag_ = 0;
                        %we use dtnum and timeopen to set the
                        %closetodayflag
                        if strcmpi(obj.mode_,'replay')
                            closetodayFlag = 0;
                        else
                            closetodayFlag = isclosetoday(timeopen,tick_time);
                        end
                        spread = 0;
                        ret = obj.shortclosesingleinstrument(code,volume,closetodayFlag,spread);
                        if ret
                            trade_j.closetime1_ = tick_time;
                            trade_j.closetime2_ = datestr(tick_time);
                            trade_j.closeprice_ = trade_j.stoplossprice_;
                            trade_j.runningpnl_ = 0;
                            trade_j.closepnl_ = direction*volume*(trade_j.stoplossprice_-trade_j.openprice_)/ tick_size * tick_value;
                        end
                        continue;
                        %stop the trade
                    elseif direction == -1 && tick_ask >= trade_j.stoplossprice_
                        %stop the trade
                        trade_j.batman_.status_ = 'closed';
                        trade_j.batman_.checkflag_ = 0;
                        %we use dtnum and timeopen to set the
                        %closetodayflag 
                        if strcmpi(obj.mode_,'replay')
                            closetodayFlag = 0;
                        else
                            closetodayFlag = isclosetoday(timeopen,tick_time);
                        end
                        spread = 0;
                        ret = obj.longclosesingleinstrument(code,volume,closetodayFlag,spread);
                        if ret
                            trade_j.closetime1_ = tick_time;
                            trade_j.closetime2_ = datestr(tick_time);
                            trade_j.closeprice_ = trade_j.stoplossprice_;
                            trade_j.runningpnl_ = 0;
                            trade_j.closepnl_ = direction*volume*(trade_j.stoplossprice_-trade_j.openprice_)/ tick_size * tick_value;
                        end
                        continue;
                    end
                    %
                    if lasttickincandle
                        trade_j.batman_.update('candle',candle);
                        if strcmpi(trade_j.batman_.status_,'closed')
                            trade_j.closetime1_ = tick_time;
                            trade_j.closetime2_ = datestr(tick_time);
                        end
                    end
                end
                
            end
            
            
        end
        
        
    end
end