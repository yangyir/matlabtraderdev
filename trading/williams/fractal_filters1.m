function [idxfractals1_filtered,comments] = fractal_filters1(idxfractals1,inputmatrix,nfractal)
idxfractals1_filtered = idxfractals1;
comments = cell(size(idxfractals1,1),1);
%%
%filter-out any bc 13 case
for i = 1:size(idxfractals1_filtered,1)
    if idxfractals1_filtered(i,2) == 0, continue;end
    j = idxfractals1_filtered(i,1);
    if bc(j) == 13 && lips(j)<teeth(j)&&teeth(j)<jaw(j)
        idxfractals1_filtered(i,2) = 0;
        comments{i} = 'bc13';
        continue;
    end
end
%%
%treatment for weak breach case
%keep it if and only if breach through TDST-lvlup or TDST-lvldn 
for i = 1:size(idxfractals1_filtered,1)
    if idxfractals1_filtered(i,2) ~= 1, continue;end
    j = idxfractals1_filtered(i,1);
    if (px(j,5)<lvldn(j) && px(j-1,5)>lvldn(j)) ||...
        (px(j,5)<lvldn(j) && px(j,3)>lvldn(j))
        comments{i} = 'breachdn-lvldn';
    elseif (px(j,5)<lvlup(j) && px(j-1,5)>lvlup(j)) ||...
        (px(j,5)<lvlup(j) && px(j,3)>lvlup(j))
        comments{i} = 'breachdn-lvlup';
    else
        idxfractals1_filtered(i,2) = 0;
        comments{i} = 'weakbreach';
    end
end
%%
%treatment for medium breach case
for i = 1:size(idxfractals1_filtered,1)
    if idxfractals1_filtered(i,2) == 0, continue;end
    if idxfractals1_filtered(i,2) ~= 2, continue;end
    j = idxfractals1_filtered(i,1);
    %keep if it breaches-down TDST-lvldn
    isbreachlvldn = (~isempty(find(px(j-bs(j)+1:j,5)<lvldn(j),1,'first')) &&~isempty(find(px(j-bs(j)+1:j,5)>lvldn(j),1,'first')) && px(j,5)<lvldn(j)) || ...
        (px(j,5)<lvldn(j) && px(j-1,5)>lvldn(j)) ||...
        (px(j,5)<lvldn(j) && px(j,3)>lvldn(j));
    if isbreachlvldn
        comments{i} = 'breachdn-lvldn';
        continue;
    end
    %keep if it breaches-down TDST-lvlup
    isbreachlvlup = (~isempty(find(px(j-bs(j)+1:j,5)<lvlup(j),1,'first')) &&~isempty(find(px(j-bs(j)+1:j,5)>lvlup(j),1,'first')) && px(j,5)<lvldn(j)) || ...
        (px(j,5)<lvlup(j) && px(j-1,5)>lvlup(j)) ||...
        (px(j,5)<lvlup(j) && px(j,3)>lvlup(j));
    if isbreachlvlup
        comments{i} = 'breachdn-lvlup';
        continue;
    end
    %exclude if it is too close to TDST-lvldn
    isclose2lvldn = px(j,5)>lvldn(j) && (lvlup(j)-px(j,5))/(lvlup(j)-lvldn(j))>0.9&&lvlup(j)>lvldn(j);
    if isclose2lvldn
        comments{i} = 'closetolvldn';
        idxfractals1_filtered(i,2) = 0;
        continue
    end
    %exclude perfect TDST-buysetup
    if bs(j) >= 9 && px(j,5) <= min(px(j-bs(j)+1:j,5)) && px(j,4) <= min(px(j-bs(j)+1:j,4))
        %need to make sure it is not breach lvlup
        if ~(px(j,5)<lvldn(j) && px(j-1,5)>lvldn(j))
            comments{i} = 'mediumbreach-bshighvalue';
            idxfractals1_filtered(i,2) = 0;
            continue
        end
    end
    %keep if it breaches the ll after bc13
    lastbc13 = find(bc(1:j-1)==13,1,'last');
    if ~isempty(lastbc13) && j-lastbc13<=12 &&px(j,5)<min(px(lastbc13:j-1,4))
        comments{i} = 'breachdn-lowbc13';
        continue;
    end
    %
    [~,~,~,nkbelowteeth,nkfromll] = fractal_counts(px(1:j,:),idxLL,nfractal,lips,teeth,jaw);
    barsizelast = px(j,3)-px(j,4);
    barsizerest = px(j-nkfromll+1:j-1,3)-px(j-nkfromll+1:j-1,4);
    isvolblowup = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
    if isvolblowup
        comments{i} = 'volblowup';
        continue;
    else
        barsizelast = abs(px(j,5)-px(j-1,5));
        isvolblowup2 = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
