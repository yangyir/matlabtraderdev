function [ret,signal,op] = fractal_hasintradaybreach_conditional(t,extrainfo,ticksize)
%fractal utility function to check whether there was any (CONDITIONAL) 
%intraday breach
    px = extrainfo.px;
    tvec = px(:,1);
    hh = hour(t);
    if hh >= 9
        idx1 = find(tvec >= floor(t)+0.375,1,'first');
    else
        lastbd = getlastbusinessdate(t);
        idx1 = find(tvec >= lastbd+0.375,1,'first');
    end
    
    %shall include the last finished candle for conditional breach check
    idx1 = idx1 - 1;
    
    ret = false;
    signal = {};
    op = {};
    
    if isempty(idx1), return;end
    idx2 = size(tvec,1);
    %here we also need to check whether the last candle has finished or not
    if t - tvec(end) < 1/48
        %intraday 30m bucket
        %if the last candle has not finished yet, we shall choose the
        %previous one
        idx2 = idx2 - 1;
    end
    if idx1 > idx2, return;end
    
    nfractal = 4;
    
    for i = idx2:idx2
        %time moves backwards to find the latest intraday breach
        extrainfo_i = struct('px',extrainfo.px(1:i,:),...
            'ss',extrainfo.ss(1:i),'sc',extrainfo.sc(1:i),...
            'bs',extrainfo.bs(1:i),'bc',extrainfo.bc(1:i),...
            'lvlup',extrainfo.lvlup(1:i),'lvldn',extrainfo.lvldn(1:i),...
            'hh',extrainfo.hh(1:i),'ll',extrainfo.ll(1:i),...
            'idxhh',extrainfo.idxhh(1:i),'idxll',extrainfo.idxll(1:i),...
            'lips',extrainfo.lips(1:i),'teeth',extrainfo.teeth(1:i),'jaw',extrainfo.jaw(1:i),...
            'wad',extrainfo.wad(1:i));
       [signal,op] = fractal_signal_conditional(extrainfo_i,ticksize,nfractal);
       if ~isempty(signal)
           ret = true;
           break
       end
    end
       
    
end