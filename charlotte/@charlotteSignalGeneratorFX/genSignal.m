function [signal] = genSignal(obj,code)
% a charlotteSignalGeneratorFX function
    idxfound = -1;
    signal = [];
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
    %
%     if strcmpi(code,'USDJPY')
%         tools_technicalplot2(ei,4+idxfound,[code,'-',obj.freq_{idxfound}],true,2*obj.ticksize_(idxfound));
%     end
    %
    if idxfound == 1
        fprintf('%10s%10s%14s%10s%10s%8s%8s%10s%10s%10s%10s%10s\n',...
                        'Code','Last','Datetime(ldn)','HH','LL','BS','SS','LevelUp','LevelDn','Jaw','Teeth','Lips');
    end    
    
    if strcmpi(code,'USDJPY')
        dataformat = '%10s%10s%14s%10s%10s%8s%8s%10s%10s%10.3f%10.3f%10.3f\n';
    elseif strcmpi(code,'XAUUSD')
        dataformat = '%10s%10s%14s%10s%10s%8s%8s%10s%10s%10.2f%10.2f%10.2f\n';
    else
        dataformat = '%10s%10s%14s%10s%10s%8s%8s%10s%10s%10.4f%10.4f%10.4f\n';
    end
    fprintf(dataformat,code,...
        num2str(ei.px(end,5)),...
        datestr(ei.px(end,1),'dd-mmm HH:MM'),...
        num2str(ei.hh(end)),num2str(ei.ll(end)),...
        num2str(ei.bs(end)),num2str(ei.ss(end)),num2str(ei.lvlup(end)),num2str(ei.lvldn(end)),...
        ei.jaw(end),ei.teeth(end),ei.lips(end));
    if idxfound == size(obj.codes_,1)
        fprintf('\n');
    end
    %
    %
%     if ~strcmpi(code,'USDJPY'), return;end
    
    if strcmpi(obj.freq_{idxfound},'5m')
        tickratio = 0;
    elseif strcmpi(obj.freq_{idxfound},'15m') || strcmpi(obj.freq_{idxfound},'30m') 
        tickratio = 0.5;
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
            fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',code,1,signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
            signal = signaluncond;
        elseif signaluncond.directionkellied == -1
            fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',code,-1,signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
            signal = signaluncond;
        else
            fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',code,0,signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
            signal = [];
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
                fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',code,1,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                signal = signalcond;
            elseif signalcond.directionkellied == -1 && ei.px(end,5) < ei.teeth(end)
                fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',code,-1,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                signal = signalcond;
            else
                fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',code,0,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                signal = [];
            end
        else
            %EMPTY RETURNS FROM BOTH UNCONDITIONAL AND CONDITIONAL SIGNAL CALCULATION
        end
    end
    
%     if ~isempty(signal)
        tools_technicalplot2(ei,4+idxfound,[code,'-',obj.freq_{idxfound}],true,2*obj.ticksize_(idxfound));
%     end
    
end