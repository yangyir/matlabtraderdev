dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\'];
fn_ = 'strat_comdty_daily.mat';
data_ = load([dir_,fn_]);
kellytables = data_.strat_comdty_daily;
%%
fn_ = 'tbl_report_comdty_daily.mat';
data_ = load([dir_,fn_]);
tblreport = data_.tbl_report_comdty_daily;
[~,stats_report_comdty_daily] = kellydistributionreport(tblreport,kellytables);
%%
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
dt1 = getlastbusinessdate;
file1 = ['activefutures_',datestr(dt1,'yyyymmdd'),'.txt'];
futlist1 = cDataFileIO.loadDataFromTxtFile([activefuturesdir,file1]);
nfut = length(futlist1);
resstruct_comdty = cell(nfx,1);
for i = 8:nfut
    if strcmpi(futlist1{i}(1:2),'ZC'),continue;end
    resstruct_comdty{i} = charlotte_plot('futcode',futlist1{i},'frequency','daily','doplot',false);
end
for i = 8:nfut
    if strcmpi(futlist1{i}(1:2),'ZC'),continue;end
    if nfut > 0 && i == 8
        fprintf('comdty daily report......\n');
        fprintf('\t%8s\t%12s\t%10s\t%10s\t%10s\t%10s\n','NAME','DATE','CLOSE','CHG','UPPER','LOWER');
    end
    fprintf('\t%8s\t%12s\t%10s\t%9.1f%%\t%10s\t%10s\n',futlist1{i},...
        datestr(resstruct_comdty{i}.px(end,1),'yyyy-mm-dd'),...
        num2str(resstruct_comdty{i}.px(end,5)),...
        100*(resstruct_comdty{i}.px(end,5)/resstruct_comdty{i}.px(end-1,5)-1),...
        num2str(resstruct_comdty{i}.hh(end)),...
        num2str(resstruct_comdty{i}.ll(end)));
end
%%
uts = cell(nfut,1);
cts = cell(nfut,1);
tbls = cell(nfut,1);
for i = 8:nfx
    if strcmpi(futlist1{i}(1:2),'ZC'),continue;end
    dt1 = irene_findactiveperiod('code',futlist1{i});
    dt2 = datestr(resstruct_fx{i}.px(end,1),'yyyy-mm-dd');
    [uts{i},cts{i},tbls{i}] = charlotte_backtest_period('code',futlist1{i},...
        'fromdate',datestr(dt1,'yyyy-mm-dd'),...
        'todate',dt2,...
        'kellytables',kellytables,'showlogs',false,'figureidx',i+1,'frequency','daily');
    
%     dt1 = datestr(resstruct_fx{i}.px(end-1,1),'yyyy-mm-dd');
    charlotte_backtest_period('code',names_fx{i},...
        'fromdate',dt2,...
        'todate',dt2,...
        'kellytables',kellytables,'showlogs',true,'figureidx',i+1,'frequency','daily','doplot',false);
end
