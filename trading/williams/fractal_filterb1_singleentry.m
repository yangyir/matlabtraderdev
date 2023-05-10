function [output,status] = fractal_filterb1_singleentry(b1type,nfractal,extrainfo,ticksize)
    if nargin < 4
        ticksize = 0;
    end

    if b1type == 1
        output = struct('use',0,'comment','weakbreach');
        status = fractal_b1_status(nfractal,extrainfo,ticksize);
        return
    end
    %
    px = extrainfo.px;
    ss = extrainfo.ss;
    sc = extrainfo.sc;
    lvlup = extrainfo.lvlup;
    lvldn = extrainfo.lvldn;
    idxhh = extrainfo.idxhh;
    idxll = extrainfo.idxll;
    hh = extrainfo.hh;
    ll = extrainfo.ll;
    lips = extrainfo.lips;
    teeth = extrainfo.teeth;
    jaw = extrainfo.jaw;
    wad = extrainfo.wad;
       
    status = fractal_b1_status(nfractal,extrainfo,ticksize);
    
    %keep if it breaches-up TDST-lvlup
    if status.islvlupbreach
        if status.isteethjawcrossed && ss(end) >= 9
            %check whether WAD is consistent with the price move
            maxpx = max(px(end-ss(end)+1:end-1,5));
            maxpxidx = find(px(end-ss(end)+1:end-1,5)==maxpx,1,'last')+size(px,1)-ss(end);
            if wad(maxpxidx) < wad(end)
                output = struct('use',1,'comment','breachup-lvlup');
            else
                output = struct('use',0,'comment','breachup-lvlup-teethjawcrossed');
            end
        else
            output = struct('use',1,'comment','breachup-lvlup');
        end
        return
    end
    %
    %keep if it breaches the hh of the previous sell sequential
    if status.issshighbreach
        output = struct('use',1,'comment','breachup-sshighvalue');
        return
    end
    %
    %keep if it breaches the hh after sc13
    if status.isschighbreach
        if ss(end) < 9
            if px(end,5)<px(end,2)
                if status.issshighbreach || status.istrendconfirmed
                    output = struct('use',1,'comment','breachup-highsc13');
                else
                    output = struct('use',0,'comment','breachup-highsc13-negative');
                end
            else
                output = struct('use',1,'comment','breachup-highsc13');
            end
        else
            output = struct('use',0,'comment','breachup-highsc13-highssvalue');
        end
        return
    end
    %
    %keep if its vol blows up
    if status.isvolblowup
        if status.istrendconfirmed
            output = struct('use',1,'comment','volblowup');
        else
            if lips(end) - teeth(end) > -5*ticksize                    %introducing a buffer zone
                output = struct('use',1,'comment','volblowup');
            else
                if status.isfirstbreachsincelastbs && ~status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','volblowup-bsreverse');
                elseif ~status.isfirstbreachsincelastbs && status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','volblowup-bcreverse');
                elseif status.isfirstbreachsincelastbs && status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','volblowup-bsbcdoublereverse');
                else             
                    output = fractal_filterb1_singleentry2(b1type,nfractal,extrainfo,ticksize);
                    if ~output.use
                        output = struct('use',0,'comment','volblowup-alligatorfailed');
                    else
                        output = struct('use',1,'comment','volblowup-s');
                    end
                end
            end
        end
        return
    end
    %
    %keep if its vol2 blows up, i.e. close to close
    if status.isvolblowup2
        if status.istrendconfirmed
            output = struct('use',1,'comment','volblowup2');
        else
            if lips(end) - teeth(end) > -5*ticksize                    %introducing a buffer zone
                output = struct('use',1,'comment','volblowup2');
            else
                if status.isfirstbreachsincelastbs && ~status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','volblowup2-bsreverse');
                elseif ~status.isfirstbreachsincelastbs && status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','volblowup2-bcreverse');
                elseif status.isfirstbreachsincelastbs && status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','volblowup2-bsbcdoublereverse');
                else
                    output = fractal_filterb1_singleentry2(b1type,nfractal,extrainfo,ticksize);
                    if ~output.use
                        output = struct('use',0,'comment','volblowup2-alligatorfailed');
                    else
                        output = struct('use',1,'comment','volblowup2-s');
                    end
                end
            end
        end
        return
    end
    %exclude if it is too close to TDST-lvlup
    if status.isclose2lvlup && ~status.istrendconfirmed
        output = struct('use',0,'comment','closetolvlup');
        return
    end
    
    %
    if b1type == 2    
        if status.issshighvalue && ~status.istrendconfirmed
            output = struct('use',0,'comment','mediumbreach-sshighvalue');
            return
        end
        %
        if status.istrendconfirmed
            output = struct('use',1,'comment','mediumbreach-trendconfirmed');
            return
        else
            output = fractal_filterb1_singleentry2(b1type,nfractal,extrainfo,ticksize);
            return
        end
    end
    %    
    if b1type == 3
        %exclude when the market is extremely bullish
        if ss(end) >= 15
            if ~status.isschighbreach && ~status.istrendconfirmed
                output = struct('use',0,'comment','strongbreach-sshighvalue');
                return
            end
        end
        %
        if status.istrendconfirmed
            output = struct('use',1,'comment','strongbreach-trendconfirmed');
            return
        else
            output = fractal_filterb1_singleentry2(b1type,nfractal,extrainfo,ticksize);
            return
        end           
    end
    
    error('fractal_filterb1_singleentry:invalid b1type input')
end