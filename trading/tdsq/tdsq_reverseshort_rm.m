function [iclose,closetype,pclose] = tdsq_reverseshort_rm(iopen,p,bs,ss,lvlup,lvldn,bc,sc,macdvec,macdbs,macdss,prisk,pshift)
    np = size(p,1);
    macdbearish = macdvec(iopen) < 0;
    lvlupnum = lvlup(iopen);
    lvldnnum = lvldn(iopen);
    lvlupbreached = ~isnan(lvlupnum) && p(iopen,5) < lvlupnum;
    lvldnbreached = ~isnan(lvldnnum) && p(iopen,5) < lvldnnum;
    bs9reached = bs(iopen) >= 9;
    
    for i = iopen+1:np
        if ~macdbearish && macdvec(i) < 0, macdbearish = true;end
        if ~lvlupbreached && ~isnan(lvlupnum) && p(i,5) < lvlupnum, lvlupbreached = true;end
        if ~lvldnbreached && ~isnan(lvldnnum) && p(i,5) < lvldnnum, lvldnbreached = true;end
        %case 1:prisk has been breached
        if p(i,3) > prisk
            pclose = max(p(i,2),prisk);
            iclose = i;closetype = 1;break
        end
        %
        %close case 2:macd turned bullish
        if macdbearish && macdvec(i) > 0
            pclose = p(i,5);
            iclose = i;closetype = 2;break
        end
        %
        %
        if bs(i) == 9
            bs9reached = true;
            lvlupnum = lvlup(i);
            lvlupbreached = true;
        end
        %case 3:bs9 reached without breaching lvldn
        if bs9reached && ~lvldnbreached
            pclose = p(i,5);
            iclose = i;closetype = 3;break
        end
        %case 4:bs9 reached with breaching lvldn
        if bs9reached && lvldnbreached && macdbs(i) == 0
            pclose = p(i,5);
            iclose = i;closetype = 4;break
        end
        %case 5:lvldn breached but rebounce
        if lvldnbreached && (p(i,4) > lvldnnum || p(i,5) > lvldnnum+pshift)
            pclose = min(lvldnnum+pshift,p(i,5));
            iclose = i;closetype = 5;break
        end
        %case 6:lvlup breached but rebounce
        if lvlupbreached && (p(i,4) > lvlupnum || p(i,5) > lvlupnum+pshift)
            pclose = min(lvlupnum+pshift,p(i,5));
            iclose = i;closetype = 6;break
        end
            
        
    end
    
    
    
end