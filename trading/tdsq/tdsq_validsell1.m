function [ flag ] = tdsq_validsell1( p,bs,ss,lvlup,lvldn,macdvec,sigvec )
%TDSQ_VALIDSELL1 Summary of this function goes here
%   Detailed explanation goes here
    diffvec = macdvec - sigvec;
    flag = false;
    if diffvec(end) > 0, return; end
    
    if bs(end) == 9
        low6 = p(end-3,4);
        low7 = p(end-2,4);
        low8 = p(end-1,4);
        low9 = p(end,4);
        close8 = p(end-1,5);
        close9 = p(end,5);
        f1 = (low8 < min(low6,low7) || low9 < min(low6,low7)) && close9 < close8;
        if f1
            return
        end
    end
    
    np = size(p,1);
    refs = macdenhanced(np,p,diffvec);
    upperbound1 = refs.y1 + refs.k1*refs.x(end);
    lowerbound1 = refs.y2 + refs.k2*refs.x(end);
    upperbound2 = refs.y3 + refs.k3*refs.x(end);
    lowerbound2 = refs.y4 + refs.k4*refs.x(end);

    if isempty(lowerbound1) && isempty(lowerbound2), return;end
    
    if ~isempty(lowerbound1) && isempty(lowerbound2)
        %at the turning point,i.e. the last diffvec just turn positive
        if upperbound1 < lowerbound1
            if p(end,5) < min(upperbound1,lowerbound1) && p(end,5) < refs.range2max-refs.range2maxbarsize && bs(end)>1
                flag = true;
                return
            else
                return
            end
        end
        
        if p(end,5) < lowerbound1
            lvldnlast = lvldn(end);
            lvluplast = lvlup(end);
            %breach lvldn?
            if ~isnan(lvldnlast) && refs.range2max>lvldnlast && p(end,5)<lvldnlast&&p(end,5)<upperbound1
                flag = true;
                return
            end
            %breach lvlup?
            if ~isnan(lvluplast) && refs.range2max>lvluplast && p(end,5)<lvluplast&&p(end,5)<upperbound1
                flag = true;
                return
            end
            %after a full sell-setup and there is no buy-setup
            %between
            lastbs = find(bs>=9,1,'last');
            lastss = find(ss>=9,1,'last');
            if isempty(lastbs), lastbs = -1;end
            if isempty(lastss), lastss = -1;end
            if lastss > lastbs && np-lastss <= 2
                flag = true;
                return
            end
            %otherwise we need to make sure bs is greater than 1
            if bs(end)>1
                flag = true;
                return
            end
        else
            lvldnlast = lvldn(end);
            lvluplast = lvlup(end);
            %breach lvldn?
            if ~isnan(lvldnlast) && refs.range2max>lvldnlast && p(end,5)<lvldnlast&&p(end,5)<upperbound1
                flag = true;
                return
            end
            %breach lvlup?
            if ~isnan(lvluplast) && refs.range2max>lvluplast && p(end,5)<lvluplast&&p(end,5)<upperbound1
                flag = true;
                return
            end
        end
        return
    end
    %
    if isempty(lowerbound1) && ~isempty(lowerbound2)
        %very rare case
        if p(end,5) < lowerbound2 && upperbound2 > lowerbound2
            flag = true;
            return
        end
        return
    end
    %
    if ~isempty(lowerbound1) && ~isempty(lowerbound2)
        %open conditions are not satified at the turning point
        if upperbound1 < lowerbound1
            if p(end,5) < lowerbound2 && upperbound2 > lowerbound2 && bs(end)>1
                flag = true;
                return
            end
            %special case 1
            if p(end,5) < lvldn(end) && p(end,5) < refs.range3min && p(end,5) < max(lowerbound2,upperbound2) && bs(end) >1
                flag = true;
                return
            end
            %special case 2
            if p(end,5) < upperbound2 && upperbound2 > lowerbound2 && ss(end) == 9 && p(end) < min(upperbound1,lowerbound1)
                flag = true;
                return
            end
        else
            lvluplast = lvlup(end);
            lvldnlast = lvldn(end);
            if ~isnan(lvluplast) && refs.range2max>lvluplast && p(end,5)<lvluplast && p(end,5)<lowerbound2
                flag = true;
                return
            end
            %double-bullish
            if lvluplast < lvldnlast && ~isnan(lvluplast) && ~isnan(lvldnlast)
                if p(end,5)<lvldnlast && refs.range2max>lvldnlast
                    if p(end,5)<lowerbound2
                        flag = true;
                        return
                    else
                        if p(end,5)<lvluplast
                            flag = true;
                            return
                        end
                    end
                end
            end
%             %
%             if p(end,5) < lowerbound1 && p(end,5) < max(lowerbound2,upperbound2) && bs(end)>1
%                 flag = true;
%                 return
%             end
            %
            if p(end,5) < lowerbound1 && p(end,5) < lowerbound2 && lowerbound2 <upperbound2 && bs(end)>1
                flag = true;
                return
            end
            
        end
        return
    end
    
end

