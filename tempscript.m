nchg = size(idxchg,1);
direction2check = -1;
info = cell(nchg,2);
reportpnl = nan(nchg,5);
openidx = [idxchg,idxchg(:,1)];
for i = 3:nchg
    if idxchg(i,2) ~= direction2check,continue;end
    
    j = idxchg(i,1);
    lvlup_j = lvlup(j);
    lvldn_j = lvldn(j);
    
    refs = macdenhanced(j,p,diffvec);
    if ~isnan(lvlup_j) && isnan(lvldn_j)
        type_j = 'singlelvlup';
        isabovelvlup = p(j,5)>lvlup_j;
        breachdnlvlup = ~isabovelvlup&&~isempty(find(refs.range2close>lvlup_j,1,'first'));
    elseif isnan(lvlup_j) && ~isnan(lvldn_j)
        type_j = 'singlelvldn';
        isabovelvldn = p(j,5)>lvldn_j;
        breachdnlvldn = ~isabovelvldn&&~isempty(find(refs.range2close>lvldn_j,1,'first'));
    else
        if lvlup_j > lvldn_j
            type_j = 'doublerange';
            if p(j,5) > lvlup_j
                type_j2 = 'isabove';
                breachdnlvlup = false;
                breachdnlvldn = false;
                if min(refs.range2close) > lvlup_j
                    type_j2 = 'isabove-r';
                end
            elseif p(j,5) < lvldn_j
                type_j2 = 'isbelow';
                breachdnlvlup = ~isempty(find(refs.range2close>lvlup_j,1,'first'));
                breachdnlvldn = ~isempty(find(refs.range2close>lvldn_j,1,'first'));
                if max(refs.range2close) < lvldn_j
                    type_j2 = 'isbelow-r';
                end
            else
                type_j2 = 'isbetween';
                breachdnlvlup = ~isempty(find(refs.range2close>lvlup_j,1,'first'));
                breachdnlvldn = false;
                if max(refs.range2close) <= lvlup_j && min(refs.range2close) >= lvldn_j
                    type_j2 = 'isbetween-r';
                end
            end
        else
            lastbs9 = find(bs(1:j)==9,1,'last');
            lastss9 = find(ss(1:j)==9,1,'last');
            if lastss9 > lastbs9
                type_j = 'doublebullish';
                isabovelvldn = p(j,5)>lvldn_j;
                breachdnlvldn = ~isabovelvldn&&~isempty(find(refs.range2close>lvldn_j,1,'first'));
            else
                type_j = 'doublebearish';
                isabovelvlup = p(j,5)>lvlup_j;
                breachdnlvlup = ~isabovelvlup&&~isempty(find(refs.range2close>lvlup_j,1,'first'));
            end
        end 
    end
    
    info{i,1} = type_j;
    if strcmpi(type_j,'doublerange');
        info{i,1} = [info{i,1},'-',type_j2];
    end
    
    upperbound1 = refs.y1 + refs.k1*refs.x(end);
    lowerbound1 = refs.y2 + refs.k2*refs.x(end);
    upperbound2 = refs.y3 + refs.k3*refs.x(end);
    lowerbound2 = refs.y4 + refs.k4*refs.x(end);
    
    if (upperbound1 - lowerbound1)/lowerbound1 < -1e-3
        %cross at the open
        for k = j+1:np
            if diffvec(k)>0, break;end
            refs_k = macdenhanced(k,p,diffvec);
            upperbound2_k = refs_k.y3 + refs_k.k3*refs_k.x(end);
            lowerbound2_k = refs_k.y4 + refs_k.k4*refs_k.x(end);
            if p(k,5)<lowerbound2_k && bs(k)>2
                info{i,2} = 'adj';
                openidx(i,3) = k;
                break
            end
        end
    else
        if p(j,5) > upperbound1, continue;end
        
        if p(j,5) < lowerbound1
            validcount = validcount+1;
            info{i,2} = 's1';
            if p(j,5) < refs.range2min
                info{i,2} = 's1-strong';
            end
            if p(j,5) > refs.range2min && p(j,5) < refs.range2max-refs.range2maxbarsize
                info{i,2} = 's1-good';
            end   
        else    
            info{i,2} = 's0';
            if strcmpi(type_j,'doublebearish') && p(j,5) < upperbound1
                info{i,2} = 's0-ok';
            %可能还需要加入突破的情况，需要看看实际的行情中有没有这样的情况
            else
                for k = j+1:np
                    if diffvec(k)>0, break;end
                    refs_k = macdenhanced(k,p,diffvec);
                    upperbound2_k = refs_k.y3 + refs_k.k3*refs_k.x(end);
                    lowerbound2_k = refs_k.y4 + refs_k.k4*refs_k.x(end);
