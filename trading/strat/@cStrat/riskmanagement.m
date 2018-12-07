function [] = riskmanagement(obj,dtnum)
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
        
        instrument = trade_i.instrument_;
        riskmanagername = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','riskmanagername');
        stoptype = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','stoptypepertrade');
        stopamount = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','stopamountpertrade');
        if stopamount == -9.99
            pxstoploss = -trade_i.opendirection_*inf;
        else
            if strcmpi(stoptype,'rel')
                pxstoploss = trade_i.openprice_ * (1+trade_i.opendirection_*stopamount);
            elseif strcmpi(stoptype,'abs')
                pxstoploss = trade_i.openprice_ + trade_i.opendirection_*stopamount/(instrument.tick_value*trade_i.openvolume_)*instrument.tick_size;
            else
                error('ERROR:%s:riskmanagement:invalid stoptypepertrade',class(obj))
            end
        end
        %
        limittype = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','limittypepertrade');
        limitamount = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','limitamountpertrade');
        if limitamount == -9.99
            pxtarget = trade_i.opendirection_*inf;
        else
            if strcmpi(limittype,'rel')
                pxtarget = trade_i.openprice_ * (1+trade_i.opendirection_*limitamount);
            elseif strcmpi(limittype,'abs')
                pxtarget = trade_i.openprice_ + trade_i.opendirection_*limitamount/(instrument.tick_value*trade_i.openvolume_)*instrument.tick_size;
            else
                error('ERROR:%s:riskmanagement:invalid limittypepertrade',class(obj))
            end
        end
        %
        if strcmpi(riskmanagername,'standard')
            extrainfo = struct('pxtarget_',pxtarget,'pxstoploss_',pxstoploss);
        elseif strcmpi(riskmanagername,'batman')
            bandtype = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandtype');
            bandwidthmin = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmin');
            bandwidthmax = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmax');
            if bandtype == 0
                %conventional set-up with bandtype == 0
                bandstoploss = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandstoploss');
                bandtarget = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandtarget');
                extrainfo = struct('pxtarget',pxtarget,'pxstoploss',pxstoploss,...
                    'bandstoploss',bandstoploss,...
                    'bandtarget',bandtarget,...
                    'bandwidthmin',bandwidthmin,...
                    'bandwidthmax',bandwidthmax);
            elseif bandtype == 1
                extrainfo = struct('pxtarget_',pxtarget,'pxstoploss_',pxstoploss,...
                    'bandstoploss',-9.99,...
                    'bandtarget',-9.99,...
                    'bandwidthmin',bandwidthmin,...
                    'bandwidthmax',bandwidthmax);
            end
        end
        trade_i.setriskmanager('name',riskmanagername,'extrainfo',extrainfo);        
    end
    %
    %
    %set status of trade with risk management in place
    for i = 1:ntrades
        trade_i = obj.helper_.trades_.node_(i);
        if strcmpi(trade_i.status_,'closed'), continue; end
        
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
            if isempty(lasttick), continue;end
            tradeid = unwindtrade.id_;
                        
            %we need to unwind the trade
            if strcmpi(obj.mode_,'replay')
                closetodayFlag = 0;
            else
                closetodayFlag = isclosetoday(unwindtrade.opendatetime1_,lasttick(1));
            end
            if direction == 1
                overridepx = lasttick(2) + bidclosespread*instrument.tick_size;
                obj.shortclose(code,volume,closetodayFlag,...
                    'time',lasttick(1),...
                    'overrideprice',overridepx,...
                    'tradeid',tradeid);
            elseif direction == -1
                overridepx = lasttick(3) - askclosespread*instrument.tick_size;
                obj.longclose(code,volume,closetodayFlag,...
                    'time',lasttick(1),...
                    'overrideprice',overridepx,...
                    'tradeid',tradeid);
            end
        end
                
    end

end