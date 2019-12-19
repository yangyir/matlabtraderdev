%
% this script shall be run around 8:30am
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
    if strcmpi(f.break_interval{end,end},'01:00:00') || strcmpi(f.break_interval{end,end},'02:30:00')
        dt2 = [datestr(lastbd+1,'yyyy-mm-dd'),' ',f.break_interval{end,end}];
    else
        dt2 = [datestr(lastbd,'yyyy-mm-dd'),' ',f.break_interval{end,end}];
    end
    if strcmpi(f.asset_name,'crude oil'), continue;end
    if strcmpi(f.exchange,'.CFE')
        dt1 = datestr(lastbd-30,'yyyy-mm-dd');
    else
        dt1 = datestr(lastbd-20,'yyyy-mm-dd');
    end
    p_hist_intraday{i} = db.intradaybar(f,dt1,dt2,30,'trade');
end
