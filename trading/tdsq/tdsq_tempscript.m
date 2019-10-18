idxss = find(ss==9);idxss = [idxss,-1*ones(length(idxss),1)];
idxbs = find(bs==9);idxbs = [idxbs,ones(length(idxbs),1)];
idxall = [idxss;idxbs];
idxsorted = sortrows(idxall);

ns = size(idxsorted);
np = size(p,1);
pshift = 0.05;
for i = 1:ns
    idx_i = idxsorted(i,1);
    if i == 1 && idxsorted(i,2) == -1
        ibar = find(p(idx_i-8:idx_i,3) == max(p(idx_i-8:idx_i,3)),1,'first')+idx_i-9;
        prisk = p(ibar,3);
        ptrigger = p(ibar,4);
        for j = idx_i+1:np
            if p(j,3) > prisk
                prisk = p(j,3);ptrigger = p(j,4);ibar = j;
            end
            flag = tdsq_reverseshort(p(j,:),bs(j),diffvec(j),macdbs(j),ptrigger,pshift);
            if flag
                iopen = j;
                fprintf('iopen:%3d\t',iopen);
                [iclose,closetype] = tdsq_reverseshort_rm(iopen,p,bs,ss,lvlup,lvldn,bc,sc,diffvec,macdbs,macdss,prisk,pshift);
            end
                
        end
    end
    %
    if i == 1 && idxsorted(i,2) == 1
    end
end

