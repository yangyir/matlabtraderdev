%%
icheck = 160;
tdsq_plotopensignal(icheck,p,bs,ss,lvlup,lvldn,bc,sc,diffvec,1);
tdsq_plot2(p,icheck,min(icheck+35,np),lf);

%%
%breach up lvldn given lvldn is available
fprintf('\n');
tolerance = 1e4;
i=2;
while i <= np
    if isnan(lvldn(i-1)) && isnan(lvlup(i-1)), i=i+1;continue;end
    f1 = ~isnan(lvldn(i-1))&&p(i,5)>lvldn(i-1)&&p(i-1,5)<lvldn(i-1);
    if f1
        refs = macdenhanced(i,p,diffvec);
        if diffvec(i)<0
            risklvl = refs.range3min-refs.range3minbarsize;
        else
            risklvl = refs.range2min-refs.range2minbarsize;
        end
        %note:test is required for this
        stopdistance = p(i,5)-risklvl;
        if diffvec(i)>0
            usedtolerance = 1.5*tolerance;
        else
            usedtolerance = tolerance;
        end
            
        stopdistance = min(stopdistance,floor(quantile(p(:,3)-p(:,4),0.975)/lf.tick_size)*lf.tick_size);
        risklvl = p(i,5)-stopdistance;
        nlots = floor(usedtolerance/(stopdistance/lf.tick_size*lf.tick_value));
        dynamicopen = p(i,5);
        for j = i+1:np
            if p(j,4)<risklvl,break;end
            if p(j,5)-p(i,5)>stopdistance/2
                risklvl = risklvl + stopdistance/2;
                dynamicopen = dynamicopen+stopdistance/2;
            end
        end
        pnl = (risklvl-p(i,5))/lf.tick_size*lf.tick_value*nlots;
        fprintf('breachup lvldn open at %3d with ss %2d and close at %3d and pnl %s\n',i,ss(i),j,num2str(pnl));
        i=j;
    end
    %
    f2 = ~isnan(lvlup(i-1))&&p(i,5)>lvlup(i-1)&&p(i-1,5)<lvlup(i-1)&&(diffvec(i)>0 || macdss(i)>=3);
    
    if f2
       risklvl = p(i,4);
       %note:test is required for this
       stopdistance = p(i,5)-risklvl;
       if diffvec(i)>0
           usedtolerance = 1.5*tolerance;
       else
           usedtolerance = tolerance;
       end
       
       stopdistance = min(stopdistance,floor(quantile(p(:,3)-p(:,4),0.975)/lf.tick_size)*lf.tick_size);
       risklvl = p(i,5)-stopdistance;
       nlots = floor(usedtolerance/(stopdistance/lf.tick_size*lf.tick_value));
       dynamicopen = p(i,5);
       for j = i+1:np
           if p(j,4)<risklvl,break;end
           if p(j,5)-p(i,5)>stopdistance/2
               risklvl = risklvl + stopdistance/2;
               dynamicopen = dynamicopen+stopdistance/2;
           end
       end
       pnl = (risklvl-p(i,5))/lf.tick_size*lf.tick_value*nlots;
       fprintf('breachup lvlup open at %3d with ss %2d and close at %3d and pnl %s\n',i,ss(i),j,num2str(pnl));
       i=j;
    end
    
    i=i+1;
end