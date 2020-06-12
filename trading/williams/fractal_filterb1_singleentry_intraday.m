function [output] = fractal_filterb1_singleentry_intraday(b1type,nfractal,extrainfo)
    if b1type == 1
        output = struct('use',0,'comment','weakbreach');
        return
    end
    %
    px = extrainfo.px;
    bs = extrainfo.bs;
    ss = extrainfo.ss;
    sc = extrainfo.sc;
    lvlup = extrainfo.lvlup;
    lvldn = extrainfo.lvldn;
%     idxHH = extrainfo.idxhh;
%     HH = extrainfo.hh;
%     LL = extrainfo.ll;
%     lips = extrainfo.lips;
%     teeth = extrainfo.teeth;
%     jaw = extrainfo.jaw;
%     wad = extrainfo.wad;
    
    this_momentum = tdsq_momentum(px,bs,ss,lvlup,lvldn);
    
    if this_momentum == -1
        %it is not wise to long when the market momentum is bearish
        output = struct('use',0','comment','bearishmomentum','momentum',this_momentum);
        return
    end
    
    if sc(end) == 13
        output = struct('use',0','comment','sc13','momentum',this_momentum);
        return
    end
    
    isbreachlvlup = (~isempty(find(px(end-ss(end):end,5)>lvlup(end),1,'first')) && ...
        ~isempty(find(px(end-ss(end):end,5)<lvlup(end),1,'first')) && ...
        px(end,5)>lvlup(end) && ...
        ss(end) < 9) ...
            || (px(end,5)>lvlup(end) && px(end-1,5)<lvlup(end))...
            || (px(end,5)>lvlup(end) && px(end,4)<lvlup(end));
    if isbreachlvlup
        output = struct('use',1,'comment','breachup-lvlup','momentum',this_momentum);
        return
    end
    
    
    output = struct('use',0,'comment','n/a','momentum',this_momentum);
    
    
end