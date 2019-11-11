function [ flag ] = tdsq_validbuy1( p,bs,ss,lvlup,lvldn,macdvec,sigvec )
%TDSQ_VALIDBUY1 Summary of this function goes here
%   Detailed explanation goes here
    diffvec = macdvec - sigvec;
    flag = false;
    if diffvec(end) < 0, return; end
    
    np = size(p,1);
    refs = macdenhanced(np,p,diffvec);
    upperbound1 = refs.y1 + refs.k1*refs.x(end);
    lowerbound1 = refs.y2 + refs.k2*refs.x(end);
    upperbound2 = refs.y3 + refs.k3*refs.x(end);
    lowerbound2 = refs.y4 + refs.k4*refs.x(end);

    if isempty(upperbound1) && isempty(upperbound2), return;end
    
    if ~isempty(upperbound1) && isempty(upperbound2)
        %at the turning point,i.e. the last diffvec just turn positive
        if upperbound1 < lowerbound1
            if p(end,5) > max(upperbound1,lowerbound1) && p(end,5) > refs.range2min+refs.range2minbarsize && ss(end)>1
                flag = true;
                return
            else
                return
            end
        end
        
        if p(end,5) > upperbound1
            lvldnlast = lvldn(end);
            lvluplast = lvlup(end);
            %breach lvldn?
            if ~isnan(lvldnlast) && refs.range2min<lvldnlast && p(end,5)>lvldnlast&&p(end,5)>lowerbound1
                flag = true;
                return
            end
            %breach lvlup?
            if ~isnan(lvluplast) && refs.range2min<lvluplast && p(end,5)>lvluplast&&p(end,5)>lowerbound1
                flag = true;
                return
            end
            %after a full buy-setup and there is no buy-setup
            %between
            lastbs = find(bs>=9,1,'last');
            lastss = find(ss>=9,1,'last');
            if isempty(lastbs), lastbs = -1;end
            if isempty(lastss), lastss = -1;end
            if lastbs > lastss && np-lastbs <= 2
                flag = true;
                return
            end
            %otherwise we need to make sure ss is greater than 1
            if ss(end)>1
                flag = true;
                return
            end
        else
            lvldnlast = lvldn(end);
            lvluplast = lvlup(end);
            %breach lvldn?
            if ~isnan(lvldnlast) && refs.range2min<lvldnlast && p(end,5)>lvldnlast&&p(end,5)>lowerbound1
                flag = true;
                return
            end
            %breach lvlup?
            if ~isnan(lvluplast) && refs.range2min<lvluplast && p(end,5)>lvluplast&&p(end,5)>lowerbound1
                flag = true;
                return
            end
        end
        return
    end
    %
    if isempty(upperbound1) && ~isempty(upperbound2)
        %very rare case
        if p(end,5) > upperbound2 && upperbound2 > lowerbound2
            flag = true;
            return
        end
        return
    end
    %
    if ~isempty(upperbound1) && ~isempty(upperbound2)
        %open conditions are not satified at the turning point
        if upperbound1 < lowerbound1
            if p(end,5) > upperbound2 && upperbound2 > lowerbound2 && ss(end)>1
                flag = true;
                return
            end
            %special case 1
            if p(end,5) > lvlup(end) && p(end,5) > refs.range3max && p(end,5) > min(upperbound2,lowerbound2) && ss(end) >1
                flag = true;
                return
            end
            %special case 2
            if p(end,5) > lowerbound2 && upperbound2 > lowerbound2 && bs(end) == 9 && p(end,5) > max(upperbound1,lowerbound1)
                flag = true;
                return
            end
        else
            if p(end,5) > upperbound1 && p(end,5) > min(lowerbound2,upperbound2) && ss(end)>1
                flag = true;
                return
            end
        end
        return
    end
    
end

