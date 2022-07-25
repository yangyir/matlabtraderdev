function [output,status] = fractal_filterb1_singleentry(b1type,nfractal,extrainfo,ticksize)
    if nargin < 4
        ticksize = 0;
    end

    if b1type == 1
        output = struct('use',0,'comment','weakbreach');
        return
    end
    %
    px = extrainfo.px;
    ss = extrainfo.ss;
    sc = extrainfo.sc;
    lvlup = extrainfo.lvlup;
    lvldn = extrainfo.lvldn;
    idxhh = extrainfo.idxhh;
    hh = extrainfo.hh;
    ll = extrainfo.ll;
    lips = extrainfo.lips;
    teeth = extrainfo.teeth;
    jaw = extrainfo.jaw;
    wad = extrainfo.wad;
       
    status = fractal_b1_status(nfractal,extrainfo,ticksize);
    
%     if sc(end) == 13 && ~status.istrendconfirmed && ~status.isvolblowup && ~status.isvolblowup2 
%         output = struct('use',0,'comment','sc13');
%         return
%     end
    
    if b1type == 2
        %keep if it breaches-up TDST-lvlup
        if status.islvlupbreach ~= 0
            output = struct('use',1,'comment','breachup-lvlup');
            return
        end
        %exclude if it is too close to TDST-lvlup
        isclose2lvlup = status.isclose2lvlup;
        if isclose2lvlup
            if status.istrendconfirmed
                output = struct('use',1,'comment','closetolvlup');
            else
                output = struct('use',0,'comment','closetolvlup');
            end
            return
        end
        %
        if status.issshighvalue && ~status.istrendconfirmed
            output = struct('use',0,'comment','mediumbreach-sshighvalue');
            return
        end
        %keep if it breaches the hh of the previous sell sequential
        if status.issshighbreach
            output = struct('use',1,'comment','breachup-sshighvalue');
            return
        end
        %keep if it breaches the hh after sc13
        if status.isschighbreach
            if ss(end) < 9
                output = struct('use',1,'comment','breachup-highsc13');
            else
                output = struct('use',0,'comment','breachup-highsc13-highssvalue');
            end
            return
        end
        %
        if status.isvolblowup
            if status.istrendconfirmed
                output = struct('use',1,'comment','volblowup');
            else
                if lips(end) - teeth(end) > -5*ticksize                    %introducing a buffer zone
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
                    if lips(end) - teeth(end) > -5*ticksize                %introducing a buffer zone
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
            %special treatment for up-mediumbreach-trendbreak
            last2hhidx = find(idxhh==1,2,'last');
            if isempty(last2hhidx)
                hhupward = true;
            else
                if size(last2hhidx,1) == 1
                    hhupward = true;
                elseif size(last2hhidx,1) == 2
                    last2hh = hh(last2hhidx);
                    if last2hh(2) == last2hh(1)
                        last3hhidx = find(idxhh==1,3,'last');
                        try
                            if last2hh(1) - hh(last3hhidx(1)) > -5*ticksize
                                hhupward = true;
                            else
                                hhupward = false;
                            end
                        catch
                            hhupward = true;
                        end
                    else
                        if last2hh(2) - last2hh(1) > -5*ticksize
                            hhupward = true;
                        else
                            hhupward = false;
                        end
                    end
                end
            end
            %
            if hhupward
                %further check whether there are any breach-up of hh since
                %the last fractal points
                nonbreachhhflag = isempty(find(px(last2hhidx(end)-2*nfractal:end-1,5)-hh(last2hhidx(end)-2*nfractal:end-1)-2*ticksize>0,1,'last'));
                %further check whether last price is above teeth
                aboveteeth = px(end,5)-teeth(end)-2*ticksize>0;
                %further check whether there is any breach dn of ll between
                nonbreachllflag = isempty(find(px(last2hhidx(end)-2*nfractal:end-1,5)-ll(last2hhidx(end)-2*nfractal:end-1)+2*ticksize<0,1,'last'));
                %extra check
                extraflag = px(end,5)-jaw(end)-2*ticksize>0;
                if ~extraflag
                    sslast = ss(end);
                    abovelipsflag = isempty(find(lips(end-sslast+1:end)-px(end-sslast+1:end,5)-2*ticksize>0,1,'last'));
                    extraflag = sslast >= 5 & abovelipsflag;
                end
                if nonbreachhhflag && aboveteeth && nonbreachllflag && extraflag 
                    output = struct('use',1,'comment','mediumbreach-trendbreak-s');
                else
                    output = struct('use',0,'comment','mediumbreach-trendbreak');
                end
            else
                %if the price were below lvldn and it breached up lvldn
                belowlvldnflag = isempty(find(px(last2hhidx(end)-2*nfractal:end-1,5)-lvldn(last2hhidx(end)-2*nfractal:end-1)-2*ticksize>0 ,1,'last'));
                breachlvldnflag = px(end,5)-lvldn(end)-2*ticksize>0;
                aboveteeth = px(end,5)-teeth(end)-2*ticksize>0;
                if belowlvldnflag && breachlvldnflag && aboveteeth
                    output = struct('use',1,'comment','mediumbreach-trendbreak-s');
                else
                    sslast = ss(end);
                    abovelipsflag = isempty(find(lips(end-sslast+1:end)-px(end-sslast+1:end,5)-2*ticksize>0,1,'last'));
                    %sslast breached 4 indicates the trend might continue
                    if sslast >= 5 && abovelipsflag && aboveteeth
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
    if b1type == 3
        %exclude when the market is extremely bullish
        if ss(end) >= 15
            if ~status.isschighbreach && ~status.istrendconfirmed
                output = struct('use',0,'comment','strongbreach-sshighvalue');
                return
            end
        end
        %
        %keep if it breach-up TDST-lvlup
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
                return
            else
                output = struct('use',1,'comment','breachup-lvlup');
                return
            end
        end
        %keep if it breach-up high of a previous sell sequential
        if status.issshighbreach
            output = struct('use',1,'comment','breachup-sshighvalue');
            return
        end
        %
