function [output] = fractal_filterb1_singleentry(b1type,nfractal,extrainfo,ticksize)
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
    idxHH = extrainfo.idxhh;
    HH = extrainfo.hh;
    LL = extrainfo.ll;
    lips = extrainfo.lips;
    teeth = extrainfo.teeth;
    jaw = extrainfo.jaw;
    wad = extrainfo.wad;
       
    status = fractal_b1_status(nfractal,extrainfo,ticksize);
    
    if sc(end) == 13 && ~status.istrendconfirmed
        output = struct('use',0,'comment','sc13');
        return
    end
    
    if b1type == 2
        %keep if it breaches-up TDST-lvlup
        if status.islvlupbreach ~= 0
            output = struct('use',1,'comment','breachup-lvlup');
            return
        end
        %exclude if it is too close to TDST-lvlup
        isclose2lvlup = px(end,5)<lvlup(end) && (lvlup(end)-px(end,5))/(lvlup(end)-lvldn(end))<0.1&&lvlup(end)>lvldn(end);
        if isclose2lvlup
            output = struct('use',0,'comment','closetolvlup');
            return
        end
        %exclude perfect TDST-sellsetup
%         if ss(end) >= 9 && px(end,5) >= max(px(end-ss(end)+1:end,5)) && px(end,3) >= max(px(end-ss(end)+1:end,3))       
        if status.issshighvalue
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
            if lips(end) > teeth(end)
                output = struct('use',1,'comment','volblowup');
            else
                output = struct('use',0,'comment','volblowup-alligatorfailed');
            end
            return
        else
            if status.isvolblowup2
                if lips(end) > teeth(end)
                    output = struct('use',1,'comment','volblowup2');
                else
                    output = struct('use',0,'comment','volblowup2-alligatorfailed');
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
            output = struct('use',0,'comment','mediumbreach-trendbreak');
            return
        end
%         if nkaboveteeth >= 2*nfractal+1
%             if lips(end) > teeth(end)
%                 output = struct('use',1,'comment','mediumbreach-trendconfirmed');
%                 return
%             else
%                 output = struct('use',0,'comment','mediumbreach-trendbreak');
%                 return
%             end
%         else
%             if (nkabovelips == nkfromhh || nkaboveteeth == nkfromhh) && nkfromhh == nfractal+2
%                 if lips(end) > teeth(end)
%                     output = struct('use',1,'comment','mediumbreach-trendconfirmed');
%                     return
%                 else
%                     output = struct('use',0,'comment','mediumbreach-trendbreak');
%                     return
%                 end
%             end
%             %
%             if nkfromhh == nfractal+2
%                 last2hhidx = find(idxHH(1:end)== 1,2,'last');
%                 if size(last2hhidx,1) < 2
%                     output = struct('use',0,'comment','mediumbreach-trendbreak');
%                     return
%                 end
%                 last2hh = HH(last2hhidx);
%                 %check whether a new higher HH is formed or not
%                 if last2hh(2)>last2hh(1) && ss(end)<9
%                     output = struct('use',1,'comment','mediumbreach-trendconfirmed');
%                 elseif last2hh(2)<last2hh(1)&&px(end,5)>last2hh(1)&&ss(end)<9
%                     output = struct('use',1,'comment','mediumbreach-trendconfirmed');
%                 else
%                     output = struct('use',0,'comment','mediumbreach-trendbreak');
%                 end
%                 return
%             end
%             %     
%             if nkabovelips >= 2*nfractal+1 && nkaboveteeth >= 2*nfractal+1
%                 output = struct('use',1,'comment','mediumbreach-trendconfirmed');
%                 return
%             end
%             %
%             if nkabovelips >= 2*nfractal+1 && nkfromhh-nkabovelips<nfractal && nkaboveteeth >= nfractal+1
%                 output = struct('use',1,'comment','mediumbreach-trendconfirmed');
%                 return
%             end
%             %
%             hasbreachedll = ~isempty(find(px(end-nkfromhh+1:end-1,5)-LL(end-nkfromhh+1:end-1)<0,1,'first'));
%             if ~hasbreachedll && status.istrendconfirmed
%                 output = struct('use',1,'comment','mediumbreach-trendconfirmed');
%                 return
%             end
%             %
%             output = struct('use',0,'comment','mediumbreach-trendbreak');
%             return
%                      
%         end
    end
        
    if b1type == 3
        %exclude when the market is extremely bullish
        if ss(end) >= 15
            if ~status.isschighbreach
                output = struct('use',0,'comment','strongbreach-sshighvalue');
                return
            end
        end
        %
