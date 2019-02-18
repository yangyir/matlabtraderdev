function [ret,e,msg] = placeentrust(obj,instrument,varargin)
%cStrat
    if ischar(instrument), instrument = code2instrument(instrument); end
    %note:a new code change that force 'placeentrust' to be used for
    %particular strategy classes
    classname = class(obj);
    if ~(strcmpi(classname,'cStratFutMultiWR'))
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
    pxtarget = p.Results.Limit;
    pxstoploss = p.Results.Stop;
    riskmanagername = p.Results.RiskManagerName;
    
    usepxtarget = abs(pxtarget + 9.99) > 1e-6;
    usepxstoploss = abs(pxstoploss + 9.99) > 1e-6;
    
    limittype = p.Results.LimitType;
    stoptype = p.Results.StopType;
    if usepxtarget
        
    end
    
    if usepxstoploss
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