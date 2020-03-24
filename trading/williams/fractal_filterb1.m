function [idxfractalb1_filtered,comments] = fractal_filterb1(idxfractalb1,inputmatrix,nfractal)
%first filter-out at point HH is less than (below) HH
idxfractalb1_filtered = idxfractalb1(idxfractalb1(:,2) ~= 1,:);
%%
%
% px = inputmatrix(:,1:5);
% idxHH = inputmatrix(:,6);idxLL = inputmatrix(:,7);HH = res(:,8);LL = inputmatrix(:,9);
% jaw = inputmatrix(:,10);teeth = inputmatrix(:,11);lips = res(:,12);
% bs = inputmatrix(:,13);ss = inputmatrix(:,14);
% lvlup = inputmatrix(:,15);lvldn = inputmatrix(:,16);
% bc = inputmatrix(:,17);sc = inputmatrix(:,18);
%second filter-out any sc 13 case
for i = 1:size(idxfractalb1_filtered,1)
    j = idxfractalb1_filtered(i,1);
    if sc(j) == 13 && lips(j)>teeth(j)&&teeth(j)>jaw(j),idxfractalb1_filtered(i,2) = 0;end
end
idxfractalb1_filtered = idxfractalb1_filtered(idxfractalb1_filtered(:,2) ~= 0,:);
%    
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
    [~,~,nkabovelips,~,nkfromhh] = fractal_countb(px(1:j,:),idxHH,nfractal,lips,teeth,jaw);
    if nkabovelips >= 2*nfractal+1, continue;end
    if nkfromhh == nfractal + 2,continue;end
    %
    if nkabovelips < 2*nfractal+1
        %if it is a lvlup breach, we keep it
        if ~(px(j,5)>lvlup(j) && px(j-1,5) < lvlup(j))
            %also check the barsize
            barsizelast = px(j,3)-px(j,4);
            barsizerest = px(j-nkfromhh+1:j-1,3)-px(j-nkfromhh+1:j-1,4);
            if barsizelast < mean(barsizerest) + 2.58*std(barsizerest)
                idxfractalb1_filtered(i,2) = 0;
            end
            if idxfractalb1_filtered(i,2) == 0, continue;end
            if px(j,5)<lvlup(j)&&(px(j,5)-lvldn(j))/(lvlup(j)-lvldn(j))>0.9&&(lvlup(j)>lvldn(j))
                idxfractalb1_filtered(i,2) = 0;
            end
        end
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
        if ~(px(j,5)>lvlup(j) && (px(j-1,5) < lvlup(j) || px(j,4)<lvlup(j)))
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
        if nkfromhh == nfractal+2
            %breach on the 1st candle after the fractal is formed
            if nkaboveteeth2 < nfractal+2
                if ~(px(j,5)>lvlup(j) && px(j-1,5) < lvlup(j))
                    idxfractalb1_filtered(i,2) = 0;
                end
            end
        elseif nkfromhh > nfractal+2
            %breach after the 1st candle after the fractal is formed
            if nkaboveteeth2 >= nfractal+2
                %NOTE:here we need to discuss whether it is nfractal+2 or
                %2*nfracal
                %not to follow the trend when the px is very close to lvlup
                if px(j,5)<lvlup(j)&&(px(j,5)-lvldn(j))/(lvlup(j)-lvldn(j))>0.9&&(lvlup(j)>lvldn(j))
                    idxfractalb1_filtered(i,2) = 0;
                end
            else
                %else it shall happen when it breach lvlup
                if ~(px(j,5)>lvlup(j) && px(j-1,5)<lvlup(j))
                    %also check the barsize
                    %include when breach with high volatility
                    barsizelast = px(j,3)-px(j,4);
                    barsizerest = px(j-nkfromhh+1:j-1,3)-px(j-nkfromhh+1:j-1,4);
                    if barsizelast < mean(barsizerest) + 2.58*std(barsizerest)
                        %also to check wheher if breach the high of sc13 if sc13 is
                        %near-by
                        lastsc13 = find(sc(1:j)==13,1,'last');
                        if j-lastsc13 <= 12 && px(j,5)>px(lastsc13,3)
                            continue;
                        else
                            idxfractalb1_filtered(i,2) = 0;
                        end
                    end
                end
            end
        end
    end
    %
end
% idxfractalb1_filtered = idxfractalb1_filtered(idxfractalb1_filtered(:,2) ~= 0,:);

    
end