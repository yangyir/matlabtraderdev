%%
% load table with rolling information of the selected asset
db = cLocal;
ui_assetname = 'copper';
[ret,tbl] = bkfunc_loadrollinfotbl(ui_assetname);
%%
% list futures of interest 
ui_freqs = [1;3;5;15];
ui_futlist = {'cu1709';'cu1710';'cu1711';'cu1712';...
    'cu1801';'cu1802';'cu1803';'cu1804';'cu1805';'cu1806';'cu1807';'cu1808';'cu1809';'cu1810';'cu1811';'cu1812';...
    'cu1901';'cu1902';'cu1903'};
nfut = size(ui_futlist,1);
candles_1m = cell(nfut,2);
candles_3m = cell(nfut,2);
candles_5m = cell(nfut,2);
candles_15m = cell(nfut,2);
for ifut = 1:nfut
    fut = ui_futlist{ifut};
    for j = 1:size(tbl,1)
        if strcmpi(tbl{j,5},fut),break;end
    end
    rolldtnum = tbl{j,1};
    instrument = code2instrument(fut);
    for ifreq = 1:4
        nbshift = wrfreq2busdayshift(ui_freqs(ifreq));
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
end
%%
dir_ = [getenv('BACKTEST'),'copper\'];
for ifreq = 1:4
    if ui_freqs(ifreq) == 1
        fn = [ui_assetname,'_intraday_1m'];
        save([dir_,fn],'candles_1m');
    elseif ui_freqs(ifreq) == 3
        fn = [ui_assetname,'_intraday_3m'];
        save([dir_,fn],'candles_3m');
    elseif ui_freqs(ifreq) == 5
        fn = [ui_assetname,'_intraday_5m'];
        save([dir_,fn],'candles_5m');
    elseif ui_freqs(ifreq) == 15
        fn = [ui_assetname,'_intraday_15m'];
        save([dir_,fn],'candles_15m');
    end
end

