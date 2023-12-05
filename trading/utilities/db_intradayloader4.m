function [data] = db_intradayloader4(code,freq)
    %version4 of db_intradayloader
    %input is code for equity/fund of CHINESE stock market only
    %20231205:now we extend to futures
    
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
    
    if nargin < 2
        freq = 30;
    end
    
    %1.first try to check whether file exists
    if freq == 30
        fn = [path,'\',code,'.mat'];
    else
        fn = [path,'\',code,'_',num2str(freq),'m.mat'];
    end
    try
        data = load(fn); 
        data = data.data;
        dt1 = data(1,1);
        dt_end = data(end,1);
    catch
        %file not exist
        %try to find input codectp in asset_ri
        path = [getenv('datapath'),'intradaybar\',code,'\'];
        list = dir(path);
        filename = list(length(list)).name;
        idxtemp = strfind(filename,'_');
        dt1 = datenum(list(3).name(idxtemp(1)+1:idxtemp(2)),'yyyymmdd');
        dt_end = [];
    end
    
    path = [getenv('datapath'),'intradaybar\',code,'\'];
    list = dir(path);
    filename = list(length(list)).name;
    idxtemp = strfind(filename,'_');
    dt2 = datenum(list(length(list)).name(idxtemp(1)+1:idxtemp(2)),'yyyymmdd');
    
    db = cLocal;
    
    if isempty(dt_end)
        %file not exist
        data = db.intradaybar(code,...
            datestr(dt1,'yyyy-mm-dd'),...
            datestr(dt2,'yyyy-mm-dd'),freq,'trade');
    else
        dt1_ = dateadd(floor(dt_end),'1b');
        if dt1_ <= dt2
            data_ = db.intradaybar(code,...
                datestr(dt1_,'yyyy-mm-dd'),...
                datestr(dt2,'yyyy-mm-dd'),freq,'trade');
            data = [data;data_];
        else
            fprintf('db_intradayloader4:done with %6s\n',code);
            return
        end
    end
    
    save(fn,'data');
    fprintf('db_intradayloader4:done with %6s\n',code);
end