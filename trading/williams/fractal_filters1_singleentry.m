function [output,status] = fractal_filters1_singleentry(s1type,nfractal,extrainfo,ticksize)
    if nargin < 4
        ticksize = 0;
    end
    
    if s1type == 1
        output = struct('use',0,'comment','weakbreach');
        return
    end
    %
    px = extrainfo.px;
    bs = extrainfo.bs;
    bc = extrainfo.bc;
    lvlup = extrainfo.lvlup;
    lvldn = extrainfo.lvldn;
    idxll = extrainfo.idxll;
    hh = extrainfo.hh;
    ll = extrainfo.ll;
    lips = extrainfo.lips;
    teeth = extrainfo.teeth;
    jaw = extrainfo.jaw;
    wad = extrainfo.wad;
    
    status = fractal_s1_status(nfractal,extrainfo,ticksize);
    
    if bc(end) == 13 && ~status.istrendconfirmed
        output = struct('use',0,'comment','bc13');
        return
    end
    %
    if s1type == 2
        %keep if it breaches-down TDST-lvldn
        if status.islvldnbreach ~= 0
            output = struct('use',1,'comment','breachdn-lvldn');
            return
        end
        %exclude if it is too close to TDST-lvldn
        isclose2lvldn = px(end,5)>=lvldn(end) && (lvlup(end)-px(end,5))/(lvlup(end)-lvldn(end))>0.9&&lvlup(end)>lvldn(end);
        if isclose2lvldn
            output = struct('use',0,'comment','closetolvldn');
            return
        end
        %
        if status.isbshighvalue && ~status.istrendconfirmed
            %maybe even confirmed trend is not a gurantee here
            output = struct('use',0,'comment','mediumbreach-bshighvalue');
            return
        end
        %keep if it breaches the ll of the previous buy sequential
        if status.isbslowbreach
            output = struct('use',1,'comment','breachdn-bshighvalue');
            return
        end
        %keep if it breaches the ll after bc13
        if status.isbclowbreach
            if bs(end) < 9
                output = struct('use',1,'comment','breachdn-lowbc13');
            else
                output = struct('use',0,'comment','breachdn-lowbc13-highbsvalue');
            end
            return
        end
        %
        if status.isvolblowup
            if status.istrendconfirmed
                output = struct('use',1,'comment','volblowup');
            else
                if lips(end) - teeth(end) < 5*ticksize                     %introducing a buffer zone   
                    output = struct('use',1,'comment','volblowup');
                else
                    output = struct('use',0,'comment','volblowup-alligatorfailed');
                end
            end
            return
        else
            if status.isvolblowup2
                if status.istrendconfirmed
                    output = struct('use',1,'comment','volblowup2');
                else
                    if lips(end) - teeth(end) < 5*ticksize                 %introducing a buffer zone
                        output = struct('use',1,'comment','volblowup2');
                    else
                        output = struct('use',0,'comment','volblowup2-alligatorfailed');
                    end
                end
                return
            end
        end
        %
        %INVESTGATE AND RESEARCH FURTHER
        if status.istrendconfirmed
            output = struct('use',1,'comment','mediumbreach-trendconfirmed');
            return
        else
            %special treatment for dn-mediumbreach-trendbreak
            last2llidx = find(idxll==-1,2,'last');
            if isempty(last2llidx)
                lldnward = true;
            else
                if size(last2llidx,1) == 1
                    lldnward = true;
                elseif size(last2llidx,1) == 2
                    last2ll = ll(last2llidx);
                    if last2ll(2) == last2ll(1)
                        last3llidx = find(idxll==-1,3,'last');
                        try
                           if last2ll(1) - ll(last3llidx(1)) <= 5*ticksize
                               lldnward = true;
                           else
                               lldnward = false;
                           end
                        catch
                            lldnward = true;
                        end
                    else
                        if last2ll(2) - last2ll(1) <= 5*ticksize
                            lldnward = true;
                        else
                            lldnward = false;
                        end
                    end
                end
            end
            %
            if lldnward
                %further check whether there are any breach-dn of ll since
                %the last fractal point
%                 nonbreachllflag = isempty(find(px(last2llidx(end)-2*nfractal:end-1,5)-ll(last2llidx(end)-2*nfractal:end-1)+2*ticksize<0,1,'last'));
                nonbreachllflag = isempty(find(px(last2llidx(end)-2*nfractal:end-1,5)-ll(end-1)+2*ticksize<0,1,'last'));
                %further check whether last price is below teeth
                belowteeth = px(end,5)-teeth(end)+2*ticksize<0;
                %further check whether there is any breach up of hh between
                nonbreachhhflag = true;
                for k = last2llidx(end)-2*nfractal:size(px,1)
                    ei_k = fractal_truncate(extrainfo,k);
                    [validbreachhh,~,~,~] = fractal_validbreach(ei_k,ticksize);
                    if validbreachhh
                        nonbreachhhflag = false;
                        break
                    end
                end