%         retlast = abs(log(px(j,5)/px(j-1,5)));
%         retrest = abs(log(px(j-nkfromll+2:j-1,5)./px(j-nkfromll+1:j-2,5)));
%         isvolblowup2 = (retlast - 3*std(retrest))>1e-4;
        if isvolblowup2
            if bs(j) <= 1
                idxfractals1_filtered(i,2) = 0;
                comments{i} = 'volblowup2-bs1';
                continue;
            else
                comments{i} = 'volblowup2';
                continue;
            end
        end 
    end
    %
    if nkbelowteeth >= 2*nfractal+1
        if lips(j) < teeth(j)
            comments{i} = '5morebelowteeth-inc';
            continue;
        else
            comments{i} = '5morebelowteeth-exc';
            idxfractals1_filtered(i,2) = 0;
        end
    else
        comments{i} = '5lessbelowteeth';
        idxfractals1_filtered(i,2) = 0;
        continue;
    end  
end
%
%%
%treatment for strong breach case
for i = 1:size(idxfractals1_filtered,1)
    if idxfractals1_filtered(i,2) == 0, continue;end
    if idxfractals1_filtered(i,2) ~= 3, continue;end
    j = idxfractals1_filtered(i,1);
    %1.exclude when the market is extremely bearish
    if bs(j) >= 15
        comments{i} = 'strongbreach-bshighvalue';
        idxfractals1_filtered(i,2) = 0;
        continue;
    end
    %2.pay attention to case of alligator's teeth and jaw crossed
    %keep if it breaches-down TDST-lvldn
    isbreachlvldn = (~isempty(find(px(j-bs(j)+1:j,5)<lvldn(j),1,'first')) &&~isempty(find(px(j-bs(j)+1:j,5)>lvldn(j),1,'first')) && px(j,5)<lvldn(j)) || ...
        (px(j,5)<lvldn(j) && px(j-1,5)>lvldn(j)) ||...
        (px(j,5)<lvldn(j) && px(j,3)>lvldn(j));
    if isbreachlvldn
        comments{i} = 'breachdn-lvldn';
        continue;
    end
    %keep if it breaches-down TDST-lvlup
    isbreachlvlup = (~isempty(find(px(j-bs(j)+1:j,5)<lvlup(j),1,'first')) &&~isempty(find(px(j-bs(j)+1:j,5)>lvlup(j),1,'first')) && px(j,5)<lvldn(j)) || ...
        (px(j,5)<lvlup(j) && px(j-1,5)>lvlup(j)) ||...
        (px(j,5)<lvlup(j) && px(j,3)>lvlup(j));
    if isbreachlvlup
        comments{i} = 'breachdn-lvlup';
        continue;
    end
    [~,~,~,nkbelowteeth2,nkfromll,teethjawcrossed] = fractal_counts(px(1:j,:),idxLL,nfractal,lips,teeth,jaw);
    if teethjawcrossed
        comments{i} = 'teethjawcrossed';
        idxfractals1_filtered(i,2) = 0;
        continue;
    else       
        %exclude if it is too close to TDST-lvldn
        isclose2lvldn = px(j,5)>lvldn(j) && (lvlup(j)-px(j,5))/(lvlup(j)-lvldn(j))>0.9&&lvlup(j)>lvldn(j);
        if isclose2lvldn
            comments{i} = 'closetolvldn';
            idxfractals1_filtered(i,2) = 0;
            continue
        end
        %keep if it breaches the ll after bc13
        lastbc13 = find(bc(1:j-1)==13,1,'last');
        if ~isempty(lastbc13) && j-lastbc13<=12 &&px(j,5)<min(px(lastbc13:j-1,4))
            comments{i} = 'breachdn-lowbc13';
            continue;
        end
        %
    
        barsizelast = px(j,3)-px(j,4);
        barsizerest = px(j-nkfromll+1:j-1,3)-px(j-nkfromll+1:j-1,4);
        isvolblowup = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
        if isvolblowup
            comments{i} = 'volblowup';
            continue;
        else
