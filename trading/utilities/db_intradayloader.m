function [] = db_intradayloader(assetname)
    switch assetname
        case 'eqindex_300'
            fut1 = 'IF1809';
        case 'eqindex_50'
            fut1 = 'IH1809';
        case 'eqindex_500'
            fut1 = 'IC1809';
        case 'govtbond_10y'
            fut1 = 'T1706';
        case 'gold'
            fut1 = 'au1812';
        case 'silver'
            fut1 = 'ag1712';
        case 'copper'
            fut1 = 'cu1709';
        case 'aluminum'
            fut1 = 'al2001';
        case 'zinc'
            fut1 = 'zn2001';
        case 'nickel'
            error('db_intradayloader:%s not implemented yet!',assetname)
        case 'pta'
            fut1 = 'TA001';
        case 'pp'
            fut1 = 'pp1901';
        case 'methanol'
            fut1 = 'MA001';
        case 'crude oil'
            error('db_intradayloader:%s not implemented yet!',assetname)
        case 'sugar'
            fut1 = 'SR001';
        case 'cotton'
            fut1 = 'CF001';
        case 'corn'
            fut1 = 'c1901';
        case 'soybean oil'
            fut1 = 'y1901';
        case 'soymeal'
            fut1 = 'm1901';
        case 'palm oil'
            fut1 = 'p1901';
        case 'rapeseed oil'
            fut1 = 'OI001';
        case 'rubber'
            fut1 = 'ru1901';
        case 'deformed bar'
            fut1 = 'rb1801';
        case 'iron ore'
            fut1 = 'i1809';
        case 'glass'
            fut1 = 'FG001';
        otherwise
            error('db_intradayloader:%s not supported!',assetname)
    end
           
    [asset_ri,~] = bkfunc_genfutrollinfo(assetname);
    idx1 = 0;
    for i = 1:size(asset_ri,1)
        if strcmpi(asset_ri{i,5},fut1)
            idx1 = i;
            break
        end
    end
    
    assetinfo = getassetinfo(assetname);
    
    path = [getenv('onedrive'),'\matlabdev\',assetinfo.AssetType,'\',lower(assetinfo.WindCode)];
    
    try
        cd(path)
    catch
        mkdir(path)
        cd(path)
    end
    
    try
        data = load([lower(assetinfo.WindCode),'_intraday.mat']);
        newflag = false;
    catch
        newflag = true;
    end
    
    eval([lower(assetinfo.WindCode),'_intraday = cell(size(asset_ri,1)-idx1+1,2);']);
    
    db = cLocal;
    
    if newflag
        for j = 1:size(asset_ri,1)-idx1+1
            eval([lower(assetinfo.WindCode),'_intraday{j,1} = asset_ri{idx1+j-1,5};']);
            dt1 = dateadd(asset_ri{j+i-1,6},'-5b');
            if j < size(asset_ri,1)-idx1+1
                if ~(strcmpi(assetname,'eqindex_300') || strcmpi(assetname,'eqindex_50') || strcmpi(assetname,'eqindex_500'))
                    dt2 = min(getlastbusinessdate,dateadd(asset_ri{j+idx1,6},'5b'));
                else
                    if isempty(asset_ri{j+idx1,6})
                        dt2 = getlastbusinessdate;
                    else
                        dt2 = min(getlastbusinessdate,datenum(asset_ri{j+idx1,6}));
                    end
                end                   
            else
                dt2 = getlastbusinessdate;
            end
            if isempty(asset_ri{idx1+j-1,5}), continue;end
            
            temp = db.intradaybar(code2instrument(asset_ri{idx1+j-1,5}),...
                datestr(dt1,'yyyy-mm-dd'),...
                datestr(dt2,'yyyy-mm-dd'),30,'trade');
            eval([lower(assetinfo.WindCode),'_intraday{j,2} = temp;']);
        end
        save([lower(assetinfo.WindCode),'_intraday'],[lower(assetinfo.WindCode),'_intraday']);
    else
        intraday_old = data.([lower(assetinfo.WindCode),'_intraday']);
        for j = 1:size(intraday_old,1)
            eval([lower(assetinfo.WindCode),'_intraday{j,1} = intraday_old{j,1};']);
            eval([lower(assetinfo.WindCode),'_intraday{j,2} = intraday_old{j,2};']);
        end
        if size(intraday_old,1) <= size(asset_ri,1)-idx1+1
            for j = size(intraday_old,1)-1:size(asset_ri,1)-idx1+1
                eval([lower(assetinfo.WindCode),'_intraday{j,1} = asset_ri{idx1+j-1,5};']);
                dt1 = dateadd(asset_ri{j+i-1,6},'-5b');
                if j < size(asset_ri,1)-idx1+1
                    if ~(strcmpi(assetname,'eqindex_300') || strcmpi(assetname,'eqindex_50') || strcmpi(assetname,'eqindex_500'))
                        dt2 = min(getlastbusinessdate,dateadd(asset_ri{j+idx1,6},'5b'));
                    else
                        if isempty(asset_ri{j+idx1,6})
                            dt2 = getlastbusinessdate;
                        else
                            dt2 = min(getlastbusinessdate,datenum(asset_ri{j+idx1,6}));
                        end
                    end                       
                else
                    dt2 = getlastbusinessdate;
                end
                if isempty(asset_ri{idx1+j-1,5}), continue;end
                temp = db.intradaybar(code2instrument(asset_ri{idx1+j-1,5}),...
                    datestr(dt1,'yyyy-mm-dd'),...
                    datestr(dt2,'yyyy-mm-dd'),30,'trade');
                eval([lower(assetinfo.WindCode),'_intraday{j,2} = temp;']);
            end
        end
        save([lower(assetinfo.WindCode),'_intraday'],[lower(assetinfo.WindCode),'_intraday']);
    end
    
    fprintf('done with %s\n',assetname);
    
end