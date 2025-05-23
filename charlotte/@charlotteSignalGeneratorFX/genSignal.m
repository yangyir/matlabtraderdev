function [signal,ei] = genSignal(obj,code,freq)
% a charlotteSignalGeneratorFX function
    idxfound = -1;
    signal = [];
    ei = [];
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},[code,'-',freq])
            idxfound = i;
            break
        end
    end
    if idxfound == -1;return;end
    p = obj.candles_{idxfound};
    if isempty(p), return; end
    
    nfractal = charlotte_freq2nfractal(freq);
    [~,ei] = tools_technicalplot1(p,nfractal,0,'volatilityperiod',0,'tolerance',0);
    ei.latestopen = ei.px(end,5);
    ei.latestdt = ei.px(end,1);
    obj.extrainfo_{idxfound} = ei;
    %
    if strcmpi(freq,'5m')
        tickratio = 0;
    elseif strcmpi(freq,'15m')
        tickratio = 0.5;
    elseif strcmpi(freq,'30m') 
        tickratio = 0.5;
    elseif strcmpi(freq,'60m')  || strcmpi(freq,'1h')
        tickratio = 1;
    elseif strcmpi(freq,'4h')
        tickratio = 1;
    else
        tickratio = 1;
    end
    
    signaluncond = fractal_signal_unconditional2('extrainfo',ei,...
        'ticksize',obj.ticksize_(idxfound),...
        'nfractal',nfractal,...
        'kellytables',obj.kellytables_{idxfound},...
        'assetname',code,...
        'ticksizeratio',tickratio);
    
    if ~isempty(signaluncond)
        if signaluncond.directionkellied == 1
            signal = signaluncond;
        elseif signaluncond.directionkellied == -1
            signal = signaluncond;
        else
            signal = signaluncond;
        end 
    else
        signalcond = fractal_signal_conditional2('extrainfo',ei,...
            'ticksize',obj.ticksize_(idxfound),...
            'nfractal',nfractal,...
            'kellytables',obj.kellytables_{idxfound},...
            'assetname',code,...
            'ticksizeratio',tickratio);
        if ~isempty(signalcond)
            if signalcond.directionkellied == 1 && ei.px(end,5) > ei.teeth(end)
                signal = signalcond;
            elseif signalcond.directionkellied == -1 && ei.px(end,5) < ei.teeth(end)
                signal = signalcond;
            else
                signal = signalcond;
            end
        else
            %EMPTY RETURNS FROM BOTH UNCONDITIONAL AND CONDITIONAL SIGNAL CALCULATION
        end
    end
    
    if ~isempty(signal)
        signal.code = code;
        signal.frequency = freq;
        exportsignal2mt4(signal,ei);
    end
    
    ei2plot = fractal_truncate(ei,size(ei.px,1),max(size(ei.px,1)-100,1));
    tools_technicalplot2(ei2plot,4+idxfound,[code,'-',freq],true,2*obj.ticksize_(idxfound));
    
end