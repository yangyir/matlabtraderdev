function [output,status] = fractal_filters1_singleentry(s1type,nfractal,extrainfo,ticksize)
    if nargin < 4
        ticksize = 0;
    end
    
    if s1type == 1
        output = struct('use',0,'comment','weakbreach');
        status = fractal_s1_status(nfractal,extrainfo,ticksize);
        return
    end
    %
    px = extrainfo.px;
    bs = extrainfo.bs;
    bc = extrainfo.bc;
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
    
    status = fractal_s1_status(nfractal,extrainfo,ticksize);
    
    %keep if it breaches-down TDST-lvldn
    if status.islvldnbreach
        output = struct('use',1,'comment','breachdn-lvldn');
        return
    end
    %keep if it breach-dn low of a previous buy sequential
    if status.isbslowbreach
        if ~status.isbshighvalue && ~status.istrendconfirmed
            %to comemnt:
        elseif status.isclose2lvldn && ~status.istrendconfirmed
            %to comment:
        else
            output = struct('use',1,'comment','breachdn-bshighvalue');
            return
        end
    end
    %
    %keep if it breaches the ll after bc13
    if status.isbclowbreach
        if bs(end) < 9
            if px(end,5)>px(end,2)
                if status.isbslowbreach || status.istrendconfirmed
                    output = struct('use',1,'comment','breachdn-lowbc13');
                else
                    output = struct('use',0,'comment','breachdn-lowbc13-positive');
                end
                return
            else
                if ~status.istrendconfirmed && status.isbslowbreach
                    %to comment:
                elseif ~status.istrendconfirmed
                    %to comment
                else
                    output = struct('use',1,'comment','breachdn-lowbc13');
                    return
                end
            end
        else
            if ~status.istrendconfirmed
                output = struct('use',0,'comment','breachdn-lowbc13-highbsvalue');
            else
                output = struct('use',1,'comment','breachdn-lowbc13');
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
            if status.isfirstbreachsincelastss && ~status.isfirstbreachsincelastsc13
                output = struct('use',1,'comment','volblowup-ssreverse');
            elseif ~status.isfirstbreachsincelastss && status.isfirstbreachsincelastsc13
                output = struct('use',1,'comment','volblowup-screverse');
            elseif status.isfirstbreachsincelastss && status.isfirstbreachsincelastsc13
                output = struct('use',1,'comment','volblowup-ssscdoublereverse');
            else
                output = fractal_filters1_singleentry2(s1type,nfractal,extrainfo,ticksize);
                if ~output.use
                    if lips(end) - teeth(end) < 2*ticksize                 %introducing a buffer zone
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
            if status.isfirstbreachsincelastss && ~status.isfirstbreachsincelastsc13
                output = struct('use',1,'comment','volblowup2-ssreverse');
            elseif ~status.isfirstbreachsincelastss && status.isfirstbreachsincelastsc13
                output = struct('use',1,'comment','volblowup2-screverse');
            elseif status.isfirstbreachsincelastss && status.isfirstbreachsincelastsc13
                output = struct('use',1,'comment','volblowup2-ssscdoublereverse');
            else
                output = fractal_filters1_singleentry2(s1type,nfractal,extrainfo,ticksize);
                if ~output.use
                    if lips(end) - teeth(end) < 2*ticksize                 %introducing a buffer zone
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
    %exclude if it is too close to TDST-lvldn
    if status.isclose2lvldn && ~status.istrendconfirmed
        output = struct('use',0,'comment','closetolvldn');
        return
    end
    %
%     if bc(end) == 13 && ~status.istrendconfirmed
%         output = struct('use',0,'comment','bc13');
%         return
%     end
    %
    if s1type == 2
        if status.isbshighvalue && ~status.istrendconfirmed
            output = struct('use',0,'comment','mediumbreach-bshighvalue');
            return
        end
        %
        if status.istrendconfirmed
            output = struct('use',1,'comment','mediumbreach-trendconfirmed');
            return
        else
            output = fractal_filters1_singleentry2(s1type,nfractal,extrainfo,ticksize);
            return
        end
    end
    %
    if s1type == 3
        %1.exclude when the market is extremely bearish
        if bs(end) >= 15
            if ~status.isbclowbreach  && ~status.istrendconfirmed
                output = struct('use',0,'comment','strongbreach-bshighvalue');
                return
            end
        end
        %
        if status.istrendconfirmed
            output = struct('use',1,'comment','strongbreach-trendconfirmed');
            return
        else
            output = fractal_filters1_singleentry2(s1type,nfractal,extrainfo,ticksize);
            return
        end
    end
    
    error('fractal_filters1_singleentry:invalid s1type input')
    
end