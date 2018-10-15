function [] = riskmanagement_futmultiwrplusbatman(obj,dtnum)
    
    ismarketopen = zeros(obj.count,1);
    instruments = obj.getinstruments;
    for i = 1:obj.count
        %firstly to check whether this is in trading hours
        ismarketopen(i) = istrading(dtnum,instruments{i}.trading_hours,...
            'tradingbreak',instruments{i}.trading_break);
    end
    
    if sum(ismarketopen) == 0, return; end
    
    ntrades = obj.helper_.trades_.latest_;
    %set risk manager
    for i = 1:ntrades
        trade_i = obj.helper_.trades_.node_(i);
        if strcmpi(trade_i.status_,'closed'), continue; end
        if ~isempty(trade_i.riskmanager_), continue;end
        %
        instrument = trade_i.instrument_;
        bandtype = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandtype');
        if bandtype ~= 0, error('cStratFutMultiWRPlusBatman:riskmanagement_futmultiwrplusbatman:invalid type for batman');end
        
        bandwidthmin = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmin');
        bandwidthmax = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmax');
        bandstoploss = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandstoploss');
        bandtarget = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandtarget');
        
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
            'UpdatePnLForClosedTrade',false);
        if ~isempty(unwindtrade)
            instrument = unwindtrade.instrument_;
            direction = unwindtrade.opendirection_;
            code = instrument.code_ctp;
            volume = unwindtrade.openvolume_;
            bidclosespread = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bidclosespread');
            askclosespread = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','askclosespread');
            lasttick = obj.mde_fut_.getlasttick(instrument);
            tradeid = unwindtrade.id_;
                        
            %we need to unwind the trade
            if strcmpi(obj.mode_,'replay')
                closetodayFlag = 0;
            else
                closetodayFlag = isclosetoday(unwindtrade.opendatetime1_,lasttick(1));
            end
            if direction == 1
                overridepx = lasttick(2) + bidclosespread*instrument.tick_size;
                ret = obj.shortclose(code,...
                    volume,...
                    closetodayFlag,...
                    'time',lasttick(1),...
                    'overrideprice',overridepx,...
                    'tradeid',tradeid);
            elseif direction == -1
                overridepx = lasttick(3) - askclosespread*instrument.tick_size;
                ret = obj.longclose(code,...
                    volume,...
                    closetodayFlag,...
                    'time',lasttick(1),...
                    'overrideprice',overridepx,...
                    'tradeid',tradeid);
            end
            %we shall only replace entrust here and we are not sure whether
            %entrust is executed or not
            if ret
%                 trade_i.closedatetime1_ = lasttick(1);
%                 trade_i.closedatetime2_ = datestr(lasttick(1),'yyyy-mm-dd HH:MM:SS');
%                 trade_i.closeprice_ = overridepx;
%                 trade_i.runningpnl_ = 0;
%                 trade_i.closepnl_ = direction*volume*(overridepx-trade_i.openprice_)/ instrument.tick_size * instrument.tick_value;  
            end  
            
        end
                
    end
    
end