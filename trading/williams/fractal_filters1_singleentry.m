function [output] = fractal_filters1_singleentry(s1type,nfractal,extrainfo)
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
    idxLL = extrainfo.idxll;
    LL = extrainfo.ll;
    lips = extrainfo.lips;
    teeth = extrainfo.teeth;
    jaw = extrainfo.jaw;
    wad = extrainfo.wad;
    
    if bc(end) == 13 && lips(end)<teeth(end)&&teeth(end)<jaw(end)
        output = struct('use',0,'comment','bc13');
        return
    end
    %%
    if s1type == 2
        %keep if it breaches-down TDST-lvldn
        isbreachlvldn = (~isempty(find(px(end-bs(end):end,5)<lvldn(end),1,'first')) &&~isempty(find(px(end-bs(end):end,5)>lvldn(end),1,'first')) && px(end,5)<lvldn(end)) || ...
            (px(end,5)<lvldn(end) && px(end-1,5)>lvldn(end)) ||...
            (px(end,5)<lvldn(end) && px(end,3)>lvldn(end));
        if isbreachlvldn
            output = struct('use',1,'comment','breachdn-lvldn');
            return
        end
        %keep if it breaches-down TDST-lvlup
        isbreachlvlup = (~isempty(find(px(end-bs(end):end,5)<lvlup(end),1,'first')) &&~isempty(find(px(end-bs(end):end,5)>lvlup(end),1,'first')) && px(end,5)<lvldn(end)) || ...
            (px(end,5)<lvlup(end) && px(end-1,5)>lvlup(end)) ||...
            (px(end,5)<lvlup(end) && px(end,3)>lvlup(end));
        if isbreachlvlup
            output = struct('use',1,'comment','breachdn-lvlup');
            return
        end
        %exclude if it is too close to TDST-lvldn
        isclose2lvldn = px(end,5)>lvldn(end) && (lvlup(end)-px(end,5))/(lvlup(end)-lvldn(end))>0.9&&lvlup(end)>lvldn(end);
        if isclose2lvldn
            output = struct('use',0,'comment','closetolvldn');
            return
        end
        %exclude perfect TDST-buysetup
        if bs(end) >= 9 && px(end,5) <= min(px(end-bs(end)+1:end,5)) && px(end,4) <= min(px(end-bs(end)+1:end,4))
            output = struct('use',0,'comment','mediumbreach-bshighvalue');
            return
        end
        %keep if it breaches the ll after bc13
        lastbc13 = find(bc(1:end-1)==13,1,'last');
        if ~isempty(lastbc13) && size(px,1)-lastbc13<=9 &&px(end,5)<min(px(lastbc13:end-1,4))
            output = struct('use',1,'comment','breachdn-lowbc13');
            return
        end
        %
        [~,~,nkbelowlips,nkbelowteeth,nkfromll] = fractal_counts(px,idxLL,nfractal,lips,teeth,jaw);
        barsizelast = px(end,3)-px(end,4);
        barsizerest = px(end-nkfromll+1:end-1,3)-px(end-nkfromll+1:end-1,4);
        isvolblowup = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
        if isvolblowup
            output = struct('use',1,'comment','volblowup');
            return
        else
            barsizelast = abs(px(end,5)-px(end-1,5));
            isvolblowup2 = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
            if isvolblowup2
                if bs(end) <= 1
                    output = struct('use',0,'comment','volblowup2-bs1');
                else
                    output = struct('use',1,'comment','volblowup2');
                end
                return
            end
        end
        %
        %INVESTGATE AND RESEARCH FURTHER
        if nkbelowteeth >= 2*nfractal+1
            if lips(end) < teeth(end)
                output = struct('use',1,'comment','mediumbreach-trendconfirmed');
                return
            else
                output = struct('use',0,'comment','mediumbreach-trendbreak');
                return
            end
        else
            if (nkbelowlips == nkfromll || nkbelowteeth == nkfromll) && nkfromll == nfractal+2
                last2llidx = find(idxLL(1:end)== -1,2,'last');
                if size(last2llidx,1) < 2
                    output = struct('use',0,'comment','mediumbreach-trendbreak');
                    return
                end
                last2ll = LL(last2llidx);
                %check whether a new lower LL is formed or not
                if last2ll(2)<last2ll(1) && bs(end) < 9
                    output = struct('use',1,'comment','mediumbreach-trendconfirmed');
                elseif last2ll(2)>last2ll(1)&&px(end,5)<last2ll(1)&&bs(end)<9
                    output = struct('use',1,'comment','mediumbreach-trendconfirmed');
                else
                    output = struct('use',0,'comment','mediumbreach-trendbreak');
                end
                return
            else
                if nkfromll == nfractal + 2
                    last2llidx = find(idxLL(1:end)== -1,2,'last');
                    if size(last2llidx,1) < 2
                        output = struct('use',0,'comment','mediumbreach-trendbreak');
                        return
                    end
                    last2ll = LL(last2llidx);
                    %check whether a new lower LL is formed or not
                    if last2ll(2)<last2ll(1) && bs(end) < 9
                        output = struct('use',1,'comment','mediumbreach-trendconfirmed');
                    elseif last2ll(2)>last2ll(1)&&px(end,5)<last2ll(1)&&bs(end)<9
                        output = struct('use',1,'comment','mediumbreach-trendconfirmed');
                    else
                        output = struct('use',0,'comment','mediumbreach-trendbreak');
                    end
                    return
                else
                    if nkbelowlips >= 2*nfractal+1 && nkbelowteeth >= 2*nfractal+1
                        output = struct('use',1,'comment','mediumbreach-trendconfirmed');
                        return
                    elseif nkbelowlips >= 2*nfractal+1 && nkfromll-nkbelowlips<nfractal && nkbelowteeth >= nfractal+1
                        output = struct('use',1,'comment','mediumbreach-trendconfirmed');
                        return
                    else
                        output = struct('use',0,'comment','mediumbreach-trendbreak');
                        return
                    end
                end
            end
        end         
    end
    %%
    if s1type == 3
        %1.exclude when the market is extremely bearish
        if bs(end) >= 15
            output = struct('use',0,'comment','strongbreach-bshighvalue');
            return
        end
        %
        [~,~,~,nkbelowteeth2,nkfromll,teethjawcrossed] = fractal_counts(px,idxLL,nfractal,lips,teeth,jaw);
        %
        %keep if it breaches-down TDST-lvldn
        isbreachlvldn = (~isempty(find(px(end-bs(end):end,5)<lvldn(end),1,'first')) &&~isempty(find(px(end-bs(end):end,5)>lvldn(end),1,'first')) && px(end,5)<lvldn(end)) || ...
            (px(end,5)<lvldn(end) && px(end-1,5)>lvldn(end)) || ...
            (px(end,5)<lvldn(end) && px(end,3)>lvldn(end));
        if isbreachlvldn
            if teethjawcrossed && bs(end) >= 9
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
        %keep if it breaches-down TDST-lvlup
        isbreachlvlup = (~isempty(find(px(end-bs(end):end,5)<lvlup(end),1,'first')) &&~isempty(find(px(end-bs(end):end,5)>lvlup(end),1,'first')) && px(end,5)<lvldn(end)) || ...
            (px(end,5)<lvlup(end) && px(end-1,5)>lvlup(end)) ||...
            (px(end,5)<lvlup(end) && px(end,3)>lvlup(end));
        if isbreachlvlup
            if teethjawcrossed && bs(end) >= 9
                %check whether WAD is consitent with the price move
                minpx = min(px(end-bs(end)+1:end-1,5));
                minpxidx = find(px(end-bs(end)+1:end-1,5)==minpx,1,'last')+size(px,1)-bs(end);
                if wad(minpxidx) > wad(end)
                    output = struct('use',1,'comment','breachdn-lvlup');
                else
                    output = struct('use',0,'comment','breachdn-lvlup-teethjawcrossed');
                end
                return
            else
                output = struct('use',1,'comment','breachdn-lvlup');
                return
            end
        end
        %
        %keep if it breach-dn low of a previous buy sequential
        if bs(end-nkfromll+1) >= 9
            lastbs = bs(end-nkfromll+1);