%         if status.isteethjawcrossed
%             if status.isvolblowup
%                 if lips(end) - teeth(end) > -5*ticksize                    %introducing a buffer zone
%                     output = struct('use',1,'comment','volblowup');
%                 else
%                     output = struct('use',0,'comment','volblowup-alligatorfailed');
%                 end
%                 return
%             end
%             %
%             if status.isvolblowup2
%                 if lips(end) - teeth(end) > -5*ticksize                    %introducing a buffer zone
%                     output = struct('use',1,'comment','volblowup2');
%                 else
%                     output = struct('use',0,'comment','volblowup2-alligatorfailed');
%                 end
%                 return
%             end
%             %
%             if status.istrendconfirmed
%                 output = struct('use',1,'comment','strongbreach-trendconfirmed');
%                 return
%             else
%                 output = struct('use',0,'comment','teethjawcrossed');
%                 return
%             end
            %
%         else
            %exclude if it is too close to TDST-lvlup
            if status.isclose2lvlup
                if (status.isvolblowup || status.isvolblowup2) && ...
                        lips(end) - teeth(end) > -5*ticksize
                    output = struct('use',1,'comment','closetolvlup');
                else
                    output = struct('use',0,'comment','closetolvlup');
                end
                return
            end
            %keep if it breachs the hh after sc13
            if status.isschighbreach
                if ss(end) < 9
                    if px(end,5)<px(end,2) 
                        if status.issshighbreach
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
            if status.isvolblowup
                if status.istrendconfirmed
                    output = struct('use',1,'comment','volblowup');
                else
                    if lips(end) - teeth(end) > -5*ticksize                %introducing a buffer zone
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
                        if lips(end) - teeth(end) > -5*ticksize            %introducing a buffer zone
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
%                 output = struct('use',0,'comment','strongbreach-trendbreak');
                last2hhidx = find(idxhh==1,2,'last');
                if isempty(last2hhidx)
                    hhupward = true;
                else
                    if size(last2hhidx,1) == 1
                        hhupward = true;
                    elseif size(last2hhidx,1) == 2
                        last2hh = hh(last2hhidx);
                        if last2hh(2) == last2hh(1)
                            last3hhidx = find(idxhh==1,3,'last');
                            try
                                if last2hh(1) - hh(last3hhidx(1)) > -5*ticksize
                                    hhupward = true;
                                else
                                    hhupward = false;
                                end
                            catch
                                hhupward = true;
                            end
                        else
                            if last2hh(2) - last2hh(1) > -5*ticksize
                                hhupward = true;
                            else
                                hhupward = false;
                            end
                        end
                    end
                end
                %
                if hhupward
                    %further check whether there are any breach-up of hh since
                    %the last fractal points
                    nonbreachhhflag = isempty(find(px(last2hhidx(end)-2*nfractal:end-1,5)-hh(last2hhidx(end)-2*nfractal:end-1)-2*ticksize>0,1,'last'));
                    %further check whether last price is above teeth
                    aboveteeth = px(end,5)-teeth(end)-2*ticksize>0;
                    %further check whether there is any breach dn of ll between
                    nonbreachllflag = isempty(find(px(last2hhidx(end)-2*nfractal:end-1,5)-ll(last2hhidx(end)-2*nfractal:end-1)+2*ticksize<0,1,'last'));
                    %extra check
                    extraflag = px(end,5)-jaw(end)-2*ticksize>0;
                    if ~extraflag
                        sslast = ss(end);
                        abovelipsflag = isempty(find(lips(end-sslast+1:end)-px(end-sslast+1:end,5)-2*ticksize>0,1,'last'));
                        extraflag = sslast >= 4 & abovelipsflag;
                    end
                    if nonbreachhhflag && aboveteeth && nonbreachllflag && extraflag 
                        output = struct('use',1,'comment','strongbreach-trendbreak-s');
                    else
                        output = struct('use',0,'comment','strongbreach-trendbreak');
                    end
                else
                    %if the price were below lvldn and it breached up lvldn
                    belowlvldnflag = isempty(find(px(last2hhidx(end)-2*nfractal:end-1,5)-lvldn(last2hhidx(end)-2*nfractal:end-1)-2*ticksize>0 ,1,'last'));
                    breachlvldnflag = px(end,5)-lvldn(end)-2*ticksize>0;
                    aboveteeth = px(end,5)-teeth(end)-2*ticksize>0;
                    if belowlvldnflag && breachlvldnflag && aboveteeth
                        output = struct('use',1,'comment','strongbreach-trendbreak-s');
                    else
                        sslast = ss(end);
                        abovelipsflag = isempty(find(lips(end-sslast+1:end)-px(end-sslast+1:end,5)-2*ticksize>0,1,'last'));
                        %sslast breached 4 indicates the trend might continue
                        if sslast >= 4 && abovelipsflag && aboveteeth
                            output = struct('use',1,'comment','strongbreach-trendbreak-s');
                        else
                            output = struct('use',0,'comment','strongbreach-trendbreak');
                        end
                    end
                end
                return
            end
%         end            
    end
    
    error('fractal_filterb1_singleentry:invalid b1type input')
end