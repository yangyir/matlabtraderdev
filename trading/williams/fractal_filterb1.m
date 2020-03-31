function [idxfractalb1_filtered,comments] = fractal_filterb1(idxfractalb1,inputmatrix,nfractal)
idxfractalb1_filtered = idxfractalb1;
comments = cell(size(idxfractalb1,1),1);
%%
%filter-out any sc 13 case
for i = 1:size(idxfractalb1_filtered,1)
    if idxfractalb1_filtered(i,2) == 0, continue;end
    j = idxfractalb1_filtered(i,1);
    if sc(j) == 13 && lips(j)>teeth(j)&&teeth(j)>jaw(j)
        idxfractalb1_filtered(i,2) = 0;
        comments{i} = 'sc13';
        continue;
    end
end
%%
%treatment for weak breach case
%keep it if and only if breach through TDST-lvlup or TDST-lvldn (MAYBE)
for i = 1:size(idxfractalb1_filtered,1)
    if idxfractalb1_filtered(i,2) ~= 1, continue;end
%     j = idxfractalb1_filtered(i,1);
%     if (px(j,5)>lvlup(j) && px(j-1,5)<lvlup(j)) ||...
%         (px(j,5)>lvlup(j) && px(j,4)<lvlup(j))
%         comments{i} = 'weakbreach-breachup-lvlup';
%     elseif (px(j,5)>lvldn(j) && px(j-1,5)<lvldn(j)) ||...
%         (px(j,5)>lvldn(j) && px(j,4)<lvldn(j))
%         comments{i} = 'weakbreach-breachdn-lvldn';
%     else
        idxfractalb1_filtered(i,2) = 0;
        comments{i} = 'weakbreach';
%     end
end
%%
%treatment for medium breach case
for i = 1:size(idxfractalb1_filtered,1)
    if idxfractalb1_filtered(i,2) == 0, continue;end
    if idxfractalb1_filtered(i,2) ~= 2, continue;end
    j = idxfractalb1_filtered(i,1);
    %keep if it breaches-up TDST-lvlup
    isbreachlvlup = (~isempty(find(px(j-ss(j):j,5)>lvlup(j),1,'first')) &&~isempty(find(px(j-ss(j):j,5)<lvlup(j),1,'first')) && px(j,5)>lvlup(j)) || ...
        (px(j,5)>lvlup(j) && px(j-1,5)<lvlup(j)) ||...
        (px(j,5)>lvlup(j) && px(j,4)<lvlup(j));
    if isbreachlvlup
        comments{i} = 'breachup-lvlup';
        continue;
    end
    %keep if it breach-up TDST-lvldn
    isbreachlvldn = (~isempty(find(px(j-ss(j):j,5)>lvldn(j),1,'first')) &&~isempty(find(px(j-ss(j):j,5)<lvldn(j),1,'first')) && px(j,5)>lvldn(j)) || ...
        (px(j,5)>lvldn(j) && px(j-1,5)<lvldn(j)) ||...
        (px(j,5)>lvldn(j) && px(j,4)<lvldn(j));
    if isbreachlvldn
        comments{i} = 'breachup-lvldn';
        continue;
    end
    %exclude if it is too close to TDST-lvlup
    isclose2lvlup = px(j,5)<lvlup(j) && (lvlup(j)-px(j,5))/(lvlup(j)-lvldn(j))<0.1&&lvlup(j)>lvldn(j);
    if isclose2lvlup
        comments{i} = 'closetolvlup';
        idxfractalb1_filtered(i,2) = 0;
        continue;
    end
    %exclude perfect TDST-sellsetup
    if ss(j) >= 9 && px(j,5) >= max(px(j-ss(j)+1:j,5)) && px(j,3) >= max(px(j-ss(j)+1:j,3))
        comments{i} = 'mediumbreach-sshighvalue';
        idxfractalb1_filtered(i,2) = 0;
        continue;
    end
    %keep if it breaches the hh after sc13
    lastsc13 = find(sc(1:j-1)==13,1,'last');
    if ~isempty(lastsc13) && j-lastsc13<9 &&px(j,5)>max(px(lastsc13:j-1,3))
        comments{i} = 'breachup-highsc13';
        continue;
    end
    %
    [~,~,nkabovelips,nkaboveteeth,nkfromhh] = fractal_countb(px(1:j,:),idxHH,nfractal,lips,teeth,jaw);
    barsizelast = px(j,3)-px(j,4);
    barsizerest = px(j-nkfromhh+1:j-1,3)-px(j-nkfromhh+1:j-1,4);
    isvolblowup = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
    if isvolblowup
        comments{i} = 'volblowup';
        continue;
    else
        barsizelast = abs(px(j,5)-px(j-1,5));
        isvolblowup2 = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
        if isvolblowup2
            if ss(j) <= 1
                idxfractalb1_filtered(i,2) = 0;
                comments{i} = 'volblowup2-ss1';
                continue;
            else
                comments{i} = 'volblowup2';
                continue;
            end
        end
    end
    %
    if nkaboveteeth >= 2*nfractal+1
        if lips(j) > teeth(j)
            comments{i} = 'mediumbreach-trendconfirmed';
            continue;
        else
            comments{i} = 'mediumbreach-trendbreak';
            idxfractalb1_filtered(i,2) = 0;
            continue;
        end
    else
        %TODO:INVESTIGATE MORE IN THE FUTURE
        if (nkabovelips == nkfromhh || nkaboveteeth == nkfromhh) && nkfromhh == nfractal+2
            if lips(j) > teeth(j)
                comments{i} = 'mediumbreach-trendconfirmed';
                continue;
            else
                comments{i} = 'mediumbreach-trendbreak';
                idxfractalb1_filtered(i,2) = 0;
                continue;
            end
        else
            if nkfromhh == nfractal+2
                if nkabovelips > 1 && nkaboveteeth > 1 && lips(j)>teeth(j)
                    comments{i} = 'mediumbreach-trendconfirmed';
                    continue;
                else
                    comments{i} = 'mediumbreach-trendbreak';
                    idxfractalb1_filtered(i,2) = 0;
                    continue;
                end
            else
                if nkabovelips >= 2*nfractal+1
                    comments{i} = 'mediumbreach-trendconfirmed';
                    continue;
                else
                    comments{i} = 'mediumbreach-trendbreak';
                    idxfractalb1_filtered(i,2) = 0;
                    continue;
                end
            end
        end
    end     
