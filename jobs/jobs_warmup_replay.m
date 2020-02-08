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
    try
        p_hist_daily{i} = cDataFileIO.loadDataFromTxtFile([futlist{i},'_daily.txt']);
    catch e
        fprintf('%s\n',e.message);
    end
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
%%
dailyret = zeros(nfut,2);
for i = 1:nfut
    hd = p_hist_daily{i};
    dailyret(i,2) = i;
    dailyret(i,1) = hd(end,5)/hd(end-1,5)-1;
end
dailyretsorted = sortrows(dailyret);