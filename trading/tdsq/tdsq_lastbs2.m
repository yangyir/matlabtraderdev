function [tag,rangelow,rangehigh,lastidxbs_start,lastidxbs_end,idxtruelow,truelowbarsize,lastbsval] = tdsq_lastbs2(bs,ss,lvlup,lvldn,bc,sc,p)
    tag = 'blank';
    rangelow = [];
    rangehigh = [];
    lastidxbs_start = [];
    lastidxbs_end = [];
    idxtruelow = [];
    truelowbarsize = [];
    lastbsval = [];
    
    lastidxbs = find(bs == 9, 1,'last');
    
    %scenario 0:bs9 is not available
    if isempty(lastidxbs), return;end
    
    lastidxbs_start = lastidxbs - 8;
    lastidxbs_end = lastidxbs;
    %note:the TD Buy Setup doesnot necessarliy stop at 9 and it can
    %continue to any number beyond 9
    %we might run this function in the process of developing a TD Buy Setup
    %or we might run this funnction after its completion
    for i = lastidxbs_end:size(bs,1)
        if bs(i) == 0, break;end
        lastidxbs_end = i;
    end
    
    lastbsval = bs(lastidxbs_end);
    
    rangehigh = max(p(lastidxbs_start:lastidxbs_end,3));
    rangelow = min(p(lastidxbs_start:lastidxbs_end,4));
    ptemp = p(lastidxbs_start:lastidxbs_end,4);
    idxtruelow = find(ptemp == rangelow,1,'last') + lastidxbs_start-1;
    truelowbarsize = p(idxtruelow,3) - p(idxtruelow,4);
    
    low6 = p(lastidxbs-3,4);
    low7 = p(lastidxbs-2,4);
    low8 = p(lastidxbs-1,4);
    low9 = p(lastidxbs,4);
    close8 = p(lastidxbs-1,5);
    close9 = p(lastidxbs,5);
    
    f1 = (low8 < min(low6,low7) || low9 < min(low6,low7));
    if f1
        if close9 < close8
            prefix = 'perfectbs';
        else
            prefix = 'semiperfectbs';
        end
    else
        prefix = 'imperfectbs';
    end
    
    lastidxss = find(ss==9,1,'last');
    %scenario 1: only bs9 is available, i.e. no ss9 happened beforehand
    if isempty(lastidxss)
        tag = [prefix,'-singlelvlup'];
        return
    end
    
    %scenario 2:the first bs9 with ss9 happened beforehand
    if isnan(lvlup(lastidxbs_start)) && ~isempty(lastidxss)
        lvldn_old = lvldn(lastidxbs_start);
        isallabove = isempty(find(p(lastidxbs_start:lastidxbs,5) < lvldn_old,1,'first'));
        isallbelow = isempty(find(p(lastidxbs_start:lastidxbs,5) > lvldn_old,1,'first'));
        if isallabove
            %might form a doublerange afterwards
            tag = [prefix,'-singlelvldn-a'];
        elseif isallbelow
            %might (given the highest price) form a doublebearish afterwards
            tag = [prefix,'-singlelvldn-c'];
        else
            %might form a doublerange
            tag = [prefix,'-singlelvldn-b'];
        end
        return;
    end
    
    %scenario3: both bs9 and ss9 happend beforehand
    if ~isnan(lvlup(lastidxbs_start)) && ~isnan(lvldn(lastidxbs_start))
        lvlup_old = lvlup(lastidxbs_start);
        lvldn_old = lvldn(lastidxbs_start);
        if lvlup_old > lvldn_old
            %in case all prices closes above lvlup_old
            isallabovelvlup = isempty(find(p(lastidxbs_start:lastidxbs,5) < lvlup_old,1,'first'));
            %in case all prices closes below lvldn_old
            isallbelowlvldn = isempty(find(p(lastidxbs_start:lastidxbs,5) > lvldn_old,1,'first'));
            if isallabovelvlup
                %still form a doublerange afterwards but with lvlup lifted
                tag = [prefix,'-doublerange-a'];
            elseif isallbelowlvldn
                %might (given the highest price) form a doublebearish afterwards 
                tag = [prefix,'-doublerange-d'];
            else
                %note the new lvlup might be lifted or moved lower and
                %shall be double check to summarize how this affect the
                %trading performance
                isallabovelvlup = isempty(find(p(lastidxbs_start:lastidxbs,5) < lvldn_old,1,'first'));
                if ~(isallabovelvlup || isallbelowlvldn) && isallabovelvlup    
                    tag = [prefix,'-doublerange-b'];
                else
                    tag = [prefix,'-doublerange-c'];
                end
            end
            %
        elseif lvlup_old < lvldn_old
            preidxbs = find(bs(1:lastidxbs_start) == 9,1,'last');
            if preidxbs > lastidxss
                tag = [prefix,'-doublebearish-'];
            else
                tag = [prefix,'-doublebullish-'];
            end
            
            %in case all prices close above lvldn_old
            isallabovelvldn = isempty(find(p(lastidxbs_start:lastidxbs,5) < lvldn_old,1,'first'));
            %in case all prices close below lvlup_old
            isallbelowlvlup = isempty(find(p(lastidxbs_start:lastidxbs,5) > lvlup_old,1,'first'));
            if isallabovelvldn
                %form a doublerange afterwards
                tag = [tag,'a'];
            elseif isallbelowlvlup
                %still doublebearish afterwards and very bearish
                tag = [tag,'d'];
            else
                %note:the new lvlup is lifted but it might be still below
                %lvldn and shall be check to summarize how this affect the
                %trading performance
                isallabovelvlup = isempty(find(p(lastidxbs_start:lastidxbs,5) < lvlup_old,1,'first'));
                if ~(isallabovelvldn || isallbelowlvlup) && isallabovelvlup 
                    tag = [tag,'b'];
                else
                    tag = [tag,'c'];
                end
            end
        end
        return
    end
    
    variablenotused(bc);
    variablenotused(sc);
    
end