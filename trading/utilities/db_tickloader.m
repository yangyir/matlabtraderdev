function [data] = db_tickloader(code)
    
    instrument = code2instrument(code);
    if isa(instrument,'cFutures')
        assetname = instrument.asset_name;
        assetinfo = getassetinfo(assetname);
        path = [getenv('onedrive'),'\matlabdev\',assetinfo.AssetType,'\',lower(assetinfo.WindCode)];
    elseif isa(instrument,'cFX')
        path = [getenv('onedrive'),'\matlabdev\fx\',lower(code)];
    elseif isa(instrument,'cStock')
        path = [getenv('onedrive'),'\matlabdev\equity\',lower(code)];
    end
    
    try
        cd(path)
    catch
        mkdir(path)
        cd(path)
    end
    
    fn = [path,'\',code,'_tick.mat'];
    
    try
        data = load(fn);
        data = data.data;
        dt1 = data(1,1);
        dt_end = data(end,1);
    catch
        path = [getenv('datapath'),'ticks\',code,'\'];
        list = dir(path);
        filename = list(length(list)).name;
        idxtemp = strfind(filename,'_');
        dt1 = datenum(list(3).name(idxtemp(1)+1:idxtemp(2)),'yyyymmdd');
        dt_end = [];
    end
    
    path = [getenv('datapath'),'ticks\',code,'\'];
    list = dir(path);
    filename = list(length(list)).name;
    idxtemp = strfind(filename,'_');
    dt2 = datenum(list(length(list)).name(idxtemp(1)+1:idxtemp(2)),'yyyymmdd');
    
    db = cLocal;
    if isempty(dt_end)
        data = db.tickdata(instrument,datestr(dt1,'yyyy-mm-dd'),...
            datestr(dt2,'yyyy-mm-dd'));
    else
        dt1_ = dateadd(floor(dt_end),'1b');
        
        if dt1_ <= dt2
            data_ = db.tickdata(instrument,datestr(dt1_,'yyyy-mm-dd'),...
                datestr(dt2,'yyyy-mm-dd'));
            data = [data;data_];
        else
            fprintf('db_tickloader:done with %6s\n',code);
            return
        end
    end
    
    save(fn,'data');
    fprintf('db_tickloader:done with %6s\n',code);
end