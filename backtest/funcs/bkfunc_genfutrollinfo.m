function [rollinfo,pxoidata] = bkfunc_genfutrollinfo(assetname)
    bbg = cBloomberg;
    ldb = cLocal;
    lbd = getlastbusinessdate;

    futlist = listcontracts(assetname,'connection','bloomberg');
    expiries = zeros(size(futlist,1),1);
    for i = 1:size(futlist,1)
        code = bbg2ctp(futlist{i});
        instrument = code2instrument(code);
        if isempty(instrument.contract_size)
            savedailybarfrombloomberg(bbg,code,true);
            instrument = code2instrument(code);
            ltd = instrument.last_trade_date1;
            if isempty(ltd)
                continue;
            else
                expiries(i) = ltd;
            end
        else
            ltd = instrument.last_trade_date1;
            expiries(i) = ltd;
            if ltd > lbd
                savedailybarfrombloomberg(bbg,code,true);
            else
                savedailybarfrombloomberg(bbg,code,false);
            end
        end
    end
    
    firstFutIdx = find(expiries>0,1,'first');
    lastFutIdx = find(expiries>lbd,1,'first');
    ncheck = length(expiries)-lastFutIdx+1;
    ois = zeros(ncheck,2);
    for i = 1:ncheck
        code = bbg2ctp(futlist{i+lastFutIdx-1});
        instrument = code2instrument(code);
        ois(i,:) = bbg.history(instrument,'open_int',lbd,lbd);
    end
    maxoi = max(ois(:,end));
    lastFutIdx = find(ois(:,end) == maxoi) + lastFutIdx-1;
    %
    %
    futures = futlist(firstFutIdx:lastFutIdx);
    expiries = expiries(firstFutIdx:lastFutIdx);
    pxoidata = cell(length(futures),1);
    for i = 1:length(futures)
        expiry = expiries(i);
        fromDate = expiry - 365;
        toDate = min(expiry,lbd);
        code = bbg2ctp(futures{i});
%         pxclose = ldb.history(code,'last_trade',fromDate,toDate);
%         openint = ldb.history(code,'open_int',fromDate,toDate);
%         pxoidata{i} = [pxclose,openint(:,end)];
        pxoidata{i} = ldb.history(code,'all',fromDate,toDate);
        %--- some data analysis here to remove the NaNs
        if ~isempty(pxoidata{i})    
            idx = ~isnan(pxoidata{i}(:,2)) & ~isnan(pxoidata{i}(:,3)) & ...
                ~isnan(pxoidata{i}(:,4)) & ~isnan(pxoidata{i}(:,5)) & ...
                ~isnan(pxoidata{i}(:,7));
            pxoidata{i} = pxoidata{i}(idx,:);
        end
    end
    %
    %build continous futures with taking account of rolling futures
    rollinfo = cell(length(futures)-1,6);
    for i = 1:length(futures)-1
        data1 = pxoidata{i};
        data2 = pxoidata{i+1};
        if isempty(data1) || isempty(data2)
            continue
        else
            [t,idx1,idx2] = intersect(data1(:,1),data2(:,1));
            oidiff = [t,data1(idx1,end)-data2(idx2,end)];
            %in case of bad quality data and there is no overlap between
            %contract prices and volume
            if isempty(oidiff)
                continue
            end
            tRoll = find(oidiff(:,end)>0);
            if isempty(tRoll)
                continue
            end
            if tRoll(end) == size(oidiff,1)
                continue
            end
            tRoll = oidiff(tRoll(end)+1,1);
            rollinfo{i,1} = tRoll;
            rollinfo{i,2} = find(data1(:,1) == tRoll);
            rollinfo{i,3} = find(data2(:,1) == tRoll);
            rollinfo{i,4} = bbg2ctp(futures{i});
            rollinfo{i,5} = bbg2ctp(futures{i+1});
            rollinfo{i,6} = datestr(tRoll);
        end    
    end
    %
    %
    res = rollinfo;
    
end