%         [~,~,~,nkaboveteeth2,nkfromhh,teethjawcrossed] = fractal_countb(px,idxHH,nfractal,lips,teeth,jaw,ticksize);
        %
        %keep if it breach-up TDST-lvlup
        if status.islvlupbreach ~= 0
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
%         if ss(end-nkfromhh+1) >= 9
%             lastss = ss(end-nkfromhh+1);
% %             if (px(end-nkfromhh+1,5) >= max(px(end-nkfromhh-lastss+2:end-nkfromhh+1,5)) && ...
% %                     px(end-nkfromhh+1,3) >= max(px(end-nkfromhh-lastss+2:end-nkfromhh+1,3)))
%             if px(end-nkfromhh+1,3) >= max(px(end-nkfromhh-lastss+2:end-nkfromhh+1,3))
%                 output = struct('use',1,'comment','breachup-sshighvalue');
%                 return
%             end
%         end
        if status.issshighbreach
            output = struct('use',1,'comment','breachup-sshighvalue');
            return
        end
%         if ss(end) > 9
%             if px(end,5) > max(px(end-ss(end):end-1,3))
%                 output = struct('use',1,'comment','breachup-sshighvalue');
%                 return
%             end
%         end
        %
        if status.isteethjawcrossed
            if status.isvolblowup
                if lips(end) > teeth(end)
                    output = struct('use',1,'comment','volblowup');
                else
                    output = struct('use',0,'comment','volblowup-alligatorfailed');
                end
                return
            end
            %
            if status.isvolblowup2
                if lips(end) > teeth(end)
                    output = struct('use',1,'comment','volblowup2');
                else
                    output = struct('use',0,'comment','volblowup2-alligatorfailed');
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
            
%             if nkaboveteeth2 >= 2*nfractal+1 && ss(end) < 9
%                 output = struct('use',1,'comment','strongbreach-trendconfirmed');
%                 return
%             end
%             %
%             hasbreachedll = ~isempty(find(px(end-nkfromhh+1:end-1,5)-LL(end-nkfromhh+1:end-1)<0,1,'first'));
%             if ~hasbreachedll && nkaboveteeth2 > nfractal+1
%                 if ss(end) >= 9 && px(end,5) >= max(px(end-ss(end)+1:end,5)) && px(end,3) >= max(px(end-ss(end)+1:end,3))
%                       output = struct('use',0,'comment','strongbreach-sshighvalue');
%                 else
%                       output = struct('use',1,'comment','strongbreach-trendconfirmed');
%                 end
%                 return
%             end
%             output = struct('use',0,'comment','teethjawcrossed');
%                 
%             return
        else
            %exclude if it is too close to TDST-lvlup
            isclose2lvlup = px(end,5)<lvlup(end) && (lvlup(end)-px(end,5))/(lvlup(end)-lvldn(end))<0.1&&lvlup(end)>lvldn(end);
            if isclose2lvlup
                output = struct('use',0,'comment','closetolvlup');
                return
            end
            %keep if it breachs the hh after sc13
%             lastsc13 = find(sc(1:end-1)==13,1,'last');
%             if ~isempty(lastsc13) && size(px,1)-lastsc13<12 &&px(end,5)>=max(px(lastsc13:end-1,3))
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
                if lips(end) > teeth(end)
                    output = struct('use',1,'comment','volblowup');
                else
                    output = struct('use',0,'comment','volblowup-alligatorfailed');
                end
                return
            else
                if status.isvolblowup2
                    if lips(end) > teeth(end)
                        output = struct('use',1,'comment','volblowup2');
                    else
                        output = struct('use',0,'comment','volblowup2-alligatorfailed');
                    end
                    return
                end
            end
            %
            %INVESTIGATE AND RESEARCH FURTHER
%             if nkaboveteeth2 >= 2*nfractal+1 && ((~isempty(lastsc13) && size(px,1)-lastsc13>8)||isempty(lastsc13))
%                 output = struct('use',1,'comment','strongbreach-trendconfirmed');
%                 return
%             else
%                 if nkfromhh == nfractal+2 &&  nkaboveteeth2 == nkfromhh
%                     last2hhidx = find(idxHH(1:end)==1,2,'last');
%                     if size(last2hhidx,1) < 2
%                         output = struct('use',0,'comment','strongbreach-trendbreak');
%                         return
%                     end
%                     last2hh = HH(last2hhidx);
%                     %check whether a new higher HH is formed or not
%                     if isempty(find(px(last2hhidx(1)-nfractal:end,5)-teeth(last2hhidx(1)-nfractal:end)<0,1,'first')) ...
%                             && last2hh(2)>=last2hh(1) ...
%                             && ss(end) < 9
%                         output = struct('use',1,'comment','strongbreach-trendconfirmed');
%                     else
%                         output = struct('use',0,'comment','strongbreach-trendbreak');
%                     end
%                     return
%                 else
%                     output = struct('use',0,'comment','strongbreach-trendbreak');
%                     return
%                 end
%             end
            if status.istrendconfirmed
                output = struct('use',1,'comment','strongbreach-trendconfirmed');
                return
            else
                output = struct('use',0,'comment','strongbreach-trendbreak');
                return
            end
        end            
    end
    
    error('fractal_filterb1_singleentry:invalid b1type input')
end