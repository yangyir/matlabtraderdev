function [signal,ei] = genSignal(obj,code)
% a charlotteSignalGeneratorFX function
    idxfound = -1;
    signal = [];
    ei = [];
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break
        end
    end
    if idxfound <= 0
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData('charlotteData:genSignal:invalid code input...'));
        return
    end
    p = obj.candles_{idxfound};
    if isempty(p), return; end
    if isempty(obj.freq_{idxfound}), return;end
    
    nfractal = charlotte_freq2nfracal(obj.freq_{idxfound});
    [~,ei] = tools_technicalplot1(p,nfractal,0,'volatilityperiod',0,'tolerance',0);
    ei.latestopen = ei.px(end,5);
    ei.latestdt = ei.px(end,1);
    obj.extrainfo_{idxfound} = ei;
    %
    if strcmpi(obj.freq_{idxfound},'5m')
        tickratio = 0;
        freqappendix = 'M5';
    elseif strcmpi(obj.freq_{idxfound},'15m')
        tickratio = 0.5;
        freqappendix = 'M15';
    elseif strcmpi(obj.freq_{idxfound},'30m') 
        tickratio = 0.5;
        freqappendix = 'M30';
    elseif strcmpi(obj.freq_{idxfound},'60m')  || strcmpi(obj.freq_{idxfound},'1h')
        tickratio = 1;
        freqappendix = 'H1';
    elseif strcmpi(obj.freq_{idxfound},'4h')
        tickratio = 1;
        freqappendix = 'H4';
    else
        tickratio = 1;
        freqappendix = 'D1';
    end
    
    signaluncond = fractal_signal_unconditional2('extrainfo',ei,...
        'ticksize',obj.ticksize_(idxfound),...
        'nfractal',nfractal,...
        'kellytables',obj.kellytables_{idxfound},...
        'assetname',code,...
        'ticksizeratio',tickratio);
    
    if ~isempty(signaluncond)
        if signaluncond.directionkellied == 1
%             fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',code,1,signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
            signal = signaluncond;
        elseif signaluncond.directionkellied == -1
%             fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',code,-1,signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
            signal = signaluncond;
        else
%             fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',code,0,signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
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
        signal.frequency = obj.freq_{idxfound};
        filename = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Signal\',code,'.lmx_',freqappendix,'_signals.txt'];
        exportsignal2mt4(signal,ei,filename);
    end
    
    ei2plot = fractal_truncate(ei,size(ei.px,1),max(size(ei.px,1)-100,1));
    tools_technicalplot2(ei2plot,4+idxfound,[code,'-',obj.freq_{idxfound}],true,2*obj.ticksize_(idxfound));
    
end