end
%%
%treatment for strong breach case
for i = 1:size(idxfractalb1_filtered,1)
    if idxfractalb1_filtered(i,2) == 0, continue;end
    if idxfractalb1_filtered(i,2) ~= 3, continue;end
    j = idxfractalb1_filtered(i,1);
    %1.exclude when the market is extremely bullish
    if ss(j) >= 15
        comments{i} = 'strongbreach-sshighvalue';
        idxfractalb1_filtered(i,2) = 0;
        continue;
    end
    %
    %2.pay attention to case of alligator's teeth and jaw crossed
    [~,~,~,nkaboveteeth2,nkfromhh,teethjawcrossed] = fractal_countb(px(1:j,:),idxHH,nfractal,lips,teeth,jaw);
    %
    %keep if it breach-up TDST-lvlup
    isbreachlvlup = (~isempty(find(px(j-ss(j):j,5)>lvlup(j),1,'first')) &&~isempty(find(px(j-ss(j):j,5)<lvlup(j),1,'first')) && px(j,5)>lvlup(j)) || ...
        (px(j,5)>lvlup(j) && px(j-1,5)<lvlup(j)) ||...
        (px(j,5)>lvlup(j) && px(j,4)<lvlup(j));
    if isbreachlvlup
        if teethjawcrossed && ss(j) >= 9
            %check whether WAD is consistent with the price move
            maxpx = max(px(j-ss(j)+1:j-1,5));
            maxpxidx = find(px(j-ss(j)+1:j-1,5)==maxpx,1,'last')+j-ss(j);
            if wad(maxpxidx) < wad(j)
                comments{i} = 'breachup-lvlup';
                continue;
            else
                comments{i} = 'breachup-lvlup-teethjawcrossed';
                idxfractalb1_filtered(i,2) = 0;
                continue;
            end
        else
            comments{i} = 'breachup-lvlup';
            continue;
        end
    end
    %keep if it breach-up TDST-lvldn
    isbreachlvldn = (~isempty(find(px(j-ss(j):j,5)>lvldn(j),1,'first')) &&~isempty(find(px(j-ss(j):j,5)<lvldn(j),1,'first')) && px(j,5)>lvldn(j)) || ...
        (px(j,5)>lvldn(j) && px(j-1,5)<lvldn(j)) ||...
        (px(j,5)>lvldn(j) && px(j,4)<lvldn(j));
    if isbreachlvldn
        if teethjawcrossed && ss(j) >= 9
            %check whether WAD is consistent with the price move
            maxpx = max(px(j-ss(j)+1:j-1,5));
            maxpxidx = find(px(j-ss(j)+1:j-1,5)==maxpx,1,'last')+j-ss(j);
            if wad(maxpxidx) < wad(j)
                comments{i} = 'breachup-lvldn';
                continue;
            else
                comments{i} = 'breachup-lvldn-teethjawcrossed';
                idxfractalb1_filtered(i,2) = 0;
                continue;
            end
        else
            comments{i} = 'breachup-lvldn';
            continue;
        end
    end
    %
    %keep if it breach-up high of a previous sell sequential
    if ss(j-nkfromhh+1) >= 9
        lastss = ss(j-nkfromhh+1);
        if (px(j-nkfromhh+1,5) >= max(px(j-nkfromhh-lastss+2:j-nkfromhh+1,5)) && ...
                px(j-nkfromhh+1,3) >= max(px(j-nkfromhh-lastss+2:j-nkfromhh+1,3)))
            comments{i} = 'breachup-sshighvalue';
            continue;
        end
    end
    if teethjawcrossed
        comments{i} = 'teethjawcrossed';
        idxfractalb1_filtered(i,2) = 0;
        continue;
    else
        %exclude if it is too close to TDST-lvlup
        isclose2lvlup = px(j,5)<lvlup(j) && (lvlup(j)-px(j,5))/(lvlup(j)-lvldn(j))<0.1&&lvlup(j)>lvldn(j); 
        if isclose2lvlup
            comments{i} = 'closetolvlup';
            idxfractalb1_filtered(i,2) = 0;
            continue;
        end
        %keep if it breachs the hh after sc13
        lastsc13 = find(sc(1:j-1)==13,1,'last');
        if ~isempty(lastsc13) && j-lastsc13<9 &&px(j,5)>max(px(lastsc13:j-1,3))
            comments{i} = 'breachup-highsc13';
            continue;
        end
        %
        barsizelast = px(j,3)-px(j,4);
        barsizerest = px(j-nkfromhh+1:j-1,3)-px(j-nkfromhh+1:j-1,4);
        isvolblowup = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
        if isvolblowup
            comments{i} = 'volblowup';
            continue;
        else
            barsizelast = abs(px(j,5)-px(j-1,5));
            isvolblowup2 = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
            if isvolblowup2
                if ss(j) <= 1
                    idxfractalb1_filtered(i,2) = 0;
                    comments{i} = 'volblowup2-ss1';
                    continue;
                else
                    comments{i} = 'volblowup2';
                    continue;
                end
            else
