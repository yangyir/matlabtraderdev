function [tag,rangelow,rangehigh,lastidxss_start,lastidxss_end] = tdsq_lastss(bs,ss,lvlup,lvldn,bc,sc,p)
    variablenotused(bs);
    variablenotused(lvldn);
    variablenotused(bc);
    variablenotused(sc);

    lastidxss = find(ss == 9, 1,'last');
    high6 = p(lastidxss-3,3);
    high7 = p(lastidxss-2,3);
    high8 = p(lastidxss-1,3);
    high9 = p(lastidxss,3);
    close8 = p(lastidxss-1,5);
    close9 = p(lastidxss,5);
    
    %here also need to check whether any bar within the TD Sell Setup
    %has closed above TDST Levelup
    closedabove = false;
    for i = lastidxss-8:lastidxss
        if isnan(lvlup(i)), continue;end
        if p(i,5) > lvlup(i)
            closedabove = true;
            break
        end
    end
    
    if (high8 > max(high6,high7) || high9 > max(high6,high7)) && ~closedabove
        if close9 > close8
            tag = 'perfectss';
        else
            tag = 'semiperfectss';
        end
    else
        tag = 'imperfectss';
    end
    
    lastidxss_start = lastidxss - 8;
    lastidxss_end = lastidxss;
    %note:the TD Sell Setup doesnot necessarliy stop at 9 and it can
    %continue to any number beyond 9
    %we might run this function in the process of developing a TD Sell Setup
    %or we might run this funnction after its completion
    for i = lastidxss_end+1:size(ss,1)
        if ss(i) == 0
            break
        end
        lastidxss_end = i;
    end
    
    tag = [tag,num2str(ss(lastidxss_end))];
    
    rangehigh = max(p(lastidxss_start:lastidxss_end,3));
    rangelow = min(p(lastidxss_start:lastidxss_end,4));
    
end