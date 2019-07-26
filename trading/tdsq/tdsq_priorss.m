function [rangelow,rangehigh,lastidxss2_start,lastidxss2_end] = tdsq_priorss(bs,ss,lvlup,lvldn,bc,sc,p)
    variablenotused(bs);
    variablenotused(lvlup)
    variablenotused(lvldn);
    variablenotused(bc);
    variablenotused(sc);
    
    
    lastidxss = find(ss == 9, 2,'last');
    lastidxss1 = lastidxss(end);
    lastidxss2 = lastidxss(end-1);
    %check the prior TD Sell Setup's true range
    lastidxss2_start = lastidxss2 -8;
    %be aware that the prior TD Sell Setup does not necessarily stop
    %at 9
    lastidxss2_end = lastidxss2;
    for i = lastidxss2_end+1:lastidxss1-9
        if ss(i) == 0
            break
        end
        lastidxss2_end = i;
    end
    
    rangehigh = max(p(lastidxss2_start:lastidxss2_end,3));
    rangelow = min(p(lastidxss2_start:lastidxss2_end,4));

    
end