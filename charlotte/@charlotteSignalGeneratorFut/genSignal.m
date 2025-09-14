function [signal] = genSignal(obj,code,freq)
% a charlotteSignalGeneratorFut function
    idxfound = -1;
    signal = [];
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break
        end
    end
    if idxfound == -1;return;end
    if strcmpi(freq,'1m') || strcmpi(freq,'m1')
        p = obj.candles_m1_{idxfound};
        ei = obj.ei_m1_{idxfound};
    elseif strcmpi(freq,'5m') || strcmpi(freq,'m5')
        p = obj.candles_m5_{idxfound};
        ei = obj.ei_m5_{idxfound};
    elseif strcmpi(freq,'15m') || strcmpi(freq,'m15')
        p = obj.candles_m15_{idxfound};
        ei = obj.ei_m15_{idxfound};
    elseif strcmpi(freq,'30m') || strcmpi(freq,'m30')
        p = obj.candles_m30_{idxfound};
        ei = obj.ei_m30_{idxfound};
    elseif strcmpi(freq,'daily') || strcmpi(freq,'d1')
        p = obj.candles_d1_{idxfound};
        ei = obj.ei_d1_{idxfound};
    end
    
    if isempty(p), return; end
    if isempty(ei), return;end
    
    % here we shall use latest tick information?
    ei.latestopen = obj.feed_.getLastTick(code);
    ei.latestdt = datenum(obj.feed_.getLastTickTime(code));
    
    %
    if strcmpi(freq,'1m') || strcmpi(freq,'m1')
        tickratio = 0;
        kellytable = obj.kellytable_m1_;
    elseif strcmpi(freq,'5m') || strcmpi(freq,'m5')
        tickratio = 0;
        kellytable = obj.kellytable_m5_;
    elseif strcmpi(freq,'15m') || strcmpi(freq,'m15')
        tickratio = 0.5;
        kellytable = obj.kellytable_m15_;
    elseif strcmpi(freq,'30m') 
        tickratio = 0.5;
        kellytable = obj.kellytable_m30_;
    else
        tickratio = 1;
        kellytable = obj.kellytable_d1_;
    end
    
    nfractal = charlotte_freq2nfractal(freq);
    
    fut = code2instrument(code);
    
    signaluncond = fractal_signal_unconditional2('extrainfo',ei,...
        'ticksize',obj.ticksize_(idxfound),...
        'nfractal',nfractal,...
        'kellytables',kellytable,...
        'assetname',fut.asset_name,...
        'ticksizeratio',tickratio);
    
    if ~isempty(signaluncond)
        if signaluncond.directionkellied == 1
            signal = signaluncond;
        elseif signaluncond.directionkellied == -1
            signal = signaluncond;
        else
            signal = signaluncond;
        end
        signal.isconditional = false;
    else
        signalcond = fractal_signal_conditional2('extrainfo',ei,...
            'ticksize',obj.ticksize_(idxfound),...
            'nfractal',nfractal,...
            'kellytables',kellytable,...
            'assetname',fut.asset_name,...
            'ticksizeratio',tickratio);
        if ~isempty(signalcond)
            if signalcond.directionkellied == 1 && ei.px(end,5) > ei.teeth(end)
                signal = signalcond;
            elseif signalcond.directionkellied == -1 && ei.px(end,5) < ei.teeth(end)
                signal = signalcond;
            else
                signal = signalcond;
            end
            signal.isconditional = true;
        else
            %EMPTY RETURNS FROM BOTH UNCONDITIONAL AND CONDITIONAL SIGNAL CALCULATION
        end
    end
    
end