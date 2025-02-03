foldername = [getenv('onedrive'),'\matlabdev\govtbond\'];
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\'];
shortcodes = {'tf';'t';'tl'};
codes_govtbondfut_tf = cell(1000,1);
codes_govtbondfut_t = cell(1000,1);
codes_govtbondfut_tl = cell(1000,1);

%
ncodes = 0;
foldername_tf = [foldername,shortcodes{1}];
listing_tf = dir(foldername_tf);
for j = 3:size(listing_tf,1)
    fn_j = listing_tf(j).name;
    if isempty(strfind(fn_j,'_'))
        ncodes = ncodes + 1;
        codes_govtbondfut_tf{ncodes,1} = fn_j(1:end-4);
    end
end
codes_govtbondfut_tf = codes_govtbondfut_tf(1:ncodes,:);
%
ncodes = 0;
foldername_t = [foldername,shortcodes{2}];
listing_t = dir(foldername_t);
for j = 3:size(listing_t,1)
    fn_j = listing_t(j).name;
    if isempty(strfind(fn_j,'_'))
        ncodes = ncodes + 1;
        codes_govtbondfut_t{ncodes,1} = fn_j(1:end-4);
    end
end
codes_govtbondfut_t = codes_govtbondfut_t(1:ncodes,:);
%
ncodes = 0;
foldername_tl = [foldername,shortcodes{3}];
listing_tl = dir(foldername_tl);
for j = 3:size(listing_tl,1)
    fn_j = listing_tl(j).name;
    if isempty(strfind(fn_j,'_'))
        ncodes = ncodes + 1;
        codes_govtbondfut_tl{ncodes,1} = fn_j(1:end-4);
    end
end
codes_govtbondfut_tl = codes_govtbondfut_tl(1:ncodes,:);
%
ntl = size(codes_govtbondfut_tl,1);
%%
output_govtbondfut_30m = fractal_kelly_summary('codes',codes_govtbondfut_tl,...
    'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_govtbondfut_30m,~,~,~,~,strat_govtbondfut_30m] = kellydistributionsummary(output_govtbondfut_30m,'useactiveonly',true);
%
[tblreport_govtbondfut_30m,statsreport_govtbondfut_30m] = kellydistributionreport(tbl_govtbondfut_30m,strat_govtbondfut_30m);
save([dir_,'strat_govtbondfut_30m.mat'],'strat_govtbondfut_30m');
save([dir_,'tblreport_govtbondfut_30m.mat'],'tblreport_govtbondfut_30m');
fprintf('file of 30m-govtbond saved...\n');
%%
% codes_govtbondfut_t_latest = {'T2312';'T2403';'T2406';'T2409';'T2412';'T2503'};
output_govtbondfut_5m = fractal_kelly_summary('codes',codes_govtbondfut_tl,...
    'frequency','intraday-5m','usefractalupdate',0,'usefibonacci',1,'direction','both');

[~,~,tbl_govtbondfut_5m,~,~,~,~,strat_govtbondfut_5m] = kellydistributionsummary(output_govtbondfut_5m,'useactiveonly',true);
%
[tblreport_govtbondfut_5m,statsreport_govtbondfut_5m] = kellydistributionreport(tbl_govtbondfut_5m,strat_govtbondfut_5m);
%
%compare with existing ones
strat_govtbondfut_5m_existing = load([dir_,'strat_govtbondfut_5m.mat']);
strat_govtbondfut_5m_existing = strat_govtbondfut_5m_existing.strat_govtbondfut_5m;
charlotte_strat_compare('strat1',strat_govtbondfut_5m_existing,'strat2',strat_govtbondfut_5m,'assetname','govtbond_30y');
%compare pnl profiles
tbl2check_5m = cell(ntl,1);
tbl2check_5m_existing = cell(ntl,1);
for i = 1:ntl
    [dt1,dt2] = irene_findactiveperiod('code',codes_govtbondfut_tl{i});
    dt1 = datestr(dt1,'yyyy-mm-dd');
    dt2 = datestr(dt2,'yyyy-mm-dd');
    [~,~,tbl2check_5m{i}] = charlotte_backtest_period('code',codes_govtbondfut_tl{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_govtbondfut_5m,'showlogs',false,'figureidx',4,'frequency','5m');
    [~,~,tbl2check_5m_existing{i}] = charlotte_backtest_period('code',codes_govtbondfut_tl{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_govtbondfut_5m_existing,'showlogs',false,'figureidx',4,'frequency','5m');
end
tbl2check_5m_all = tbl2check_5m{1};
tbl2check_5m_existing_all = tbl2check_5m_existing{1};
for i = 2:ntl
    temp_5m = [tbl2check_5m_all;tbl2check_5m{i}];
    tbl2check_5m_all = temp_5m;
    temp_5m_existing = [tbl2check_5m_existing_all;tbl2check_5m_existing{i}];
    tbl2check_5m_existing_all = temp_5m_existing;
end
[tblpnl_5m,~,statsout_5m] = irene_trades2dailypnl('tradestable',tbl2check_5m_all,'frequency','5m');
[tblpnl_5m_existing,~,statsout_5m_existing] = irene_trades2dailypnl('tradestable',tbl2check_5m_existing_all,'frequency','5m');
figure(10);
plot(tblpnl_5m_existing.runningnotional,'b-');
hold on;
plot(tblpnl_5m.runningnotional,'r-');
legend('exiting-5m','new-5m');hold off;

% save([dir_,'strat_govtbondfut_5m.mat'],'strat_govtbondfut_5m');
% save([dir_,'tblreport_govtbondfut_5m.mat'],'tblreport_govtbondfut_5m');
% fprintf('file of 5m-govtbond saved...\n');
%%
output_govtbondfut_15m = fractal_kelly_summary('codes',codes_govtbondfut_tl,...
    'frequency','intraday-15m','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_govtbondfut_15m,~,~,~,~,strat_govtbondfut_15m] = kellydistributionsummary(output_govtbondfut_15m,'useactiveonly',true);
%
[tblreport_govtbondfut_15m,statsreport_govtbondfut_15m] = kellydistributionreport(tbl_govtbondfut_15m,strat_govtbondfut_15m);
%
%compare with existing ones
strat_govtbondfut_15m_existing = load([dir_,'strat_govtbondfut_15m.mat']);
strat_govtbondfut_15m_existing = strat_govtbondfut_15m_existing.strat_govtbondfut_15m;
charlotte_strat_compare('strat1',strat_govtbondfut_15m_existing,'strat2',strat_govtbondfut_15m,'assetname','govtbond_30y');
%compare pnl profiles
tbl2check_15m = cell(ntl,1);
tbl2check_15m_existing = cell(ntl,1);
for i = 1:ntl
    [dt1,dt2] = irene_findactiveperiod('code',codes_govtbondfut_tl{i});
    dt1 = datestr(dt1,'yyyy-mm-dd');
    dt2 = datestr(dt2,'yyyy-mm-dd');
    [~,~,tbl2check_15m{i}] = charlotte_backtest_period('code',codes_govtbondfut_tl{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_govtbondfut_15m,'showlogs',false,'figureidx',4,'frequency','15m');
    [~,~,tbl2check_15m_existing{i}] = charlotte_backtest_period('code',codes_govtbondfut_tl{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_govtbondfut_15m_existing,'showlogs',false,'figureidx',4,'frequency','15m');
end
tbl2check_15m_all = tbl2check_15m{1};
tbl2check_15m_existing_all = tbl2check_15m_existing{1};
for i = 2:ntl
    temp_15m = [tbl2check_15m_all;tbl2check_15m{i}];
    tbl2check_15m_all = temp_15m;
    temp_15m_existing = [tbl2check_15m_existing_all;tbl2check_15m_existing{i}];
    tbl2check_15m_existing_all = temp_15m_existing;
end
[tblpnl_15m,~,statsout_15m] = irene_trades2dailypnl('tradestable',tbl2check_15m_all,'frequency','15m');
[tblpnl_15m_existing,~,statsout_15m_existing] = irene_trades2dailypnl('tradestable',tbl2check_15m_existing_all,'frequency','15m');
figure(11);
plot(tblpnl_15m_existing.runningnotional,'b-');
hold on;
plot(tblpnl_15m.runningnotional,'r-');
legend('exiting-15m','new-15m');hold off;
% save([dir_,'strat_govtbondfut_15m.mat'],'strat_govtbondfut_15m');
% save([dir_,'tblreport_govtbondfut_15m.mat'],'tblreport_govtbondfut_15m');
% fprintf('file 15m-govtbond saved...\n');
%%

tbl2check_15m = cell(ntl,1);
tbl2check_30m = cell(ntl,1);
for i = 1:ntl
    [dt1,dt2] = irene_findactiveperiod('code',codes_govtbondfut_tl{i});
    dt1 = datestr(dt1,'yyyy-mm-dd');
    dt2 = datestr(dt2,'yyyy-mm-dd');
    
    [~,~,tbl2check_15m{i}] = charlotte_backtest_period('code',codes_govtbondfut_tl{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_govtbondfut_15m,'showlogs',false,'figureidx',5,'frequency','15m');
    [~,~,tbl2check_30m{i}] = charlotte_backtest_period('code',codes_govtbondfut_tl{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_govtbondfut_30m,'showlogs',false,'figureidx',6,'frequency','30m');
end
%%
% tbl2check_5m_all = tbl2check_5m{1};
tbl2check_15m_all = tbl2check_15m{1};
tbl2check_30m_all = tbl2check_30m{1};
for i = 2:ntl
%     temp_5m = [tbl2check_5m_all;tbl2check_5m{i}];
%     tbl2check_5m_all = temp_5m;
    temp_15m = [tbl2check_15m_all;tbl2check_15m{i}];
    tbl2check_15m_all = temp_15m;
    temp_30m = [tbl2check_30m_all;tbl2check_30m{i}];
    tbl2check_30m_all = temp_30m;
end
%
[tblpnl_5m,~,statsout_5m] = irene_trades2dailypnl('tradestable',tbl2check_5m_all,'frequency','5m');
[tblpnl_15m,~,statsout_15m] = irene_trades2dailypnl('tradestable',tbl2check_15m_all,'frequency','15m');
[tblpnl_30m,~,statsout_30m] = irene_trades2dailypnl('tradestable',tbl2check_30m_all,'frequency','30m');



    