%                 if nkaboveteeth2 >= 2*nfractal+1 && nkaboveteeth2 == nkfromhh
                if nkaboveteeth2 >= 2*nfractal+1 && ((~isempty(lastsc13) && j-lastsc13>12)||isempty(lastsc13))
                    comments{i} = 'strongbreach-trendconfirmed';
                    continue;
                else
                    if nkfromhh == nfractal+2 &&  nkaboveteeth2 == nkfromhh
                        last2hhidx = find(idxHH(1:j)==1,2,'last');
                        if size(last2hhidx,1) < 2
                            comments{i} = 'strongbreach-trendbreak';
                            idxfractalb1_filtered(i,2) = 0;
                            continue;
                        end
                        last2hh = HH(last2hhidx);
                        %check whether a new higher HH is formed or not
                        if isempty(find(px(last2hhidx(1)-nfractal:j,5)-teeth(last2hhidx(1)-nfractal:j)<0,1,'first')) ...
                                && last2hh(2)>last2hh(1) ...
                                && ss(j) < 9
                            comments{i} = 'strongbreach-trendconfirmed';
                            continue;
                        else
                            comments{i} = 'strongbreach-trendbreak';
                            idxfractalb1_filtered(i,2) = 0;
                            continue;
                        end
                    else                    
                        comments{i} = 'strongbreach-trendbreak';
                        idxfractalb1_filtered(i,2) = 0;
                        continue;
                    end
                end
            end
        end
    end
end