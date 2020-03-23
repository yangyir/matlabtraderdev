function [idxfractalb1_filtered,comments] = fractal_filterb1(idxfractalb1,inputmatrix,nfractal)
%first filter-out at point HH is less than (below) HH
idxfractalb1_filtered = idxfractalb1(idxfractalb1(:,2) ~= 1,:);

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
idxfractalb1_filtered = idxfractalb1_filtered(idxfractalb1_filtered(:,2) ~= 0,:);
%treatment for medium breach case continue
%filter by count No.of candles stay above lips before open
for i = 1:size(idxfractalb1_filtered,1)
    if idxfractalb1_filtered(i,2) ~= 2, continue;end
    j = idxfractalb1_filtered(i,1);
    [~,~,nkabovelips,~,nkfromhh] = fractal_countb(px(1:j,:),idxHH,nfractal,lips,teeth);
    if nkabovelips >= 2*nfractal+1, continue;end
    if nkfromhh == nfractal + 2,continue;end
    %
    if nkabovelips < 2*nfractal+1
        %if it is a lvlup breach, we keep it
        if ~(px(j,5)>lvlup(j) && px(j-1,5) < lvlup(j))
            %also check the barsize
            barsizelast = px(j,3)-px(j,4);
            barsizerest = px(j-nkfromhh:j-1,3)-px(j-nkfromhh:j-1,4);
            if barsizelast < mean(barsizerest) + 1.96*std(barsizerest)
                idxfractalb1_filtered(i,2) = 0;
            end
        end
    end
end
idxfractalb1_filtered = idxfractalb1_filtered(idxfractalb1_filtered(:,2) ~= 0,:);
%
%treatment for strong breach case
for i = 1:size(idxfractalb1_filtered,1)
    if idxfractalb1_filtered(i,2) ~= 3, continue;end
    j = idxfractalb1_filtered(i,1);
    if ss(j) >= 16, idxfractalb1_filtered(i,2) = 0;end
    [~,nkaboveteeth1,~,nkaboveteeth2,nkfromhh] = fractal_countb(px(1:j,:),idxHH,nfractal,lips,teeth);
    if nkaboveteeth2 >= 2*nfractal
        if px(j,5)<lvlup(j)&&(px(j,5)-lvldn(j))/(lvlup(j)-lvldn(j))>0.95&&(lvlup(j)>lvldn(j))
            idxfractalb1_filtered(i,2) = 0;
        end
    end
    %
    if nkfromhh == nfractal+2 && nkaboveteeth2 < nfractal+2
        if ~(px(j,5)>lvlup(j) && px(j-1,5) < lvlup(j))
            idxfractalb1_filtered(i,2) = 0;
        end 
    end
    %
    if nkaboveteeth2 < 2*nfractal
        if ~(px(j,5)>lvlup(j) && px(j-1,5) < lvlup(j))
            %also check the barsize
            barsizelast = px(j,3)-px(j,4);
            barsizerest = px(j-nkfromhh:j-1,3)-px(j-nkfromhh:j-1,4);
            if barsizelast < mean(barsizerest) + 1.96*std(barsizerest)
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
        %
        
    end
end
idxfractalb1_filtered = idxfractalb1_filtered(idxfractalb1_filtered(:,2) ~= 0,:);

    
end