function [ret,e,msg] = placecondentrust(obj,instrument,varargin)
%cStrat
    if ~strcmpi(obj.status_,'working')
        ret = 0;
        e = [];
        msg = sprintf('%s:placecondentrust:it is not allowed when the strategy is not working....',class(obj));
        fprintf('%s\n',msg);
        return
    end
    
    if ischar(instrument), instrument = code2instrument(instrument); end
    
    bool = obj.hasinstrument(instrument);
    if ~bool
        ret = 0;
        e = [];
        msg = fprintf('%s:placecondentrust:%s not registered in strategy...',class(obj),instrument.code_ctp);
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
    p.addParameter('Stop',-9.99,@isnumeric);
    p.addParameter('RiskManagerName','standard',@ischar);
    p.parse(varargin{:});
    
    directionstr = p.Results.BuySell;
    if ~(strcmpi(directionstr,'buy') || strcmpi(directionstr,'b') || ...
            strcmpi(directionstr,'sell') || strcmpi(directionstr,'s'))
        ret = 0;
        e = [];
        msg = sprintf('%s:placeentrust:invalid buy/sell flag input...',class(obj));
        fprintf('%s\n',msg);
        return
    end
    
    if strcmpi(directionstr,'buy') || strcmpi(directionstr,'b')
        directionnum = 1;
    elseif strcmpi(directionstr,'sell') || strcmpi(directionstr,'s')
        directionnum = -1;
    end
    
    offsetstr = p.Results.Offset;
    if ~(strcmpi(offsetstr,'open') || strcmpi(offsetstr,'close'))
        ret = 0;
        e = [];
        msg = sprintf('%s:placeentrust:invalid offset input...',class(obj));
        fprintf('%s\n',msg);
        return
    end
    
    price = p.Results.Price;
    lots = p.Results.Volume;
    pxtarget = p.Results.Limit;
    pxstoploss = p.Results.Stop;
    riskmanagername = p.Results.RiskManagerName;
    
    %sanity check to make sure that price/target/stoploss are correctly 
    if directionnum == 1
        %pxstoploss < price < pxtarget
        if ~(pxstoploss < price && price < pxtarget)
            ret = 0;
            e = [];
            msg = sprintf('%s:invalid target/stoploss input for long open trade...',class(obj));
            fprintf('%s\n',msg);
            return
        end
    elseif directionnum == -1
        %pxstoploss > price > pxtarget
        if ~(pxstoploss > price && price > pxtarget)
            ret = 0;
            e = [];
            msg = sprintf('%s:invalid target/stoploss input for short open trade...',class(obj));
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
    
    signalinfo = struct('name','manual',...
        'riskmanagername',riskmanagername,...
        'instrument',instrument,...
        'frequency',samplefreqstr,...
        'pxtarget',pxtarget,...
        'pxstoploss',pxstoploss);
     
    if directionnum == 1
        if strcmpi(offsetstr,'open')
            [ret,e,msg] = obj.condlongopen(instrument.code_ctp,price,abs(lots),...
               'signalinfo',signalinfo);
        else
            error('condlongclose not implemented')
        end
    elseif directionnum == -1
        if strcmpi(offsetstr,'open')
            [ret,e,msg] = obj.condshortopen(instrument.code_ctp,price,abs(lots),...
                'signalinfo',signalinfo);
        else
            error('condshortclose not implemented')
        end 
    end
    
end