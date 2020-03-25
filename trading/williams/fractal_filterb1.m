function [idxfractalb1_filtered,comments] = fractal_filterb1(idxfractalb1,inputmatrix,nfractal)
%first filter-out at point HH is less than (below) HH
idxfractalb1_filtered = idxfractalb1(idxfractalb1(:,2) ~= 1,:);
%%
px = inputmatrix(:,1:5);
idxHH = inputmatrix(:,6);idxLL = inputmatrix(:,7);HH = res(:,8);LL = inputmatrix(:,9);
jaw = inputmatrix(:,10);teeth = inputmatrix(:,11);lips = res(:,12);
bs = inputmatrix(:,13);ss = inputmatrix(:,14);
lvlup = inputmatrix(:,15);lvldn = inputmatrix(:,16);
bc = inputmatrix(:,17);sc = inputmatrix(:,18);
%%
%second filter-out any sc 13 case
for i = 1:size(idxfractalb1_filtered,1)
    j = idxfractalb1_filtered(i,1);
    if sc(j) == 13 && lips(j)>teeth(j)&&teeth(j)>jaw(j),idxfractalb1_filtered(i,2) = 0;end
end
idxfractalb1_filtered = idxfractalb1_filtered(idxfractalb1_filtered(:,2) ~= 0,:);
%%    
%treatment for medium breach case
for i = 1:size(idxfractalb1_filtered,1)
    if idxfractalb1_filtered(i,2) ~= 2, continue;end
    j = idxfractalb1_filtered(i,1);
    if ss(j) < 9, continue;end
    %remove perfect ss
    if px(j,5) >= max(px(j-ss(j)+1:j,5)) && px(j,3) >= max(px(j-ss(j)+1:j,3))
        %need to make sure it is not breach lvlup
        if ~(px(j,5)>lvlup(j) && px(j-1,5) < lvlup(j))
            idxfractalb1_filtered(i,2) = 0;
        end
    end    
end
% idxfractalb1_filtered = idxfractalb1_filtered(idxfractalb1_filtered(:,2) ~= 0,:);
%treatment for medium breach case continue
%filter by count No.of candles stay above lips before open
for i = 1:size(idxfractalb1_filtered,1)
    if idxfractalb1_filtered(i,2) ~= 2, continue;end
    j = idxfractalb1_filtered(i,1);
    if px(j,5)<lvlup(j)&&(px(j,5)-lvldn(j))/(lvlup(j)-lvldn(j))>0.90&&(lvlup(j)>lvldn(j))
        idxfractalb1_filtered(i,2) = 0;
        continue;
    end    
    [~,~,nkabovelips,~,nkfromhh] = fractal_countb(px(1:j,:),idxHH,nfractal,lips,teeth,jaw);
    if nkabovelips == nkfromhh
        %do nothing maybe something at later stage
    else
        %need to check whether it make sense to include all breach if it
        %happens on the first candle after the fractal
        if nkfromhh == nfractal + 2, continue;end
        %
        %we shall keep the signal if it breach up TDST-lvlup or
        %TDST-lvldn at the same time
        isbreachlvlup = px(j,5)>lvlup(j) && (px(j-1,5)<lvlup(j) || px(j,4)<lvlup(j));
        isbreachlvldn = px(j,5)>lvldn(j) && (px(j-1,5)<lvldn(j) || px(j,4)<lvldn(j));
        if (isbreachlvlup || isbreachlvldn), continue;end
        %
        %we shall also keep the signal if the breach candle's vol is
        %much higher than the previous ones
        barsizelast = px(j,3)-px(j,4);    
        barsizerest = px(j-nkfromhh+1:j-1,3)-px(j-nkfromhh+1:j-1,4);
        if barsizelast > mean(barsizerest) + 2.58*std(barsizerest), continue;end
        %
        %we shall also keep the signal if the breach of lvlup was
        %during this TDST-Sell Setup
        if ss(j) > 0 && ~isempty(find(px(j-ss(j):j,5)<lvlup(j),1,'first'))&&p(j,5)>lvlup(j),continue;end
        if ss(j) > 0 && ~isempty(find(px(j-ss(j):j,5)<lvldn(j),1,'first'))&&p(j,5)>lvldn(j),continue;end
        %
        %we shall also keep the signal if it failed the last sell
        %countdown 13 by breaching its high
        lastsc13 = find(sc(1:j)==13,1,'last');
        if ~isempty(lastsc13) && j-lastsc13 <= 12 && px(j,5)>px(lastsc13,3), continue;end
        %with close above teeth
        %HERE we need more samples
        if nkabovelips >= 2*nfractal+1,continue;end
        idxfractalb1_filtered(i,2) = 0;
    end
