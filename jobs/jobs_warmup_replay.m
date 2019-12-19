%
% this script shall be run after 15:15 pm
% 
db = cLocal;
lastbd = getlastbusinessdate;
fn = ['activefutures_',datestr(lastbd,'yyyymmdd'),'.txt'];
futlist = cDataFileIO.loadDataFromTxtFile(fn);
%%
nfut = length(futlist);
p_hist_intraday = cell(nfut,1);
p_hist_daily = cell(nfut,1);
for i = 1:nfut
    p_hist_daily{i} = cDataFileIO.loadDataFromTxtFile([futlist{i},'_daily.txt']);
    f = code2instrument(futlist{i});
    dt2 = datestr(lastbd,'yyyy-mm-dd');
    if strcmpi(f.asset_name,'crude oil'), continue;end
    if strcmpi(f.exchange,'.CFE')
        dt1 = datestr(lastbd-30,'yyyy-mm-dd');
    else
        dt1 = datestr(lastbd-20,'yyyy-mm-dd');
    end
    p_hist_intraday{i} = db.intradaybar(f,dt1,dt2,30,'trade');
end
