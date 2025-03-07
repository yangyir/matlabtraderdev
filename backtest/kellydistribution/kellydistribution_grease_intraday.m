foldername = [getenv('onedrive'),'\matlabdev\agriculture\'];
shortcodes = {'oi';'p';'y';'m';'rm';'a'};
codes_grease = cell(10000,1);
codes_oi = cell(10000,1);
codes_p = cell(10000,1);
codes_y = cell(10000,1);
codes_m = cell(10000,1);
codes_rm = cell(10000,1);
codes_a = cell(10000,1);
ncodes = 0;
ncodes_oi = 0;
ncodes_p = 0;
ncodes_y = 0;
ncodes_m = 0;
ncodes_rm = 0;
ncodes_a = 0;
for i = 1:length(shortcodes)
    foldername_i = [foldername,shortcodes{i}];
    listing_i = dir(foldername_i);
    for j = 3:size(listing_i,1)
        ncodes = ncodes + 1;
        fn_j = listing_i(j).name;
        codes_grease{ncodes,1} = fn_j(1:end-4);
        switch shortcodes{i}
            case 'oi'
                ncodes_oi = ncodes_oi + 1;
                codes_oi{ncodes_oi,1} = fn_j(1:end-4);
            case 'p'
                ncodes_p = ncodes_p + 1;
                codes_p{ncodes_p,1} = fn_j(1:end-4);
            case 'y'
                ncodes_y = ncodes_y + 1;
                codes_y{ncodes_y,1} = fn_j(1:end-4);
            case 'm'
                ncodes_m = ncodes_m + 1;
                codes_m{ncodes_m,1} = fn_j(1:end-4);
            case 'rm'
                ncodes_rm = ncodes_rm + 1;
                codes_rm{ncodes_rm,1} = fn_j(1:end-4);
            case 'a'
                ncodes_a = ncodes_a + 1;
                codes_a{ncodes_a,1} = fn_j(1:end-4);
            otherwise
                break
        end   
    end
end
codes_grease = codes_grease(1:ncodes,:);
codes_oi = codes_oi(1:ncodes_oi,:);
codes_p = codes_p(1:ncodes_p,:);
codes_y = codes_y(1:ncodes_y,:);
codes_m = codes_m(1:ncodes_m,:);
codes_rm = codes_rm(1:ncodes_rm,:);
codes_a = codes_a(1:ncodes_a,:);

%%
output_grease = fractal_kelly_summary('codes',codes_grease,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_grease_i,~,~,~,~,strat_intraday_grease] = kellydistributionsummary(output_grease);
%
[tbl_report_grease_i,stats_report_grease_i] = kellydistributionreport(tbl_grease_i,strat_intraday_grease);
%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\grease\'];
save([dir_,'strat_intraday_grease.mat'],'strat_intraday_grease');
fprintf('file saved...\n');
%%
output_p = fractal_kelly_summary('codes',codes_p,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_i_p,~,~,~,~,strat_i_p] = kellydistributionsummary(output_p);
%
% [tbl_report_grease_i,stats_report_grease_i] = kellydistributionreport(tbl_grease_i,strat_intraday_grease);
%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\grease\'];
save([dir_,'strat_i_p.mat'],'strat_i_p');
fprintf('file saved...\n');
%%
output_y = fractal_kelly_summary('codes',codes_y,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_i_y,~,~,~,~,strat_i_y] = kellydistributionsummary(output_y);
%
% [tbl_report_grease_i,stats_report_grease_i] = kellydistributionreport(tbl_grease_i,strat_intraday_grease);
%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\grease\'];
save([dir_,'strat_i_y.mat'],'strat_i_y');
fprintf('file saved...\n');


%% palm oil
data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\grease\strat_intraday_grease.mat']);
kellytables = data.strat_intraday_grease;
tbl2check_30m_p = cell(ncodes_p,1);

for i = 1:ncodes_p
    [dt1,dt2] = irene_findactiveperiod('code',codes_p{i});
    dt1 = datestr(dt1,'yyyy-mm-dd');
    dt2 = datestr(dt2,'yyyy-mm-dd');
    [~,~,tbl2check_30m_p{i}] = charlotte_backtest_period('code',codes_p{i},'fromdate',dt1,'todate',dt2,'kellytables',kellytables,'showlogs',false,'figureidx',i+1,'frequency','30m');
    if i == 1
        tbl2check_30m_all_p = tbl2check_30m_p{i};
    else
        tmp = [tbl2check_30m_all_p;tbl2check_30m_p{i}];
        tbl2check_30m_all_p = tmp;
    end
end
[tblpnl_30m_p,~,statsout_30m_p] = irene_trades2dailypnl('tradestable',tbl2check_30m_all_p,'frequency','30m');

%% soybean oil
tbl2check_30m_y = cell(ncodes_y,1);
for i = 1:ncodes_y
    [dt1,dt2] = irene_findactiveperiod('code',codes_y{i});
    dt1 = datestr(dt1,'yyyy-mm-dd');
    dt2 = datestr(dt2,'yyyy-mm-dd');
    [~,~,tbl2check_30m_y{i}] = charlotte_backtest_period('code',codes_y{i},'fromdate',dt1,'todate',dt2,'kellytables',kellytables,'showlogs',false,'figureidx',i+1,'frequency','30m');
    if i == 1
        tbl2check_30m_all_y = tbl2check_30m_y{i};
    else
        tmp = [tbl2check_30m_all_y;tbl2check_30m_y{i}];
        tbl2check_30m_all_y = tmp;
    end
end
[tblpnl_30m_y,~,statsout_30m_y] = irene_trades2dailypnl('tradestable',tbl2check_30m_all_y,'frequency','30m');

%% soymeal
tbl2check_30m_m = cell(ncodes_m,1);
for i = 1:ncodes_m
    [dt1,dt2] = irene_findactiveperiod('code',codes_m{i});
    dt1 = datestr(dt1,'yyyy-mm-dd');
    dt2 = datestr(dt2,'yyyy-mm-dd');
    [~,~,tbl2check_30m_m{i}] = charlotte_backtest_period('code',codes_m{i},'fromdate',dt1,'todate',dt2,'kellytables',kellytables,'showlogs',false,'figureidx',i+1,'frequency','30m');
    if i == 1
        tbl2check_30m_all_m = tbl2check_30m_m{i};
    else
        tmp = [tbl2check_30m_all_m;tbl2check_30m_m{i}];
        tbl2check_30m_all_m = tmp;
    end
end
[tblpnl_30m_m,~,statsout_30m_m] = irene_trades2dailypnl('tradestable',tbl2check_30m_all_m,'frequency','30m');
%% rapeseed oil
tbl2check_30m_oi = cell(ncodes_oi,1);
for i = 1:ncodes_oi
    [dt1,dt2] = irene_findactiveperiod('code',codes_oi{i});
    dt1 = datestr(dt1,'yyyy-mm-dd');
    dt2 = datestr(dt2,'yyyy-mm-dd');
    [~,~,tbl2check_30m_oi{i}] = charlotte_backtest_period('code',codes_oi{i},'fromdate',dt1,'todate',dt2,'kellytables',kellytables,'showlogs',false,'figureidx',i+1,'frequency','30m');
    if i == 1
        tbl2check_30m_all_oi = tbl2check_30m_oi{i};
    else
        tmp = [tbl2check_30m_all_oi;tbl2check_30m_oi{i}];
        tbl2check_30m_all_oi = tmp;
    end
end
[tblpnl_30m_oi,~,statsout_30m_oi] = irene_trades2dailypnl('tradestable',tbl2check_30m_all_oi,'frequency','30m');
