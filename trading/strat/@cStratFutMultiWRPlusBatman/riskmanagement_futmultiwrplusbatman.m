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
        isinstrumenttraded = strategy.bookrunning_.hasposition(instruments{i});
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
            trade_i = trades.node_(i);
            direction = trade_i.direction_;
            volume = trade_i.volume_;
            timeopen = trade_i.opendatetime1_;
            pxopen = trade_i.openprice_;
            if strcmpi(trade_i.status_,'unset')
                %
                lowestp = obj.getlownperiods(instrument);
                highestp = obj.gethighnperiods(instrument);
                
                %note:todo:0.01 and 0.02 are hard coded here and shall be
                %replaced with variables set elsewhere
                pxstoploss = pxopen-direction*(highestp-lowestp)*0.01;
                pxtarget = pxopen+direction*(highestp-lowestp)*0.02;
                %
                %round to tradeable price
                pxstoploss = round(pxstoploss/tick_size)*tick_size;
                pxtarget = round(pxtarget/tick_size)*tick_size;
                %
                obj.helper_.trades_.node_(i).targetprice_ = pxtarget;
                obj.helper_.trades_.node_(i).stoplossprice_ = pxstoploss;
                obj.helper_.trades_.node_(i).status_ = 'set';
                obj.helper_.trades_.node_(i).riskmanagementmethod_ = 'batman';
                %
                obj.helper_.trades_.node_(i).batman_.pxtarget_ = pxtarget;
                obj.helper_.trades_.node_(i).batman_.pxstoploss_ = pxstoploss;
            elseif strcmpi(trade_i.status_,'set')
                if ~strcmpi(trade_i.batman_.status_,'closed')
                    %note:if the trade is set but not closed yet, as per
                    %backtest, 1)we check whether the tick price breaches
                    %the stoploss and 2)whether the last candles close
                    %breaches the relavent levels
                    if direction == 1 && tick_bid <= trade_i.stoplossprice_
                        trade_i.batman_.status_ = 'closed';
                        trade_i.batman_.checkflag_ = 0;
                        %we use dtnum and timeopen to set the
                        %closetodayflag
                        closetodayFlag = isclosetoday(timeopen,tick_time);
                        spread = 0;
                        ret = obj.shortclosesingleinstrument(code,volume,closetodayFlag,spread);
                        if ret
                            trade_i.closetime1_ = tick_time;
                            trade_i.closeprice_ = trade_i.stoplossprice_;
                            trade_i.runningpnl_ = 0;
                            trade_i.closepnl_ = direction*volume*(trade_i.pxstoploss_-trade_i.pxopenreal_)/ tick_size * tick_value;
                        end
                        continue;
                        %stop the trade
                    elseif direction == -1 && tick_ask >= trade_i.stoplossprice_
                        %stop the trade
                        trade_i.batman_.status_ = 'closed';
                        trade_i.batman_.checkflag_ = 0;
                        %we use dtnum and timeopen to set the
                        %closetodayflag 
                        closetodayFlag = isclosetoday(timeopen,dtnum);
                        spread = 0;
                        ret = obj.longclosesingleinstrument(code,volume,closetodayFlag,spread);
                        if ret
                            trade_i.closetime1_ = dtnum;
                            trade_i.closeprice_ = trade_i.stoplossprice_;
                            trade_i.runningpnl_ = 0;
                            trade_i.closepnl_ = direction*volume*(trade_i.pxstoploss_-trade_i.pxopenreal_)/ tick_size * tick_value;
                        end
                        continue;
                    end
                    %
                    if lasttickincandle
                        trade_i.batman_.update('candle',candle);
                    end
                end
                
            end
            
            
        end
        
        
    end
end