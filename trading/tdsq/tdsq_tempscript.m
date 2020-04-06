idxss = find(ss==9);idxss = [idxss,-1*ones(length(idxss),1)];
idxbs = find(bs==9);idxbs = [idxbs,ones(length(idxbs),1)];
idxall = [idxss;idxbs];
idxsorted = sortrows(idxall);

ns = size(idxsorted);
np = size(p,1);
pshift = 0.05;
i = 1;
while i <= ns
    idx_i = idxsorted(i,1);
    if i == 1 && idxsorted(i,2) == -1
        %第一个SETUP是SELL SETUP
        ibar = find(p(idx_i-8:idx_i,3) == max(p(idx_i-8:idx_i,3)),1,'first')+idx_i-9;
        prisk = p(ibar,3);
        ptrigger = p(ibar,4);
        j = idx_i+1;
        while j <= np
            if p(j,3) > prisk
                prisk = p(j,3);ibar = j;ptrigger = p(j,4);
            end
            %注释：此处应该除了reverseshort还应该有个followlong
            flag = tdsq_reverseshort(p(j,:),bs(j),diffvec(j),macdbs(j),ptrigger,pshift);
            if flag
                iopen = j;
                fprintf('iopen(-1):%3d\t',iopen);
                [iclose,closetype,pclose] = tdsq_reverseshort_rm(iopen,p,bs,ss,lvlup,lvldn,bc,sc,diffvec,macdbs,macdss,prisk,pshift);
                fprintf('iclose:%3d\t',iclose);
                fprintf('closetype:%d\n',closetype);
                j = iclose;
                if pclose < p(iopen,5)
                    prisk = p(iclose,3);ibar = iclose;ptrigger = p(iclose,4);
                end
            else
                j = j+1;
            end
            lastidxbs = find(bs(idx_i+1:j) == 9,1,'first');
            if ~isempty(lastidxbs)
                i = find(idxsorted(:,1) == lastidxbs+idx_i);
                break
            end
        end
    end
    %
    if i == 1 && idxsorted(i,2) == 1
        
        
    end
    %
    if i > 1 && idxsorted(i,2) == 1
        %第一个SETUP是BUY SETUP
        idx_i = j;
        prisk = p(ibar,4);ptrigger = p(ibar,3);
        while j <= np
            if p(j,4) < prisk
                prisk = p(j,4);ibar = j;ptrigger = p(j,3);
            end
            flag = tdsq_reverselong(p(j,:),ss(j),diffvec(j),macdss(j),ptrigger,pshift);
            if flag
                iopen = j;
                fprintf('iopen(+1):%3d\t',iopen);
                [iclose,closetype,pclose] = tdsq_reverselong_rm(iopen,p,bs,ss,lvlup,lvldn,bc,sc,diffvec,macdbs,macdss,prisk,ptrigger,pshift);
                fprintf('iclose:%3d\t',iclose);
                fprintf('closetype:%d\n',closetype);
                j = iclose;
                if pclose > p(iopen,5)
                    prisk = p(iclose,4);ibar = iclose;ptrigger = p(iclose,3);
                end
            else
                j = j+1;
            end
        end
    end
    i = i + 1;
end
