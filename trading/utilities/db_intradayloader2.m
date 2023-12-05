function [] = db_intradayloader2(assetname,datein)
    idx = -1;
    assetlist = getassetmaptable;
    for i = 1:length(assetlist)
        if strcmpi(assetname,assetlist{i})
            idx = i;
            break
        end
    end
    
    if nargin < 2, datein = getlastbusinessdate; end
    
    if idx == -1, error('db_intradayloader2:invalid asset input');end
    
    activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
    filename = ['activefutures_',datestr(datein,'yyyymmdd'),'.txt'];
    activefutures = cDataFileIO.loadDataFromTxtFile([activefuturesdir,filename]);
    code = activefutures{idx};
    assetinfo = getassetinfo(assetname);
    shortcode = lower(assetinfo.WindCode);
    fn = [getenv('onedrive'),'\matlabdev\',assetinfo.AssetType,...
        '\',shortcode,'\',shortcode,'_intraday.mat'];
    path = [getenv('onedrive'),'\matlabdev\',assetinfo.AssetType,'\',shortcode];
    cd(path);
    
    try
        data = load(fn);
    catch
        eval([shortcode,'_intraday = cell(1,2);']);
        dt1 = datein-31;
        db = cLocal;
        temp = db.intradaybar(code2instrument(code),...
                datestr(dt1,'yyyy-mm-dd'),...
                datestr(datein,'yyyy-mm-dd'),30,'trade');
        eval([shortcode,'_intraday{1,1} = code;']);    
        eval([shortcode,'_intraday{1,2} = temp;']);
        variablenotused(temp);
        save([shortcode,'_intraday'],[shortcode,'_intraday']);
%         error('db_intradayloader2:data not stored in .m format for asset: %2s',shortcode);
    end
            
    intraday_old = data.([shortcode,'_intraday']);
    eval([shortcode,'_intraday = cell(size(intraday_old,1),2);']);
    
    idx = -1;
    for i = 1:size(intraday_old,1)
        if strcmpi(intraday_old{i,1},code)
            p = intraday_old{i,2};
            db = cLocal;
            temp = db.intradaybar(code2instrument(code),...
                datestr(p(1,1),'yyyy-mm-dd'),...
                datestr(datein,'yyyy-mm-dd'),30,'trade');
            eval([shortcode,'_intraday{i,2} = temp;']);
            eval([shortcode,'_intraday{i,1} = intraday_old{i,1};']);
            idx = i;
            variablenotused(temp);
        else
            eval([shortcode,'_intraday{i,1} = intraday_old{i,1};']);
            eval([shortcode,'_intraday{i,2} = intraday_old{i,2};']);
        end
    end
    
    if idx > 0
        %code found in old file
        save([shortcode,'_intraday'],[shortcode,'_intraday']);
        fprintf('db_intradayloader2 done for %6s\n',code);
    else
        %code not found in old file
        eval([shortcode,'_intraday = cell(size(intraday_old,1)+1,2);']);
        for i = 1:size(intraday_old,1)
            eval([shortcode,'_intraday{i,1} = intraday_old{i,1};']);
            eval([shortcode,'_intraday{i,2} = intraday_old{i,2};']);
        end
        dt1 = datein-31;
        db = cLocal;
        temp = db.intradaybar(code2instrument(code),...
                datestr(dt1,'yyyy-mm-dd'),...
                datestr(datein,'yyyy-mm-dd'),30,'trade');
        eval([shortcode,'_intraday{end,1} = code;']);    
        eval([shortcode,'_intraday{end,2} = temp;']);
        save([shortcode,'_intraday'],[shortcode,'_intraday']);
%         error('db_intradayloader2:%s not found in existing file!\n', code);
        variablenotused(temp);
    end
end
