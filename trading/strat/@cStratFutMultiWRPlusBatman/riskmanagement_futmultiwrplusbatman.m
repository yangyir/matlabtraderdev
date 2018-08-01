function [] = riskmanagement_futmultiwrplusbatman(obj,dtnum)
%     error('cStratFutMultiWRPlusBatman:riskmanagement_futmultiwrplusbatman not implemented')

    
    ntrades = obj.helper_.trades_.latest_;
    %set risk manager
    for i = 1:ntrades
        trade_i = obj.helper_.trades_.node_(i);
        if strcmpi(trade_i.status_,'closed'), continue; end
        if ~isempty(trade_i.riskmanager_), continue;end
        %
        instrument = trade_i.instrument_;
        bandtype = obj.getbandtype(instrument);
        if bandtype ~= 0, errot('cStratFutMultiWRPlusBatman:riskmanagement_futmultiwrplusbatman:invalid type for batman');end
        bandwidthmin = obj.getbandwidthmin(instrument);
        bandwidthmax = obj.getbandwidthmax(instrument);
        bandstoploss = obj.getbandstoploss(instrument);
        bandtarget = obj.getbandtarget(instrument);      
        extrainfo = struct('bandstoploss',bandstoploss,...
            'bandtarget',bandtarget,...
            'bandwidthmin',bandwidthmin,...
            'bandwidthmax',bandwidthmax);
        trade_i.setriskmanager('name','batman','extrainfo',extrainfo);        
    end
    
    %set status of trade
    for i = 1:ntrades
        trade_i = obj.helper_.trades_.node_(i);
        unwindtrade = trade_i.riskmanager_.riskmanagement('MDEFut',obj.mde_fut_,...
            'UpdatePnLForClosedTrade',true);
        if ~isempty(unwindtrade)
            instrument = unwindtrade.instrument_;
            direction = unwindtrade.opendirection_;
            code = instrument.code_ctp;
            volume = unwindtrade.openvolume_;
            bidspread = obj.getbidspread(instrument);
            askspread = obj.getaskspread(instrument);
            lasttick = obj.mde_fut_.getlasttick(instrument);
                        
            %we need to unwind the trade
            if strcmpi(obj.mode_,'replay')
                closetodayFlag = 0;
            else
                closetodayFlag = isclosetoday(unwindtrade.opendatetime1_,lasttick(1));
            end
            if direction == 1
                overridepx = lasttick(2) + bidspread*instrument.tick_size;
                ret = obj.shortclosesingleinstrument(code,...
                    volume,...
                    closetodayFlag,...
                    bidspread,...
                    'time',lasttick(1),...
                    'overrideprice',overridepx);
            elseif direction == -1
                overridepx = lasttick(3) - askspread*instrument.tick_size;
                ret = obj.longclosesingleinstrument(code,...
                    volume,...
                    closetodayFlag,...
                    askspread,...
                    'time',lasttick(1),...
                    'overrideprice',overridepx);
            end
            if ret
                trade_i.closedatetime1_ = lasttick(1);
                trade_i.closedatetime2_ = datestr(lasttick(1),'yyyy-mm-dd HH:MM:SS');
                trade_i.closeprice_ = overridepx;
                trade_i.runningpnl_ = 0;
                trade_i.closepnl_ = direction*volume*(overridepx-trade_i.openprice_)/ instrument.tick_size * instrument.tick_value;  
            end  
            
        end
        
        
%         trade_i = obj.helper_.trades_.node_(i);
%         if strcmpi(trade_i.status_,'closed'), continue; end
%         instrument = trade_i.instrument_;
%         candlesticks = obj.mde_fut_.getcandles(instrument);
%         candleK = candlesticks{1};
%         
%         if strcmpi(trade_i.status_,'unset')
%            openBucket = gettradeopenbucket(trade_i,trade_i.opensignal_.frequency_);
%            candleTime = candleK(end,1);
%             if openBucket < candleTime
%                 trade_i.status_ = 'set';
%             end 
%         else
%             if isempty(trade_i.riskmanager_), continue;end
%             
%             tick = obj.mde_fut_.getlasttick(instrument);
%             unwindtrade = trade_i.riskmanager_.riskmanagementwithtick(tick,...
%                 'UpdatePnLForClosedTrade',true);
%             if ~isempty(unwindtrade)
%                 trade_i.status_ = 'closed';
% %                 fprintf('trade unwinded!\n');
%                 continue;
%             end
%             
%             try
%                 candlepoped = candleK(end-1,:);
%                 unwindtrade = trade_i.riskmanager_.riskmanagementwithcandle(candlepoped,...
%                     'debug',false,'usecandlelastonly',false,'updatepnlforclosedtrade',true);
%                 if ~isempty(unwindtrade)
%                     trade_i.status_ = 'closed';
%                     continue;
%                 end
%                 
%             catch
%             end
%             
%         
%         end
%         
%       
%      
        
       
        

        
        
    end
    
    
    return
    
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
                        ret = obj.shortclosesingleinstrument(code,volume,closetodayFlag,spread,'time',tick_time);
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
                        ret = obj.longclosesingleinstrument(code,volume,closetodayFlag,spread,'time',tick_time);
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