end
% idxfractalb1_filtered = idxfractalb1_filtered(idxfractalb1_filtered(:,2) ~= 0,:);
%%
%treatment for strong breach case
for i = 1:size(idxfractalb1_filtered,1)
    if idxfractalb1_filtered(i,2) ~= 3, continue;end
    j = idxfractalb1_filtered(i,1);
    %1.we are not going to follow when the market is extremely bullish
    if ss(j) >= 15, idxfractalb1_filtered(i,2) = 0;end
    [~,~,~,nkaboveteeth2,nkfromhh,teethjawcrossed] = fractal_countb(px(1:j,:),idxHH,nfractal,lips,teeth,jaw);
    %
    %2.pay attention to case of alligator's teeth and jaw crossed
    if teethjawcrossed
        %it's risky to follow the bullish trend in case teeth and jaw crossed
        if ss(j) >= 9, idxfractalb1_filtered(i,2) = 0;end
        if idxfractalb1_filtered(i,2) == 0, continue;end
        %but it is ok if it also breach lvlup
        if ~(px(j,5)>lvlup(j) && (px(j-1,5)<lvlup(j) || px(j,4)<lvlup(j)))
            %also it is ok if it breach high of a previous sell sequential
            %and the high is also a fractal upper boundary
            %perfect sell sequential is also needed
            if ss(j-nkfromhh+1) >= 9
                lastss = ss(j-nkfromhh+1);
                if ~(px(j-nkfromhh+1,5) >= max(px(j-nkfromhh-lastss+2:j-nkfromhh+1,5)) && ...
                        px(j-nkfromhh+1,4) >= max(px(j-nkfromhh-lastss+2:j-nkfromhh+1,4)))
                    idxfractalb1_filtered(i,2) = 0;
                end
            else
                idxfractalb1_filtered(i,2) = 0;
            end
        end
    %3.alligator's teeth and jaw are not crossed    
    else
        if nkaboveteeth2 == nkfromhh
            if px(j,5)<lvlup(j)&&(px(j,5)-lvldn(j))/(lvlup(j)-lvldn(j))>0.95&&(lvlup(j)>lvldn(j))
                idxfractalb1_filtered(i,2) = 0;
            end
        else
            %nkaboveteeth2<nkfromhh
            %we shall keep the signal if it breach up TDST-lvlup or
            %TDST-lvldn at the same time
            isbreachlvlup = px(j,5)>lvlup(j) && (px(j-1,5)<lvlup(j) || px(j,4)<lvlup(j));
            isbreachlvldn = px(j,5)>lvldn(j) && (px(j-1,5)<lvldn(j) || px(j,4)<lvldn(j));
            if (isbreachlvlup || isbreachlvldn), continue;end
            %
            %we shall also keep the signal if the breach candle's vol is
            %much higher than the previous ones
            barsizelast = px(j,3)-px(j,4);    
            barsizerest = px(j-nkfromhh+1:j-1,3)-px(j-nkfromhh+1:j-1,4);
            if barsizelast > mean(barsizerest) + 2.58*std(barsizerest), continue;end
            %
            %we shall also keep the signal if the breach of lvlup was
            %during this TDST-Sell Setup
            if ss(j) > 0 && ~isempty(find(px(j-ss(j):j,5)<lvlup(j),1,'first'))&&p(j,5)>lvlup(j),continue;end
            if ss(j) > 0 && ~isempty(find(px(j-ss(j):j,5)<lvldn(j),1,'first'))&&p(j,5)>lvldn(j),continue;end
            %
            %we shall also keep the signal if it failed the last sell
            %countdown 13 by breaching its high
            lastsc13 = find(sc(1:j)==13,1,'last');
            if ~isempty(lastsc13) && j-lastsc13 <= 12 && px(j,5)>px(lastsc13,3), continue;end
            %
            %last but not least to keep at least 2*nfratcal+1 candle bar
            %with close above teeth
            %HERE we need more samples
            if nkaboveteeth2 >= 2*nfractal+1,continue;end
            idxfractalb1_filtered(i,2) = 0;
        end
    end
    %
end
% idxfractalb1_filtered = idxfractalb1_filtered(idxfractalb1_filtered(:,2) ~= 0,:);

    
end