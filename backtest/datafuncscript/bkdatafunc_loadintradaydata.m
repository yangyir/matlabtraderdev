function ret = bkdatafunc_loadintradaydata(varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('AssetName','',@ischar);
    p.addParameter('RollTable',{},@iscell);
    p.addParameter('FirstFutures','',@ischar);
    p.parse(varargin{:});
    assetname = p.Results.AssetName;
    tbl = p.Results.RollTable;
    firstfut = p.Results.FirstFutures;
    
    istart = -1;
    for i = 1:size(tbl,1)
        if strcmpi(tbl{i,5},firstfut)
            istart = i;
            break
        end
    end
    if istart == -1
        fprintf('bkdatafunc_loadintradaydata:invalid input of firstfutures\n');
        ret = 0;
        return
    end
    
    ui_futlist = tbl(istart:end,5);
    ui_freqs = [1;3;5;15];
    nfut = size(ui_futlist,1);
    nfreq = size(ui_freqs,1);
    candles_1m = cell(nfut,2);
    candles_3m = cell(nfut,2);
    candles_5m = cell(nfut,2);
    candles_15m = cell(nfut,2);
    bkdir = [getenv('BACKTEST'),assetname,'\'];
    db = cLocal;
    % note: we dont want to download the data repeatly as it takes a
    % lot of time. thus, we simply check whether the data is updated
    % for each futures of interest
    for ifreq = 1:nfreq
        bkfn = [assetname,'_intraday_',num2str(ui_freqs(ifreq)),'m'];
        fldn = ['candles_',num2str(ui_freqs(ifreq)),'m'];
        try
            dataondisk = load([bkdir,bkfn]);
        catch
            dataondisk = {};
        end

        nbshift = wrfreq2busdayshift(ui_freqs(ifreq));

        if isempty(dataondisk)
            for ifut = 1:nfut
                fut = ui_futlist{ifut};
                for j = 1:size(tbl,1)
                    if strcmpi(tbl{j,5},fut),break;end
                end
                rolldtnum = tbl{j,1};
                instrument = code2instrument(fut);

                dt1 = dateadd(rolldtnum,['-',num2str(nbshift),'b']);
                dt1 = datestr(dt1,'yyyy-mm-dd');
                if j ~= size(tbl,1)
                    dt2 = datestr(tbl{j+1,1},'yyyy-mm-dd');
                else
                    dt2 = datestr(getlastbusinessdate,'yyyy-mm-dd');
                end

                data = db.intradaybar(instrument,dt1,dt2,ui_freqs(ifreq),'trade');
                
                if ui_freqs(ifreq) == 1
                    candles_1m{ifut,1} = fut;
                    candles_1m{ifut,2} = data;
                elseif ui_freqs(ifreq) == 3
                    candles_3m{ifut,1} = fut;
                    candles_3m{ifut,2} = data;
                elseif ui_freqs(ifreq) == 5
                    candles_5m{ifut,1} = fut;
                    candles_5m{ifut,2} = data;
                elseif ui_freqs(ifreq) == 15
                    candles_15m{ifut,1} = fut;
                    candles_15m{ifut,2} = data;
                end
            end
        else
            lastactfut = tbl{end,5};
            candles = dataondisk.(fldn);
            for ifut = 1:nfut
                fut = ui_futlist{ifut};
                foundflag = 0;
                for j = 1:size(candles,1)
                    if strcmpi(candles{j,1},fut)
                        foundflag = 1;
                        break;
                    end
                end
                if ~foundflag
                    for j = 1:size(tbl,1)
                        if strcmpi(tbl{j,5},fut),break;end
                    end
                    rolldtnum = tbl{j,1};
                    instrument = code2instrument(fut);

                    dt1 = dateadd(rolldtnum,['-',num2str(nbshift),'b']);
                    dt1 = datestr(dt1,'yyyy-mm-dd');
                    if j ~= size(tbl,1)
                        dt2 = datestr(tbl{j+1,1},'yyyy-mm-dd');
                    else
                        dt2 = datestr(getlastbusinessdate,'yyyy-mm-dd');
                    end

                    data = db.intradaybar(instrument,dt1,dt2,ui_freqs(ifreq),'trade');
                    newentry = {fut,data};
                    temp = [candles;newentry];
                    candles = temp;
                else
                    if strcmpi(fut,lastactfut)
                        for j = 1:size(tbl,1)
                            if strcmpi(tbl{j,5},fut),break;end
                        end
                        rolldtnum = tbl{j,1};
                        instrument = code2instrument(fut);

                        dt1 = dateadd(rolldtnum,['-',num2str(nbshift),'b']);
                        dt1 = datestr(dt1,'yyyy-mm-dd');
                        if j ~= size(tbl,1)
                            dt2 = datestr(tbl{j+1,1},'yyyy-mm-dd');
                        else
                            dt2 = datestr(getlastbusinessdate,'yyyy-mm-dd');
                        end

                        data = db.intradaybar(instrument,dt1,dt2,ui_freqs(ifreq),'trade');
                        candles{ifut,1} = fut;
                        candles{ifut,2} = data;
                    end
                end
            end
            if ui_freqs(ifreq) == 1
                candles_1m = candles;
            elseif ui_freqs(ifreq) == 3
                candles_3m = candles;
            elseif ui_freqs(ifreq) == 5
                candles_5m = candles;
            elseif ui_freqs(ifreq) == 15
                candles_15m = candles;
            end
        end
    end
    %
    for ifreq = 1:4
        if ui_freqs(ifreq) == 1
            fn = [assetname,'_intraday_1m'];
            save([bkdir,fn],'candles_1m');
        elseif ui_freqs(ifreq) == 3
            fn = [assetname,'_intraday_3m'];
            save([bkdir,fn],'candles_3m');
        elseif ui_freqs(ifreq) == 5
            fn = [assetname,'_intraday_5m'];
            save([bkdir,fn],'candles_5m');
        elseif ui_freqs(ifreq) == 15
            fn = [assetname,'_intraday_15m'];
            save([bkdir,fn],'candles_15m');
        end
    end
    ret = 1;
end











