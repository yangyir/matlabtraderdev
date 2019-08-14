function [tag,rangelow,rangehigh,lastidxbs_start,lastidxbs_end,idxtruelow,truelowbarsize] = tdsq_lastbs(bs,ss,lvlup,lvldn,bc,sc,p)
    variablenotused(ss);
    variablenotused(lvlup);
    variablenotused(bc);
    variablenotused(sc);

    lastidxbs = find(bs == 9, 1,'last');
    low6 = p(lastidxbs-3,4);
    low7 = p(lastidxbs-2,4);
    low8 = p(lastidxbs-1,4);
    low9 = p(lastidxbs,4);
    close8 = p(lastidxbs-1,5);
    close9 = p(lastidxbs,5);
    
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
    
    if (low8 < min(low6,low7) || low9 < min(low6,low7)) && ~closedbelow
        if close9 < close8
            tag = 'perfectbs';
        else
            tag = 'semiperfectbs';
        end
    else
        tag = 'imperfectbs';
    end
    
    lastidxbs_start = lastidxbs - 8;
    lastidxbs_end = lastidxbs;
    %note:the TD Buy Setup doesnot necessarliy stop at 9 and it can
    %continue to any number beyond 9
    %we might run this function in the process of developing a TD Buy Setup
    %or we might run this funnction after its completion
    for i = lastidxbs_end+1:size(bs,1)
        if bs(i) == 0
            break
        end
        lastidxbs_end = i;
    end
    
    tag = [tag,num2str(bs(lastidxbs_end))];
    rangehigh = max(p(lastidxbs_start:lastidxbs_end,3));
    rangelow = min(p(lastidxbs_start:lastidxbs_end,4));
    
    ptemp = p(lastidxbs_start:lastidxbs_end,4);
    idxtruelow = find(ptemp == rangelow) + lastidxbs_start-1;
    truelowbarsize = p(idxtruelow,3) - p(idxtruelow,4);
    
end