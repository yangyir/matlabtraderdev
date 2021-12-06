function [ret,direction,breachtime,breachidx] = fractal_hasintradaybreach(t,extrainfo,ticksize)
%fractal utility function to check whether there was any intraday breach
    px = extrainfo.px;
    tvec = px(:,1);
    hh = hour(t);
    if hh >= 9
        idx1 = find(tvec >= floor(t)+0.375,1,'first');
    else
        lastbd = getlastbusinessdate(t);
        idx1 = find(tvec >= lastbd+0.375,1,'first');
    end
    
    ret = false;
    direction = 0;
    breachtime = [];
    breachidx = [];
    
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
    
    for i = idx2:-1:idx1
        extrainfo_i = struct('px',extrainfo.px(1:i,:),...
            'ss',extrainfo.ss(1:i),'sc',extrainfo.sc(1:i),...
            'bs',extrainfo.bs(1:i),'bc',extrainfo.bc(1:i),...
            'lvlup',extrainfo.lvlup(1:i),'lvldn',extrainfo.lvldn(1:i),...
            'hh',extrainfo.hh(1:i),'ll',extrainfo.ll(1:i),...
            'lips',extrainfo.lips(1:i),'teeth',extrainfo.teeth(1:i),'jaw',extrainfo.jaw(1:i),...
            'wad',extrainfo.wad(1:i));
       [validbreachhh,validbreachll,~,~] = fractal_validbreach(extrainfo_i,ticksize);
       if validbreachhh
           ret = true;
           direction = 1;
           breachtime = tvec(i);
           breachidx = i;
           break
       end
       if validbreachll
           ret = true;
           direction = -1;
           breachtime = tvec(i);
           breachidx = i;
           break
       end
    end
       
    
end