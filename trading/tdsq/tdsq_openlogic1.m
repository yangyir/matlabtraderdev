% only works on MACD turning points
clc;
np = size(p,1);
%note:
%in tdsq_openlogic1:we will open a long position if and only if macd is
%positive and also we will open a short position if and only if macd is
%negative
nchg = size(idxchg,1);
for i = 1:nchg
    j = idxchg(i,1);
    if j < 47, continue;end
    lvlup_i = lvlup(j);
    lvldn_i = lvldn(j);
    
    if idxchg(i,2) == 1
        for k = j:np
            if diffvec(k) < 0, break;end
            refs = macdenhanced(k,p);
            upperbound1 = refs.y1 + refs.k1*refs.x(end);
            lowerbound1 = refs.y2 + refs.k2*refs.x(end);
            upperbound2 = refs.y3 + refs.k3*refs.x(end);
            lowerbound2 = refs.y4 + refs.k4*refs.x(end);
            
            if isempty(upperbound1) && isempty(upperbound2)
                continue;
            elseif ~isempty(upperbound1) && isempty(upperbound2)
                %at the turning point
                %if the upperbound1 and lowerbound1 crossed before the MACD
                %turning point, we will not use upperbound1 here as we
                %believe it is not valid anymore
                if upperbound1 < lowerbound1, continue;end
                
                if p(k,5) > upperbound1
                    %breach lvldn?
                    if ~isnan(lvldn_i) && refs.range2min < lvldn_i && p(k,5) > lvldn_i && p(k,5) > lowerbound1
                        fprintf('B at %4d with ss %2d:breach up lvldn\n',k,ss(k));
                        break
                    end
                    %breach lvlup?
                    if ~isnan(lvlup_i) && refs.range2min < lvlup_i && p(k,5) > lvlup_i && p(k,5) > lowerbound1
                        fprintf('B at %4d with ss %2d:breach up lvlup\n',k,ss(k));
                        break
                    end
                    %after a full buy-setup and there is no buy-setup
                    %between
                    lastbs = find(bs(1:k) >=9,1,'last');
                    lastss = find(ss(1:k) >=9,1,'last');
                    if isempty(lastbs), lastbs = -1;end
                    if isempty(lastss), lastss = -1;end
                    if lastbs > lastss && k-lastbs <= 2
                        fprintf('B at %4d with ss %2d:td buysetup\n',k,ss(k));
                        break
                    end
                    %otherwise we need to make sure ss is greater than 1
                    if ss(k) > 1
                        fprintf('B at %4d with ss %2d\n',k,ss(k));
                        break
                    end
                else
                    %if the price is below upperbound1 but it either
                    %breached lvldn or lvlup
                    %breach lvldn?
                    if ~isnan(lvldn_i) && refs.range2min < lvldn_i && p(k,5) > lvldn_i && p(k,5) > lowerbound1
                        fprintf('B at %4d with ss %2d:breach up lvldn\n',k,ss(k));
                        break
                    end
                    %breach lvlup?
                    if ~isnan(lvlup_i) && refs.range2min < lvlup_i && p(k,5) > lvlup_i && p(k,5) > lowerbound1
                        fprintf('B at %4d with ss %2d:breach up lvlup\n',k,ss(k));
                        break
                    end
                end
            elseif isempty(upperbound1) && ~isempty(upperbound2)
                %very rare case and shall be ignored in realtime trading
                if p(k,5) > upperbound2 && upperbound2 > lowerbound2
                    fprintf('B at %4d with ss %2d:rare case\n',k,ss(k));
                    break
                end
            else
                %open conditions are not satisfied 
                if upperbound1 < lowerbound1
                    %in case upperbound1 and lowerbound1 crossed before
                    %this time point, we will use upperbound2 instead but
                    %we would also make sure that upperbound2 is not
                    %crossed with lowerbound2
                    if p(k,5) > upperbound2 && upperbound2 > lowerbound2 && ss(k)>1
                        fprintf('B at %4d with ss %2d\n',k,ss(k));
                        break
                    end
                else
                    %if upperbound1 and lowerbound1 is not crossed, we need
                    %to make sure that price is above upperbound1 and 
                    if p(k,5) > upperbound1 && p(k,5) > min(lowerbound2,upperbound2) && ss(k)>1
                        fprintf('B at %4d with ss %2d\n',k,ss(k));
                        break
                    end
                end
            end 
        end
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
                    %breach lvldn?
                    if ~isnan(lvldn_i) && refs.range2max > lvldn_i && p(k,5) < lvldn_i && p(k,5) < upperbound1
                        fprintf('S at %4d with ss %2d:breach down lvldn\n',k,bs(k));
                        break
                    end
                    %breach lvlup?
                    if ~isnan(lvlup_i) && refs.range2max > lvlup_i && p(k,5) < lvlup_i && p(k,5) < upperbound1
                        fprintf('S at %4d with ss %2d:breach down lvlup\n',k,ss(k));
                        break
                    end
                    %after a full sell-setup and there is no buy-setup
                    %between
                    lastss = find(ss(1:k) >= 9,1,'last');
                    lastbs = find(bs(1:k) >= 9,1,'last');
                    if isempty(lastss), lastss = -1;end
                    if isempty(lastbs), lastbs = -1;end
                    if lastss > lastbs && k - lastss <= 2
                        fprintf('S at %4d with bs %2d:td sellsetup\n',k,bs(k));
                        break
                    end
                    %otherwise we meed to make sure bs is greater than 1
                    if bs(k) > 1
                        fprintf('S at %4d with bs %2d\n',k,bs(k));
                        break
                    end
                else
                    %if the price is above lowerbound1 but it either
                    %breached lvldn or lvlup
                    if ~isnan(lvldn_i) && refs.range2max > lvldn_i && p(k,5) < lvldn_i && p(k,5) < upperbound1
                        fprintf('S at %4d with ss %2d:breach down lvldn\n',k,bs(k));
                        break
                    end
                    %breach lvlup?
                    if ~isnan(lvlup_i) && refs.range2max > lvlup_i && p(k,5) < lvlup_i && p(k,5) < upperbound1
                        fprintf('S at %4d with ss %2d:breach down lvlup\n',k,ss(k));
                        break
                    end
                end
                
            elseif isempty(lowerbound1) && ~isempty(lowerbound2)
                %very rare case and shall be ignored in realtime trading
                if p(k,5) < lowerbound2 && lowerbound2 < upperbound2
                    fprintf('S at %4d with bs %2d:rare case\n',k,bs(k));
                    break
                end
            else
                if upperbound1 < lowerbound1
                    %in case upperbound1 and lowerbound1 crossed before
                    %this time point, we will use lowerbound2 instead but
                    %we would also make sure that upperbound2 is not
                    %crossed with lowerbound2
                    if p(k,5) < lowerbound2 && lowerbound2 < upperbound2 && bs(k)>1
                        fprintf('S at %4d with bs %2d\n',k,bs(k));
                        break
                    end
                else
                    %if upperbound1 and lowerbound1 is not crossed, we meed
                    %to make sure that price is below lowerbound1 and
                    if p(k,5) < lowerbound1 && p(k,5) < max(lowerbound2,upperbound2) && bs(k)>1
                        fprintf('S at %4d with bs %2d\n',k,bs(k));
                        break
                    end
                end
            end
            
        end
    end
    
end
%%
% we need to do some stats of the trades above in order to maximing the pnl
% per risk management requirement
% todo: