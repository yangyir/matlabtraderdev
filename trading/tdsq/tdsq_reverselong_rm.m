function [iclose,closetype,pclose] = tdsq_reverselong_rm(iopen,p,bs,ss,lvlup,lvldn,bc,sc,macdvec,macdbs,macdss,prisk,ptrigger,pshift)
    np = size(p,1);
    macdbullish = macdvec(iopen) > 0;
    lvlupnum = lvlup(iopen);
    lvldnnum = lvldn(iopen);
    lvlupbreached = ~isnan(lvlupnum) && p(iopen,5) > lvlupnum;
    lvldnbreached = ~isnan(lvldnnum) && p(iopen,5) > lvldnnum;
    ss9reached = ss(iopen) >= 9;
    
    prisk2 = ptrigger;
    ptrigger2 = prisk;
    
    for i = iopen+1:np
        if ~macdbullish && macdvec(i) > 0, macdbullish = true;end
        if ~lvlupbreached && ~isnan(lvlupnum) && p(i,5) > lvlupnum, lvlupbreached = true;end
        if ~lvldnbreached && ~isnan(lvldnnum) && p(i,5) > lvldnnum, lvldnbreached = true;end
        %case 1:prisk has been breached
        if p(i,4) < prisk
            pclose = min(p(i,2),prisk);
            iclose = i;closetype = 1;break
        end
        %
        %close case 2:macd turned bearish
        if macdbullish && macdvec(i) < 0
            pclose = p(i,5);
            iclose = i;closetype = 2;break
        end
        %
        %
        if ss(i) == 9
            ss9reached = true;
            lvldnnum = lvldn(i);
            lvldnbreached = true;
        end
        %case 3:ss9 reached without breaching lvlup
        if ss9reached && ~lvlupbreached
            pclose = p(i,5);
            iclose = i;closetype = 3;break
        end
        %case 4:ss9 reached with breaching lvldn
        if ss9reached && lvlupbreached && macdss(i) == 0
            pclose = p(i,5);
            iclose = i;closetype = 4;break
        end
        %case 5:lvlup breached but rebounce
        if lvlupbreached && (p(i,3) < lvldnnum || p(i,5) < lvldnnum-pshift)
            pclose = max(lvldnnum-pshift,p(i,5));
            iclose = i;closetype = 5;break
        end
        %case 6:lvlup breached but rebounce
        if lvlupbreached && (p(i,3) < lvlupnum || p(i,5) < lvlupnum-pshift)
            pclose = max(lvlupnum-pshift,p(i,5));
            iclose = i;closetype = 6;break
        end
        %
        if p(i,3) > prisk2
            prisk2 = p(i,3);ptrigger2 = p(i,4);
        end
        if (p(i,5) <= ptrigger2 || p(i,2) <= ptrigger2 - pshift) && ...
                (bs(i) >= 3 && macdbs(i) >= 3)
            pclose = max(p(i,5),ptrigger2-pshift);
            iclose = i;closetype = 7;break
        end
    end
    
    
    
end