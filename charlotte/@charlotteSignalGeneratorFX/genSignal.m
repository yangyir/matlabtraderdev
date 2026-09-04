function [signal,ei] = genSignal(obj,code,freq,mode)
% a charlotteSignalGeneratorFX function
    idxfound = -1;
    signal = [];
    ei = [];
    for i = 1:size(obj.codes_,1)
        if strcmpi(obj.codes_{i},code) && strcmpi(obj.freqs_{i},freq)
            idxfound = i;
            break
        end
    end
    
    if idxfound == -1;return;end
    
    ei = obj.extrainfo_{idxfound};
    
    nfractal = charlotte_freq2nfractal(freq);
    ei.latestopen = ei.px(end,5);
    ei.latestdt = ei.px(end,1);
    %
    if strcmpi(freq,'m15')
        strat_table = obj.kellytables_m15_;
        tickratio = 0.5;
    elseif strcmpi(freq,'m30')
        strat_table = obj.kellytables_m30_;
        tickratio = 0.5;
    elseif strcmpi(freq,'h1')
        strat_table = obj.kellytables_h1_;
        tickratio = 1;
    elseif strcmpi(freq,'h4')
        strat_table = obj.kellytables_h4_;
        tickratio = 1;
    end
    
    signaluncond = fractal_signal_unconditional2('extrainfo',ei,...
        'ticksize',obj.ticksize_(idxfound),...
        'nfractal',nfractal,...
        'kellytables',strat_table,...
        'assetname',code,...
        'ticksizeratio',tickratio);
    
    if ~isempty(signaluncond)
        signal = signaluncond; 
        signal.type = 0; % unconditional signal
        signal.time = ei.px(end,1);
    else
        signalcond = fractal_signal_conditional2('extrainfo',ei,...
            'ticksize',obj.ticksize_(idxfound),...
            'nfractal',nfractal,...
            'kellytables',strat_table,...
            'assetname',code,...
            'ticksizeratio',tickratio);
        if ~isempty(signalcond)
            signal = signalcond;
            signal.type = 1;
            signal.time = ei.px(end,1);
        else
            %EMPTY RETURNS FROM BOTH UNCONDITIONAL AND CONDITIONAL SIGNAL CALCULATION
        end
    end
    
    if ~isempty(signal)
        signal.code = code;
        signal.frequency = freq;
        if strcmpi(mode,'realtime')
            exportsignal2mt4(signal,ei);
        else
            opendtstr = datestr(ei.px(end,1),'yyyymmdd');
            fn = [getenv('OneDrive'),'\mt4\replay\signals\',code,'.lmx_',upper(freq),'_signals_',opendtstr,'.txt'];
            exportsignal2mt4(signal,ei,fn,obj.printSignal_);
        end
    end
    
%     ei2plot = fractal_truncate(ei,size(ei.px,1),max(size(ei.px,1)-100,1));
%     tools_technicalplot2(ei2plot,4+idxfound,[code,'-',freq],true,2*obj.ticksize_(idxfound));
    
end