%             if (px(end-nkfromll+1,5) <= min(px(end-nkfromll-lastbs+2:end-nkfromll+1,5)) && ...
%                     px(end-nkfromll+1,4) <= min(px(end-nkfromll-lastbs+2:end-nkfromll+1,4)))
            if px(end-nkfromll+1,4) <= min(px(end-nkfromll-lastbs+2:end-nkfromll+1,4))    
                output = struct('use',1,'comment','breachdn-bshighvalue');
                return
            end
        end
        %
        if teethjawcrossed
            barsizelast = px(end,3)-px(end,4);
            barsizerest = px(end-nkfromll+1:end-1,3)-px(end-nkfromll+1:end-1,4);
            isvolblowup = barsizelast > mean(barsizerest) + norminv(0.99)*std(barsizerest);
            if isvolblowup
                output = struct('use',1,'comment','volblowup');
            else
                output = struct('use',0,'comment','teethjawcrossed');
            end
            return
        else
            %exclude if it is too close to TDST-lvldn
            isclose2lvldn = px(end,5)>lvldn(end) && (lvlup(end)-px(end,5))/(lvlup(end)-lvldn(end))>0.9&&lvlup(end)>lvldn(end);
            if isclose2lvldn
                output = struct('use',0,'comment','closetolvldn');
                return
            end
            %keep if it breaches the ll after bc13
            lastbc13 = find(bc(1:end-1)==13,1,'last');
            if ~isempty(lastbc13) && size(px,1)-lastbc13<9 &&px(end,5)<min(px(lastbc13:end-1,4))
                output = struct('use',1,'comment','breachdn-lowbc13');
                return
            end
            %
            %
            barsizelast = px(end,3)-px(end,4);
            barsizerest = px(end-nkfromll+1:end-1,3)-px(end-nkfromll+1:end-1,4);
            isvolblowup = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
            if isvolblowup
                output = struct('use',1,'comment','volblowup');
                return
            else
                barsizelast = abs(px(end,5)-px(end-1,5));
                isvolblowup2 = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
                if isvolblowup2
                    if bs(end) <= 1
                        output = struct('use',0,'comment','volblowup2-bs1');
                    else
                        output = struct('use',1,'comment','volblowup2');
                    end
                    return
                end
            end
            %
            %INVESTIGATE AND RESEARCH FURTHER
            if nkbelowteeth2 >= 2*nfractal+1 && ((~isempty(lastbc13) && size(px,1)-lastbc13>8)||isempty(lastbc13))
                output = struct('use',1,'comment','strongbreach-trendconfirmed');
                return
            else
                if nkfromll == nfractal+2 && nkbelowteeth2 == nkfromll
                    last2llidx = find(idxLL(1:end)== -1,2,'last');
                    if size(last2llidx,1) < 2
                        output = struct('use',0,'comment','strongbreach-trendbreak');
                        return
                    end
                    last2ll = LL(last2llidx);
                    %check whether a new lower LL is formed or not
                    if isempty(find(px(last2llidx(1)-nfractal:end,5)-teeth(last2llidx(1)-nfractal:end)>0,1,'first')) ...
                            && last2ll(2)<last2ll(1) ...
                            && bs(end) < 9
                        output = struct('use',1,'comment','strongbreach-trendconfirmed');
                    else
                        output = struct('use',0,'comment','strongbreach-trendbreak');
                    end
                    return
                else
                    output = struct('use',0,'comment','strongbreach-trendbreak');
                    return
                end
            end
                    
        end
    end
    
    error('fractal_filters1_singleentry:invalid s1type input')
    
end