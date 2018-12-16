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
        
        if isa(trade_i.opensignal_,'cManualInfo')
            pxtarget = trade_i.opensignal_.pxtarget_;
            if pxtarget == -9.99, pxtarget = trade_i.opendirection_*inf;end
            pxstoploss = trade_i.opensignal_.pxstoploss_;
            if pxstoploss == -9.99,pxstoploss = trade_i.opendirection_*(-inf);end
            if strcmpi(trade_i.opensignal_.riskmanagername_,'standard')
                extrainfo = struct('pxtarget_',pxtarget,'pxstoploss_',pxstoploss);
            elseif strcmpi(trade_i.opensignal_.riskmanagername_,'batman')
                try
                    bandwidthmin = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmin');
                catch
                    bandwidthmin = 0.3333;  %default value 1/3
                end
                try
                    bandwidthmax = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmax');
                catch
                    bandwidthmax = 0.5;     %default value 1/2
                end
                extrainfo = struct('pxtarget_',pxtarget,...
                    'pxstoploss_',pxstoploss,...
                    'bandstoploss_',-9.99,...
                    'bandtarget_',-9.99,...
                    'bandwidthmin_',bandwidthmin,...
                    'bandwidthmax_',bandwidthmax);
            end
            trade_i.setriskmanager('name',trade_i.opensignal_.riskmanagername_,'extrainfo',extrainfo);
            %
        else
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
                try
                    bandtype = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandtype');
                catch
                    bandtype = 1;
                end
                try
                    bandwidthmin = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmin');
                catch
                    bandwidthmin = 0.3333;  %default value 1/3
                end
                try
                    bandwidthmax = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmax');
                catch
                    bandwidthmax = 0.5;     %default value 1/2
                end
                if bandtype == 0
                    %conventional set-up with bandtype == 0
                    bandstoploss = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandstoploss');
                    bandtarget = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandtarget');
                    extrainfo = struct('pxtarget_',pxtarget,...
                        'pxstoploss_',pxstoploss,...
                        'bandstoploss_',bandstoploss,...
                        'bandtarget_',bandtarget,...
                        'bandwidthmin_',bandwidthmin,...
                        'bandwidthmax_',bandwidthmax);
                elseif bandtype == 1
                    try
                        wrmode = trade_i.opensignal_.wrmode_;
                        isflash = strcmpi(wrmode,'flash');
                    catch
                        isflash = false;
                    end
                    if isflash
                        if trade_i.opendirection_ == 1
                            pxstoploss = trade_i.opensignal_.lowestlow_;
                        else
                            pxstoploss = trade_i.opensignal_.highesthigh_;
                        end
                        pxtarget = trade_i.openprice_ + trade_i.opendirection_*abs(trade_i.openprice_-pxstoploss)*0.5;
                        extrainfo = struct('pxtarget_',pxtarget,...
                            'pxstoploss_',pxstoploss,...
                            'bandstoploss_',-9.99,...
                            'bandtarget_',-9.99,...
                            'bandwidthmin_',bandwidthmin,...
                            'bandwidthmax_',bandwidthmax);
                        trade_i.status_ = 'set';
                    else
                        extrainfo = struct('pxtarget_',pxtarget,...
                            'pxstoploss_',pxstoploss,...
                            'bandstoploss_',-9.99,...
                            'bandtarget_',-9.99,...
                            'bandwidthmin_',bandwidthmin,...
                            'bandwidthmax_',bandwidthmax);
                    end
                end
            end
            trade_i.setriskmanager('name',riskmanagername,'extrainfo',extrainfo);
        end
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
            obj.unwindtrade(unwindtrade);
%             instrument = unwindtrade.instrument_;
%             direction = unwindtrade.opendirection_;
%             code = instrument.code_ctp;
%             volume = unwindtrade.openvolume_;
%             bidclosespread = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bidclosespread');
%             askclosespread = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','askclosespread');
%             lasttick = obj.mde_fut_.getlasttick(instrument);
%             if isempty(lasttick), continue;end
%             tradeid = unwindtrade.id_;
%                         
%             %we need to unwind the trade
%             if strcmpi(obj.mode_,'replay')
%                 closetodayFlag = 0;
%             else
%                 closetodayFlag = isclosetoday(unwindtrade.opendatetime1_,lasttick(1));
%             end
%             if direction == 1
%                 overridepx = lasttick(2) + bidclosespread*instrument.tick_size;
%                 obj.shortclose(code,volume,closetodayFlag,...
%                     'time',lasttick(1),...
%                     'overrideprice',overridepx,...
%                     'tradeid',tradeid);
%             elseif direction == -1
%                 overridepx = lasttick(3) - askclosespread*instrument.tick_size;
%                 obj.longclose(code,volume,closetodayFlag,...
%                     'time',lasttick(1),...
%                     'overrideprice',overridepx,...
%                     'tradeid',tradeid);
%             end
        end
                
    end

end