%                     if lowerbound2_k>upperbound2_k,break;end
                    if p(k,5)<lowerbound2_k && bs(k)>1
                        info{i,2} = 's0-adj';
                        openidx(i,3) = k;
                        break
                    end
                end
            end
        end  
    end

    for k = openidx(i,3)+1:np
        reportpnl(i,1) = direction2check*(p(k,5)-p(openidx(i,3),5));    
        if k == openidx(i,3)+1
            reportpnl(i,2) = reportpnl(i,1);
            reportpnl(i,3) = reportpnl(i,1);
        else
            if reportpnl(i,1)>reportpnl(i,2),reportpnl(i,2) = reportpnl(i,1);end
            if reportpnl(i,1)<reportpnl(i,3),reportpnl(i,3) = reportpnl(i,1);end
        end
        if direction2check == -1
            if strcmpi(type_j,'singlelvlup')
                if ~breachdnlvlup, breachdnlvlup = p(k,5) < lvlup_j;end
            end
            if strcmpi(type_j,'singlelvldn')
                if ~breachdnlvldn, breachdnlvldn =  p(k,5) < lvldn_j;end
            end
            if strcmpi(type_j,'doublerange')
                if ~breachdnlvlup, breachdnlvlup =  p(k,5) < lvlup_j;end
                if ~breachdnlvldn, breachdnlvldn =  p(k,5) < lvldn_j;end
            end
            
            if strcmpi(type_j,'doublebearish')
                if ~breachdnlvlup, breachdnlvlup =  p(k,5) < lvlup_j;end
            end
            
            if strcmpi(type_j,'doublebullish')
                if ~breachdnlvldn, breachdnlvldn =  p(k,5) < lvldn_j;end
            end
            
            if strcmpi(type_j,'singlelvlup')
                if breachdnlvlup && p(k,5)>lvlup_j
                    reportpnl(i,4) = 4;
                    reportpnl(i,5) = k;
                    break
                end
            elseif strcmpi(type_j,'singlelvldn')
                if breachdnlvldn && p(k,5)>lvldn_j
                    reportpnl(i,4) = 4;
                    reportpnl(i,5) = k;
                    break
                end
            elseif strcmpi(type_j,'doublerange')
                if breachdnlvlup && p(k,5)>lvlup_j
                    reportpnl(i,4) = 4;
                    reportpnl(i,5) = k;
                    break
                end
                if breachdnlvldn && p(k,5)>lvldn_j
                    reportpnl(i,4) = 4;
                    reportpnl(i,5) = k;
                    break
                end
            elseif strcmpi(type_j,'doublebullish')
                if breachdnlvldn && p(k,5)>lvldn_j
                    reportpnl(i,4) = 4;
                    reportpnl(i,5) = k;
                    break
                end
            elseif strcmpi(type_j,'doublebearish')
                if breachdnlvlup && p(k,5)>lvlup_j
                    reportpnl(i,4) = 4;
                    reportpnl(i,5) = k;
                    break
                end
            end
            if diffvec(k)>0,reportpnl(i,4) = 1;reportpnl(i,5) = k;break;end
            if bs(k) >= 24,reportpnl(i,4) = 2;reportpnl(i,5) = k;break;end
            if bc(k) == 13,reportpnl(i,4) = 3;reportpnl(i,5) = k;break;end
        
        end
        
    end
end
