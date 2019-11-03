% only works on MACD turning points
clc;
np = size(p,1);
nchg = size(idxchg,1);
for i = 1:nchg
    j = idxchg(i,1);
    if j < 47, continue;end
    lvlup_i = lvlup(j);
    lvldn_i = lvldn(j);
%     if isnan(lvlup_i) && isnan(lvldn_i)
%         scen = 1;
%     elseif isnan(lvlup_i) && ~isnan(lvldn_i)
%         scen = 2;
%     elseif ~isnan(lvlup_i) && isnan(lvldn_i)
%         scen = 3;
%     else
%         scen = 4;
%     end
    
    if idxchg(i,2) == 1
%         for k = j:np
%             if diffvec(k) < 0, break;end
%             refs = macdenhanced(k,p);
%             upperbound1 = refs.y1 + refs.k1*refs.x(end);
%             lowerbound1 = refs.y2 + refs.k2*refs.x(end);
%             upperbound2 = refs.y3 + refs.k3*refs.x(end);
%             lowerbound2 = refs.y4 + refs.k4*refs.x(end);
%             
%             if isempty(upperbound1) && isempty(upperbound2)
%                 continue;
%             elseif ~isempty(upperbound1) && isempty(upperbound2)
%                 %at the turning point
%                 %if the upperbound1 and lowerbound1 crossed before the MACD
%                 %turning point, we will not use upperbound1 here as we
%                 %believe it is not valid anymore
%                 if upperbound1 < lowerbound1, continue;end
%                 
%                 if p(k,5) > upperbound1
%                     fprintf('buy at %d\n',k);
%                     break
%                 else
%                     %if the price is below upperbound1 but it either
%                     %breached lvldn or lvlup
%                     %breach lvldn?
%                     if ~isnan(lvldn_i) && refs.range2max > lvldn_i && refs.range2min < lvldn_i && p(k,5) > lvldn_i && p(k,5) > lowerbound1
%                         fprintf('buy at %d\n',k);
%                         break
%                     end
%                     %breach lvlup?
%                     if ~isnan(lvlup_i) && refs.range2max > lvlup_i && refs.range2min < lvlup_i && p(k,5) > lvlup_i && p(k,5) > lowerbound1
%                         fprintf('buy at %d\n',k);
%                         break
%                     end
%                 end
%             elseif isempty(upperbound1) && ~isempty(upperbound2)
%                 %very rare case and shall be ignored in realtime trading
%                 if p(k,5) > upperbound2 && upperbound2 > lowerbound2
%                     fprintf('buy at %d\n',k);
%                     break
%                 end
%             else
%                 if upperbound1 < lowerbound1
%                     %in case upperbound1 and lowerbound1 crossed before
%                     %this time point, we will use upperbound2 instead but
%                     %we would also make sure that upperbound2 is not
%                     %crossed with lowerbound2
%                     if p(k,5) > upperbound2 && upperbound2 > lowerbound2
%                         fprintf('buy at %d\n',k);
%                         break
%                     end
%                 else
%                     %if upperbound1 and lowerbound1 is not crossed, we need
%                     %to make sure that price is above upperbound1 and 
%                     if p(k,5) > upperbound1 && p(k,5) > min(lowerbound2,upperbound2)
%                         fprintf('buy at %d\n',k);
%                         break
%                     end
%                 end
%             end 
%         end
        %
        %
    elseif idxchg(i,2) == -1
        for k = j:np
            if diffvec(k) > 0, break;end
            refs = macdenhanced(k,p);
            upperbound1 = refs.y1 + refs.k1*refs.x(end);
            lowerbound1 = refs.y2 + refs.k2*refs.x(end);
            upperbound2 = refs.y3 + refs.k3*refs.x(end);
            lowerbound2 = refs.y4 + refs.k4*refs.x(end);
            
            if isempty(lowerbound1) && isempty(lowerbound2)
                continue;
            elseif ~isempty(lowerbound1) && isempty(lowerbound2)
                %at the turning point
                %if the upperbound1 and lowerbound1 crossed before the MACD
                %turning point, we will not use upperbound1 here as we
                %believe it is not valid anymore
                if upperbound1 < lowerbound1, continue;end
                
                if p(k,5) < lowerbound1
                    fprintf('short at %d\n',k);
                    break
                else
                end
                
            elseif isempty(lowerbound1) && ~isempty(lowerbound2)
                %very rare case and shall be ignored in realtime trading
                if p(k,5) < lowerbound2 && lowerbound2 < upperbound2
                    fprintf('short at %d\n',k);
                    break
                end
            else
                if upperbound1 < lowerbound1
                    %in case upperbound1 and lowerbound1 crossed before
                    %this time point, we will use lowerbound2 instead but
                    %we would also make sure that upperbound2 is not
                    %crossed with lowerbound2
                    if p(k,5) < lowerbound2 && lowerbound2 < upperbound2
                        fprintf('short at %d\n',k);
                        break
                    end
                else
                    %if upperbound1 and lowerbound1 is not crossed, we meed
                    %to make sure that price is below lowerbound1 and
                    if p(k,5) < lowerbound1 && p(k,5) < max(lowerbound2,upperbound2)
                        fprintf('short at %d\n',k);
                        break
                    end
                end
            end
            
        end
        
    end
    
end