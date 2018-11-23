function [ret,e] = placeentrust(obj,instrument,varargin)
%cStrat
    if ~strcmpi(obj.status_,'working')
        ret = 0;
        e = [];
        fprintf('%s:placeentrust is not allowed when the strategy is not working',class(obj))
        return
    end
    
    if ischar(instrument), instrument = code2instrument(instrument); end
    
    bool = obj.hasinstrument(instrument);
    if ~bool
        ret = 0;
        e = [];
        fprintf('cStratFutMultiBatman:% not registered in strategy...\n',instrument.code_ctp);
        return
    end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('BuySell','',@ischar);
    p.addParameter('Price',[],@isnumeric);
    p.addParameter('Volume',[],@isnumeric);
    p.addParameter('Target',[],@isnumeric);
    p.addParameter('Stoploss',[],@isnumeric);
    p.parse(varargin{:});
    directionstr = p.Results.BuySell;
    if ~(strcmpi(directionstr,'buy') || strcmpi(directionstr,'b') || ...
            strcmpi(directionstr,'sell') || strcmpi(directionstr,'s'))
        ret = 0;
        e = [];
        fprintf('cStratFutMultiBatman:invalid buy/sell flag input...\n');
        return
    end
    
    if strcmpi(directionstr,'buy') || strcmpi(directionstr,'b')
        directionnum = 1;
    elseif strcmpi(directionstr,'sell') || strcmpi(directionstr,'s')
        directionnum = -1;
    end 
    
    price = p.Results.Price;
    lots = p.Results.Volume;
    pxtarget = p.Results.Target;
    pxstoploss = p.Results.Stoploss;
    
    %sanity check to make sure that price/target/stoploss are correctly 
    if directionnum == 1
        %pxstoploss < price < pxtarget
        if ~(pxstoploss < price && price < pxtarget)
            ret = 0;
            e = [];
            fprintf('cStratFutMultiBatman:invalid target/stoploss input for long open trade...\n');
        end
    elseif directionnum == -1
        %pxstoploss > price > pxtarget
        if ~(pxstoploss > price && price > pxtarget)
            ret = 0;
            e = [];
            fprintf('cStratFutMultiBatman:invalid target/stoploss input for short open trade...\n');
        end
    end
    
    try
        samplefreqstr = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
    catch err
        %note:the code is executed here because
        %1)either riskcontrols are not initiated at all
        %2)or riskcontrols for such instrument is not set
        fprintf('%s\n',['Error:',err.message]);
        ret = 0;
        e = [];
        return
    end
    
    
    signalinfo = struct('name','batmanmanual',...
        'instrument',instrument,...
        'frequency',samplefreqstr,...
        'pxtarget',pxtarget,...
        'pxstoploss',pxstoploss);
    
    if strcmpi(obj.mode_,'realtime')
        ordertime = now;
    else
        try
            tick = obj.mde_fut_.getlasttick(instrument);
            ordertime = tick(1);
        catch
            ordertime = obj.replay_time1_;
        end
        if hour(ordertime) > 20
            pause(1);
        end
    end
    
    %first to withdraw pending entrusts with the same instrument and same
    %direction (open position entrust only)
    obj.withdrawentrusts(instrument,'time',ordertime,'direction',directionnum,'offset',1);
    
    if directionnum == 1
        [ret,e] = obj.longopen(instrument.code_ctp,abs(lots),...
            'overrideprice',price,'time',ordertime,'signalinfo',signalinfo);
    elseif directionnum == -1
        [ret,e] = obj.shortopen(instrument.code_ctp,abs(lots),...
            'overrideprice',price,'time',ordertime,'signalinfo',signalinfo);
    end

end