%                 nonbreachhhflag = isempty(find(px(last2llidx(end)-2*nfractal:end-1,5)-hh(last2llidx(end)-2*nfractal:end-1)-2*ticksize>0,1,'last'));
                %extra check
                extraflag = px(end,5)-jaw(end)+2*ticksize<0;
                if ~extraflag
                    bslast = bs(end);
                    belowlipsflag = isempty(find(lips(end-bslast+1:end)-px(end-bslast+1:end,5)+2*ticksize<0,1,'last'));
                    extraflag = bslast >= 5 & belowlipsflag;
                end
                if nonbreachllflag && belowteeth && nonbreachhhflag && extraflag
                    output = struct('use',1,'comment','mediumbreach-trendbreak-s');
                else
                    output = struct('use',0,'comment','mediumbreach-trendbreak');
                end
            else
                %if the price were above lvlup and it breached down lvlup
                abovelvlupflag = isempty(find(px(last2llidx(end)-2*nfractal:end-1,5)-lvlup(last2llidx(end)-2*nfractal:end-1)+2*ticksize<0 ,1,'last'));
                breachlvlupflag = px(end,5)-lvlup(end)+2*ticksize<0;
                belowteeth = px(end,5)-teeth(end)+2*ticksize<0;
                if abovelvlupflag && breachlvlupflag && belowteeth
                    output = struct('use',1,'comment','mediumbreach-trendbreak-s');
                else
                    bslast = bs(end);
                    belowlipsflag = isempty(find(lips(end-bslast+1:end)-px(end-bslast+1:end,5)+2*ticksize<0,1,'last'));
                    nonbreachhhflag = isempty(find(px(last2llidx(end)-2*nfractal:end-1,5)-hh(last2llidx(end)-2*nfractal:end-1)-2*ticksize>0,1,'last'));
                    %bslast breached 4 indicates the trend might continue
                    if bslast >= 5 && belowlipsflag && belowteeth && nonbreachhhflag
                        output = struct('use',1,'comment','mediumbreach-trendbreak-s');
                    else
                        output = struct('use',0,'comment','mediumbreach-trendbreak');
                    end
                end
            end
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
        %keep if it breaches-down TDST-lvldn
        if status.islvldnbreach
            if status.isteethjawcrossed && bs(end) >= 9
                %check whether WAD is consitent with the price move
                minpx = min(px(end-bs(end)+1:end-1,5));
                minpxidx = find(px(end-bs(end)+1:end-1,5)==minpx,1,'last')+size(px,1)-bs(end);
                if wad(minpxidx) > wad(end)
                    output = struct('use',1,'comment','breachdn-lvldn');
                else
                    output = struct('use',0,'comment','breachdn-lvldn-teethjawcrossed');
                end
                return
            else
                output = struct('use',1,'comment','breachdn-lvldn');
                return
            end
        end
        %
        %keep if it breach-dn low of a previous buy sequential
        if status.isbslowbreach
            output = struct('use',1,'comment','breachdn-bshighvalue');
            return
        end
        %
        if status.isteethjawcrossed
            if status.isvolblowup
                if lips(end) - teeth(end) < 5*ticksize                     %introducing a buffer zone
                    output = struct('use',1,'comment','volblowup');
                else
                    output = struct('use',0,'comment','volblowup-alligatorfailed');
                end
                return
            end
            %
            if status.isvolblowup2
                if lips(end) - teeth(end) < 5*ticksize                     %introducing a buffer zone
                    output = struct('use',1,'comment','volblowup2');
                else
                    output = struct('use',1,'comment','volblowup2-alligatorfailed');
                end
                return
            end
            %
            if status.istrendconfirmed
                output = struct('use',1,'comment','strongbreach-trendconfirmed');
                return
            else
                output = struct('use',0,'comment','teethjawcrossed');
                return
            end
            %
        else
            %exclude if it is too close to TDST-lvldn
            isclose2lvldn = px(end,5)>lvldn(end) && (lvlup(end)-px(end,5))/(lvlup(end)-lvldn(end))>0.9&&lvlup(end)>lvldn(end);
            if isclose2lvldn
                output = struct('use',0,'comment','closetolvldn');
                return
            end
            %keep if it breaches the ll after bc13
            if status.isbclowbreach
                if bs(end) < 9
                    if px(end,5)>px(end,2)
                        if status.isbslowbreach
                            output = struct('use',1,'comment','breachdn-lowbc13');
                        else
                            output = struct('use',0,'comment','breachdn-lowbc13-positive');
                        end
                    else
                        output = struct('use',1,'comment','breachdn-lowbc13');
                    end
                else
                    output = struct('use',0,'comment','breachdn-lowbc13-highbsvalue');
                end
                return
            end
            %
            if status.isvolblowup
                if status.istrendconfirmed
                    output = struct('use',1,'comment','volblowup');        
                else
                    if lips(end) - teeth(end) < 5*ticksize                 %introducing a buffer zone
                        output = struct('use',1,'comment','volblowup');     
                    else
                        output = struct('use',0,'comment','volblowup-alligatorfailed');
                    end
                end
                return
            else
                if status.isvolblowup2
                    if status.istrendconfirmed
                        output = struct('use',1,'comment','volblowup2');
                    else
                        if lips(end) - teeth(end) < 5*ticksize             %introducing a buffer zone
                            output = struct('use',1,'comment','volblowup2');
                        else
                            output = struct('use',0,'comment','volblowup2-alligatorfailed');
                        end
                    end
                    return
                end
            end
            %
            if status.istrendconfirmed
                output = struct('use',1,'comment','strongbreach-trendconfirmed');
                return
            else
                output = struct('use',0,'comment','strongbreach-trendbreak');
                return
            end            
        end
    end
    
    error('fractal_filters1_singleentry:invalid s1type input')
    
end