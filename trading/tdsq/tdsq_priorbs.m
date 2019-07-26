function [rangelow,rangehigh,lastidxbs2_start,lastidxbs2_end] = tdsq_priorbs(bs,ss,lvlup,lvldn,bc,sc,p)
    variablenotused(ss);
    variablenotused(lvlup)
    variablenotused(lvldn);
    variablenotused(bc);
    variablenotused(sc);
    
    
    lastidxbs = find(bs == 9, 2,'last');
    lastidxbs1 = lastidxbs(end);
    lastidxbs2 = lastidxbs(end-1);
    %check the prior TD Buy Setup's true range
    lastidxbs2_start = lastidxbs2 -8;
    %be aware that the prior TD Buy Setup does not necessarily stop
    %at 9
    lastidxbs2_end = lastidxbs2;
    for i = lastidxbs2_end+1:lastidxbs1-9
        if bs(i) == 0
            break
        end
        lastidxbs2_end = i;
    end
    
    rangehigh = max(p(lastidxbs2_start:lastidxbs2_end,3));
    rangelow = min(p(lastidxbs2_start:lastidxbs2_end,4));

    
end