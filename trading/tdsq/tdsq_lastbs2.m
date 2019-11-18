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
    idxtruelow = find(ptemp == rangelow) + lastidxbs_start-1;
    truelowbarsize = p(idxtruelow,3) - p(idxtruelow,4);
    
    low6 = p(lastidxbs-3,4);
    low7 = p(lastidxbs-2,4);
    low8 = p(lastidxbs-1,4);
    low9 = p(lastidxbs,4);
    close8 = p(lastidxbs-1,5);
    close9 = p(lastidxbs,5);
    
    f1 = (low8 < min(low6,low7) || low9 < min(low6,low7));
    
    %scenario 1: only bs9 is available, i.e. no ss9 happened beforehand
    if isnan(lvldn(lastidxbs))
        if f1
            if close9 < close8
                tag = 'perfectbs-scenario1';
            else
                tag = 'semiperfectbs-scenario1';
            end
        else
            tag = 'imperfectbs-scenario1';
        end
        return
    end
    
    %scenario 2:the first bs9 with ss9 happened beforehand
    if isnan(lvlup(lastidxbs_start)) && ~isnan(lvldn(lastidxbs_start))
        lvldn_old = lvldn(lastidxbs_start);
        f2 = isempty(find(p(lastidxbs_start:lastidxbs,5) < lvldn_old,1,'first'));
        if f1 && f2
            if close9 < close8
                tag = 'perfectbs-scenario1';
            else
                tag = 'semiperfectbs-scenario1';
            end
        else
            tag = 'imperfectbs-scenario2';
        end
        return
    end
    
    %scenario3: both bs9 and ss9 happend beforehand
    if ~isnan(lvlup(lastidxbs_start)) && ~isnan(lvldn(lastidxbs_start))
        lvlup_old = lvlup(lastidxbs_start);
        lvldn_old = lvldn(lastidxbs_start);
        if lvlup_old > lvldn_old
            %in case all prices closes above lvlup_old
            f3 = isempty(find(p(lastidxbs_start:lastidxbs,5) < lvlup_old,1,'first'));
            %in case all prices closes below lvldn_old
            f4 = isempty(find(p(lastidxbs_start:lastidxbs,5) > lvldn_old,1,'first'));
            if f3
            elseif f4
            else
                %in case all prices closes above lvldn_old but not lvlup_old
                %in case some prices closes above lvldn_old but some below
            end
            
            
            
        elseif lvlup_old < lvldn_old
            %in case all prices close above lvldn_old
            %in case all prices close above lvlup_old but not lvldn_old
            %in case some prices close above lvlup_old but some below
            %in case all prices close below lvlup_old
            
        end
        
        
        return
    end
    



    variablenotused(ss);
    variablenotused(lvlup);
    variablenotused(bc);
    variablenotused(sc);

    
    
        
        
    
    
    
    %here also need to check whether any bar within the TD Buy Setup
    %has closed below TDST Leveldn
    closedbelow = false;
    for i = lastidxbs-8:lastidxbs
        if isnan(lvldn(i)), continue;end
        if p(i,5) < lvldn(i)
            closedbelow = true;
            break
        end
    end
    
    if  && ~closedbelow
        if close9 < close8
            tag = 'perfectbs';
        else
            tag = 'semiperfectbs';
        end
    else
        tag = 'imperfectbs';
    end
    
    
    
    
    tag = [tag,num2str(bs(lastidxbs_end))];
    
    
end