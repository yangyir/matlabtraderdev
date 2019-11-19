function [ret,e,msg] = placeentrust(obj,instrument,varargin)
%cStrat
    if ischar(instrument), instrument = code2instrument(instrument); end
    %note:a new code change that force 'placeentrust' to be used for
    %particular strategy classes
    classname = class(obj);
    if ~(strcmpi(classname,'cStratFutMultiWR') || strcmpi(classname,'cStratManual'))
        ret = 0;
        e = [];
        msg = fprintf('%s:placeentrust:not support...',classname);
        fprintf('%s\n',msg);
        return
    end
    %aslo,we restrict auotrade flag switch off when to call 'placeentrust'
    %function
    autotrade = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','autotrade');
    if autotrade
        ret = 0;
        e = [];
        msg = fprintf('%s:placeentrust:% autotrade flag shall be switched off...',classname,instrument.code_ctp);
        fprintf('%s\n',msg);
        return
    end

    if ~strcmpi(obj.status_,'working')
        ret = 0;
        e = [];
        msg = sprintf('%s:placeentrust:it is not allowed when the strategy is not working....',classname);
        fprintf('%s\n',msg);
        return
    end

    bool = obj.hasinstrument(instrument);
    if ~bool
        ret = 0;
        e = [];
        msg = fprintf('%s:placeentrust:%s not registered in strategy...',classname,instrument.code_ctp);
        fprintf('%s\n',msg);
        return
    end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('BuySell','',@ischar);
    p.addParameter('Offset','open',@ischar);
    p.addParameter('Price',[],@isnumeric);
    p.addParameter('Volume',[],@isnumeric);
    p.addParameter('Limit',-9.99,@isnumeric);
    p.addParameter('LimitType','abs',@ischar);
    p.addParameter('Stop',-9.99,@isnumeric);
    p.addParameter('StopType','abs',@ischar);
    p.addParameter('RiskManagerName','standard',@ischar);
    p.parse(varargin{:});
    
    directionstr = p.Results.BuySell;
    if ~(strcmpi(directionstr,'buy') || strcmpi(directionstr,'b') || ...
            strcmpi(directionstr,'sell') || strcmpi(directionstr,'s'))
        ret = 0;
        e = [];
        msg = sprintf('%s:placeentrust:invalid buy/sell flag input...',classname);
        fprintf('%s\n',msg);
        return
    end
    
    if strcmpi(directionstr,'buy') || strcmpi(directionstr,'b')
        directionnum = 1;
    elseif strcmpi(directionstr,'sell') || strcmpi(directionstr,'s')
        directionnum = -1;
    end
    
    offsetstr = p.Results.Offset;
    if ~(strcmpi(offsetstr,'open') || strcmpi(offsetstr,'close') || strcmpi(offsetstr,'closetoday'))
        ret = 0;
        e = [];
        msg = sprintf('%s:placeentrust:invalid offset input...',classname);
        fprintf('%s\n',msg);
        return
    end
    
    price = p.Results.Price;
    lots = p.Results.Volume;
    target = p.Results.Limit;
    stoploss = p.Results.Stop;
    riskmanagername = p.Results.RiskManagerName;
    
    usepxtarget = abs(target + 9.99) > 1e-6;
    usepxstoploss = abs(stoploss + 9.99) > 1e-6;
    
    if price == -1 && (usepxtarget || usepxstoploss)
        tick = obj.mde_fut_.getlasttick(instrument);
        if directionnum == 1
            price = tick(3);
        elseif directionnum == -1
            price = tick(2);
        end
    end
    
    limittype = p.Results.LimitType;
    if ~(strcmpi(limittype,'abs') || strcmpi(limittype,'rel') || ...
            strcmpi(limittype,'opt') || strcmpi(limittype,'exact'))
        ret = 0;
        e = [];
        msg = sprintf('%s:placeentrust:invalid limittype input...',classname);
        fprintf('%s\n',msg);
        return
    end
    
    stoptype = p.Results.StopType;
    if ~(strcmpi(stoptype,'abs') || strcmpi(stoptype,'rel') || ...
            strcmpi(stoptype,'opt') || strcmpi(stoptype,'exact'))
        ret = 0;
        e = [];
        msg = sprintf('%s:placeentrust:invalid stoptype input...',classname);
        fprintf('%s\n',msg);
        return
    end
    
    if (usepxtarget && strcmpi(limittype,'opt')) ||...
            (usepxstoploss && strcmpi(stoptype,'opt'))
        nperiod = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','numofperiod');
        includelastcandle = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','includelastcandle');
        vol = obj.mde_fut_.calc_hv(instrument,'numofperiods',nperiod,'includelastcandle',includelastcandle,'method','linear');
        optpremium = blkprice(1,1,0,1,vol);
    end
    
    if usepxtarget
        if strcmpi(limittype,'abs')
            pxtarget = price + directionnum*target;
        elseif strcmpi(limittype,'rel')
            pxtarget = price *(1+ directionnum*target);
        elseif strcmpi(limittype,'opt')
            pxtarget = price *(1+ directionnum*optpremium*target);
        elseif strcmpi(limittype,'exact')
            pxtarget = target;
        end
    else
        pxtarget = -9.99;
    end
    
    if usepxstoploss
        if strcmpi(stoptype,'abs')
            pxstoploss = price - directionnum*stoploss;
        elseif strcmpi(stoptype,'rel')
            pxstoploss = price * (1-directionnum*stoploss);
        elseif strcmpi(stoptype,'opt')
            pxstoploss = price * (1-directionnum*optpremium*stoploss);
        elseif strcmpi(stoptype,'exact')
            pxstoploss = stoploss;
        end
    else
        pxstoploss = -9.99;
    end
    
    %sanity check to make sure that price/target/stoploss are correctly 
    if directionnum == 1
        %pxstoploss < price < pxtarget
        if (usepxstoploss && ~(pxstoploss < price)) ||...
                (usepxtarget && ~(price < pxtarget))
            ret = 0;
            e = [];
            msg = sprintf('%s:invalid target/stoploss input for long open trade...',classname);
            fprintf('%s\n',msg);
            return
        end
    elseif directionnum == -1
        %pxstoploss > price > pxtarget
        if (usepxstoploss && ~(pxstoploss > price)) ||...
                (usepxtarget && ~(price > pxtarget))
            ret = 0;
            e = [];
            msg = sprintf('%s:invalid target/stoploss input for short open trade...',classname);
            fprintf('%s\n',msg);
            return
        end
    end
    
    try
        samplefreqstr = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
    catch err
        %note:the code is executed here because
        %1)either riskcontrols are not initiated at all
        %2)or riskcontrols for such instrument is not set
        ret = 0;
        e = [];
        msg = sprintf('%s',['Error:',err.message]);
        fprintf('%s\n',msg);
        return
    end
    
    if strcmpi(classname,'cStratFutMultiWR')
        wrmode = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','wrmode');
        lengthofperiod = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','numofperiod');
        includelastcandle = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','includelastcandle');
    
        maxpx_last = obj.getmaxnperiods(instrument,'IncludeLastCandle',includelastcandle);
        minpx_last = obj.getminnperiods(instrument,'IncludeLastCandle',includelastcandle);
    
        signalinfo = struct('name','williamsr',...
            'instrument',instrument,...
            'frequency',samplefreqstr,...
            'lengthofperiod',lengthofperiod,...
            'highesthigh',maxpx_last,...
            'lowestlow',minpx_last,...
            'wrmode',wrmode,...
            'overrideriskmanagername',riskmanagername,...
            'overridepxtarget',pxtarget,...
            'overridepxstoploss',pxstoploss);
    elseif strcmpi(classname,'cStratManual')
        signalinfo = struct('name','manual',...
            'instrument',instrument,...
            'frequency',samplefreqstr,...
            'riskmanagername',riskmanagername,...
            'pxtarget',pxtarget,...
            'pxstoploss',pxstoploss);
    end
    if strcmpi(obj.mode_,'realtime')
        ordertime = now;
    else
        try
            tick = obj.mde_fut_.getlasttick(instrument);
            ordertime = tick(1);
        catch
            ordertime = obj.replay_time1_;
        end
    end
    
    %first to withdraw pending entrusts with the same instrument and same
    %direction (open position entrust only)
%     obj.withdrawentrusts(instrument,'time',ordertime,'direction',directionnum,'offset',1);
%     
    if directionnum == 1
        if strcmpi(offsetstr,'open')
            [ret,e] = obj.longopen(instrument.code_ctp,abs(lots),...
                'overrideprice',price,'time',ordertime,'signalinfo',signalinfo);
        else
            if strcmpi(offsetstr,'closetoday')
                closetodayFlag = 1;
            else
                closetodayFlag = 0;
            end
            [ret,e] = obj.longclose(instrument.code_ctp,abs(lots),closetodayFlag,...
                'overrideprice',price,'time',ordertime);
        end
    elseif directionnum == -1
        if strcmpi(offsetstr,'open')
            [ret,e] = obj.shortopen(instrument.code_ctp,abs(lots),...
                'overrideprice',price,'time',ordertime,'signalinfo',signalinfo);
        else
            if strcmpi(offsetstr,'closetoday')
                closetodayFlag = 1;
            else
                closetodayFlag = 0;
            end
            [ret,e] = obj.shortclose(instrument.code_ctp,abs(lots),closetodayFlag,...
                'overrideprice',price,'time',ordertime);
        end 
    end
    
    
    
end