%         retlast = abs(log(px(j,5)/px(j-1,5)));
%         retrest = abs(log(px(j-nkfromll+2:j-1,5)./px(j-nkfromll+1:j-2,5)));
%         isvolblowup2 = (retlast - 3*std(retrest))>1e-4;
            barsizelast = abs(px(j,5)-px(j-1,5));
            isvolblowup2 = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
            if isvolblowup2
                if bs(j) <= 1
                    idxfractals1_filtered(i,2) = 0;
                    comments{i} = 'volblowup2-bs1';
                    continue;
                else
                    comments{i} = 'volblowup2';
                    continue;
                end
            end 
        end
    end
    
    
%     
%     barsizelast = px(j,3)-px(j,4);    
%     barsizerest = px(j-nkfromll+1:j-1,3)-px(j-nkfromll+1:j-1,4);
%     isvolblowup = barsizelast > mean(barsizerest) + 2.58*std(barsizerest);
%     %
%     isbreachlvldn = (~isempty(find(px(j-bs(j)+1:j,5)<lvldn(j),1,'first')) &&~isempty(find(px(j-bs(j)+1:j,5)>lvldn(j),1,'first')) && px(j,5)<lvldn(j)) || ...
%         (px(j,5)<lvldn(j) && px(j-1,5)>lvldn(j)) ||...
%         (px(j,5)<lvldn(j) && px(j,3)>lvldn(j));
%     isclose2lvldn = px(j,5)>lvldn(j) && (lvlup(j)-px(j,5))/(lvlup(j)-lvldn(j))>0.9&&lvlup(j)>lvldn(j);
%     if isclose2lvldn
%         comments{i} = 'closetolvldn';
%         idxfractals1_filtered(i,2) = 0;
%         continue
%     end 
    %
    
%     if teethjawcrossed
%         comments{i} = 'teethjawcrossed';
%         idxfractals1_filtered(i,2) = 0;
%         continue;
%     %3.alligator's teeth and jaw are not crossed
%     else
%         if nkbelowteeth == nkfromll
%             if nkfromll == nfractal+2
%                 %TODO:not sure about this for now
%                 if isbreachlvldn && lvldn(j) < lvlup(j)
%                     comments{i}='breachdn-lvldn';
%                 else
%                     if isvolblowup
%                         comments{i} = 'volblowup';
%                     else
%                         idxfractals1_filtered(i,2) = 0;
%                         comments{i} = 'firstcandlebreach';
%                     end
%                 end
%             else
%                 if isbreachlvldn && lvldn(j) < lvlup(j)
%                     comments{i}='breachdn-lvldn';
%                 else
%                     if isvolblowup
%                         comments{i} = 'volblowup';
%                     else
%                         comments{i} = '5morebelowteeth';
%                     end
%                 end
%             end
%         else 
%             if isbreachlvldn && lvldn(j) < lvlup(j)
%                 comments{i}='breachdn-lvldn';
%             else
%                 if isvolblowup
%                     comments{i} = 'volblowup';
%                 else
%                     idxfractals1_filtered(i,2) = 0;
%                     comments{i} = '5lessbelowteeth';
%                 end
%             end
%         end
%         
        
end
end