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
        output = struct('use',1,'comment','breachup-lvlup');    
        return
    end
    %
    %keep if it breaches the hh of the previous sell sequential
    if status.issshighbreach
        if ~status.issshighvalue && ~status.istrendconfirmed
            %to comment:
        elseif status.isclose2lvlup && ~status.istrendconfirmed
            %to comment:
        else
            output = struct('use',1,'comment','breachup-sshighvalue');
            return
        end
        
    end
    %
    %keep if it breaches the hh after sc13
    if status.isschighbreach
        if ss(end) < 9
            if px(end,5)<px(end,2)
                if status.istrendconfirmed
                    output = struct('use',1,'comment','breachup-highsc13');
                else
                    output = struct('use',0,'comment','breachup-highsc13-negative');
                end
                return
            else
                if ~status.istrendconfirmed && status.issshighbreach
                    %to comment:
                elseif ~status.istrendconfirmed
                    %to comment:
                else
                    output = struct('use',1,'comment','breachup-highsc13');
                    return
                end
            end
        else
            if ~status.istrendconfirmed
                output = struct('use',0,'comment','breachup-highsc13-highssvalue');
            else
                output = struct('use',1,'comment','breachup-highsc13');
            end
            return
        end
    end
    %
    %keep if its vol blows up
    if status.isvolblowup
        if status.istrendconfirmed
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
                    if lips(end) - teeth(end) < -2*ticksize                    %introducing a buffer zone
                        output = struct('use',0,'comment','volblowup-alligatorfailed');
                    else
                        output = struct('use',0,'comment','volblowup-trendbreak');
                    end
                else
                    if ~isempty(strfind(output.comment,'s1'))
                        output = struct('use',1,'comment','volblowup-s1');
                    elseif ~isempty(strfind(output.comment,'s2'))
                        output = struct('use',1,'comment','volblowup-s2');
                    elseif ~isempty(strfind(output.comment,'s3'))
                        output = struct('use',1,'comment','volblowup-s3');
                    else
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
            if status.isfirstbreachsincelastbs && ~status.isfirstbreachsincelastbc13
                output = struct('use',1,'comment','volblowup2-bsreverse');
            elseif ~status.isfirstbreachsincelastbs && status.isfirstbreachsincelastbc13
                output = struct('use',1,'comment','volblowup2-bcreverse');
            elseif status.isfirstbreachsincelastbs && status.isfirstbreachsincelastbc13
                output = struct('use',1,'comment','volblowup2-bsbcdoublereverse');
            else
                output = fractal_filterb1_singleentry2(b1type,nfractal,extrainfo,ticksize);
                if ~output.use
                    if lips(end) - teeth(end) < -2*ticksize                    %introducing a buffer zone
                        output = struct('use',0,'comment','volblowup2-alligatorfailed');
                    else
                        output = struct('use',0,'comment','volblowup2-trendbreak');
                    end
                else
                    if ~isempty(strfind(output.comment,'s1'))
                        output = struct('use',1,'comment','volblowup2-s1');
                    elseif ~isempty(strfind(output.comment,'s2'))
                        output = struct('use',1,'comment','volblowup2-s2');
                    elseif ~isempty(strfind(output.comment,'s3'))
                        output = struct('use',1,'comment','volblowup2-s3');
                    else
                    end
                end
            end
        end
        return
    end
    %
    %exclude if it is too close to TDST-lvlup
    if status.isclose2lvlup && ~status.istrendconfirmed
        output = struct('use',0,'comment','closetolvlup');
        return
    end
    %
%     if sc(end) == 13 && ~status.istrendconfirmed
%         output = struct('use',0,'comment','sc13');
%         return
%     end
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
            if strcmpi(output.comment,'mediumbreach-trendbreak')
                if status.isfirstbreachsincelastbs && ~status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','mediumbreach-trendbreak-bsreverse');
                elseif ~status.isfirstbreachsincelastbs && status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','mediumbreach-trendbreak-bcreverse');
                elseif status.isfirstbreachsincelastbs && status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','mediumbreach-trendbreak-bsbcdoublereverse');
                else
                end
                return
            end
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
            if strcmpi(output.comment,'strongbreach-trendbreak')
                if status.isfirstbreachsincelastbs && ~status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','strongbreach-trendbreak-bsreverse');
                elseif ~status.isfirstbreachsincelastbs && status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','strongbreach-trendbreak-bcreverse');
                elseif status.isfirstbreachsincelastbs && status.isfirstbreachsincelastbc13
                    output = struct('use',1,'comment','strongbreach-trendbreak-bsbcdoublereverse');
                else
                end
                return
            end
            return
        end           
    end
    
    error('fractal_filterb1_singleentry:invalid b1type input')
    
end