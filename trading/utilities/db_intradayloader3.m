function [data] = db_intradayloader3(codectp)
    %version3 of db_intradayloader
    %input is a ctp code of futures
    try
        instrument = code2instrument(codectp);
        assetname = instrument.asset_name;
        assetinfo = getassetinfo(assetname);
        path = [getenv('onedrive'),'\matlabdev\',assetinfo.AssetType,'\',lower(assetinfo.WindCode)];
    catch
        instrument = [];
        assetname = [];
        assetinfo = [];
        path = [getenv('onedrive'),'\matlabdev\equity\',lower(codectp)];
    end
    
    try
        cd(path)
    catch
        mkdir(path)
        cd(path)
    end
    
    %1.first try to check whether file exists
    try
        data = load([path,'\',codectp,'.mat']);
        data = data.data;
        dt1 = data(1,1);
    catch
        %file not exist
        %try to find input codectp in asset_ri
        try
            if ~isempty(assetname)
                asset_ri = bkfunc_genfutrollinfo(assetname);
                idx1 = 0;
                for i = 1:size(asset_ri,1)
                    if strcmpi(asset_ri{i,5},codectp)
                        idx1 = i;
                        break
                    end
                end
            else
                asset_ri = {};
                idx1 = 0;
            end
        catch
            asset_ri = {};
            idx1 = 0;
        end
        if idx1 == 0
            if ~isempty(asset_ri)
                disp(asset_ri);
                fprintf('db_intradayloader3: %6s not found in futures roll table:\n',codectp);
            end
            path = [getenv('datapath'),'intradaybar\',codectp,'\'];
            list = dir(path);
            filename = list(length(list)).name;
            idxtemp = strfind(filename,'_');
            dt1 = datenum(list(3).name(idxtemp(1)+1:idxtemp(2)),'yyyymmdd');
        else
            dt1 = dateadd(asset_ri{idx1,6},'-5b');
        end
    end
    
    path = [getenv('datapath'),'intradaybar\',codectp,'\'];
    list = dir(path);
    filename = list(length(list)).name;
    idxtemp = strfind(filename,'_');
    
    dt2 = datenum(list(length(list)).name(idxtemp(1)+1:idxtemp(2)),'yyyymmdd');
    
    db = cLocal;
    if ~isempty(instrument)
        data = db.intradaybar(instrument,...
                    datestr(dt1,'yyyy-mm-dd'),...
                    datestr(dt2,'yyyy-mm-dd'),30,'trade');
    else
        data = db.intradaybar(codectp,...
                    datestr(dt1,'yyyy-mm-dd'),...
                    datestr(dt2,'yyyy-mm-dd'),30,'trade');
    end
    if ~isempty(instrument)
        fn = [getenv('onedrive'),'\matlabdev\',assetinfo.AssetType,...
            '\',lower(assetinfo.WindCode),'\',codectp,'.mat'];
    else
        fn = [getenv('onedrive'),'\matlabdev\equity\',lower(codectp),'\',codectp,'.mat'];
    end
    save(fn,'data');
    fprintf('done with %6s\n',codectp);
end