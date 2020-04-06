
i=1;
iopen = idx2check(i);
[~,rl,~,~,~,~,barwidth,] = tdsq_lastbs2(bs(1:iopen),ss(1:iopen),lvlup(1:iopen),lvldn(1:iopen),bc(1:iopen),sc(1:iopen),p(1:iopen,:));
risklvl = rl-barwidth;
stopdistance = p(iopen,5)-risklvl;
dynamicopen = p(iopen,5);
for k = iopen+1:size(p,1)
    if p(k,4) < risklvl
        closemsg = 'risklvl reached!';
        if p(k,2) < risklvl
            pnl = p(k,2)-p(iopen,5);
        else
            pnl = risklvl-p(iopen,5);
        end
        break
    end
    if p(k,5)-dynamicopen > 0.3*stopdistance
        dynamicopen = floor((dynamicopen+0.3*stopdistance)/0.005)*0.005;
        risklvl = ceil((risklvl+0.3*stopdistance)/0.005)*0.005;
    end    
end
res = [p(iopen,5),risklvl,pnl,iopen,k];
open res

tdsq_plot2(p,idx2check(i)-8,min(k+30,size(p,1)),code2instrument(codes{ifut}));