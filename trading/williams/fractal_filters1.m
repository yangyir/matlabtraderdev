function [idxfractals1_filtered,comments] = fractal_filters1(idxfractals1,inputmatrix,nfractal)
idxfractals1_filtered = idxfractals1;
%%
%filter-out any bc 13 case
for i = 1:size(idxfractals1_filtered,1)
    j = idxfractals1_filtered(i,1);
    if bc(j) == 13 && lips(j)<teeth(j)&&teeth(j)<jaw(j),idxfractals1_filtered(i,2) = 0;end
end
%%
%treatment for strong breach case
for i = 1:size(idxfractals1_filtered,1)
    if idxfractals1_filtered(i,2) ~= 3, continue;end
    j = idxfractals1_filtered(i,1);
%     if bc(j) == 13 && lips(j)<teeth(j)&&teeth(j)<jaw(j),idxfractals1_filtered(i,2) = 0;end
    %1.we are not going to follow when the market is extremely bearish
%     if bs(j) >= 15, idxfractals1_filtered(i,2) = 0;end
    [~,~,~,nkbelowteeth2,nkfromll,teethjawcrossed] = fractal_counts(px(1:j,:),idxLL,nfractal,lips,teeth,jaw);
    %
    %2.pay attention to case of alligator's teeth and jaw crossed
    if teethjawcrossed
%         %it's risky to follow the bearish trend in case teeth and jaw
%         %crossed
%         if bs(j) >= 9
%             if ~isempty(find(px(j-bs(j):j,5)<lvldn(j),1,'first'))&&px(j,5)<lvldn(j)
%                 continue;
%             else
%                 idxfractals1_filtered(i,2) = 0;
%             end
%         else
%             idxfractals1_filtered(i,2) = 0;
%         end
    %3.alligator's teeth and jaw are not crossed
    else
        barsizelast = px(j,3)-px(j,4);    
        barsizerest = px(j-nkfromhh+1:j-1,3)-px(j-nkfromhh+1:j-1,4);
        isvolblowup = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
        if nkbelowteeth2 == nkfromll
            if nkfromll == 4
                %TODO:not sure about this for now
                if ~isempty(find(px(j-bs(j):j,5)<lvldn(j),1,'first')) &&...
                        ~isempty(find(px(j-bs(j):j,5)>lvldn(j),1,'first')) &&...
                        px(j,5)<lvldn(j)
                    continue
                elseif isvolblowup
                    continue
                else
                    idxfractals1_filtered(i,2) = 0;
                end
            else
%                 if px(j,5)>lvldn(j)&&(lvlup(j)-px(j,5))/(lvlup(j)-lvldn(j))>0.9&&(lvlup(j)>lvldn(j))
%                     idxfractals1_filtered(i,2) = 0;
%                 end
            end
        else
            
        end
        
        
    end
end
end