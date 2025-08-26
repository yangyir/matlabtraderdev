[~,~,codes_index,codes_sector,codes_stock] = isinequitypool('');
codes_etfs = [codes_index;codes_sector];

output_etfs = fractal_kelly_summary('codes',codes_etfs,'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_etfs,~,~,~,~,strat_daily_etfs] = kellydistributionsummary(output_etfs);
[tblreport_etfs,stats_etfs,tbl_byasset_etfs] = kellydistributionreport(tbl_etfs,strat_daily_etfs);
%%
output_etfs = fractal_kelly_summary('codes',{'512100'},'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
[~,~,tbl_etfs_m30,~,~,~,~,strat_etfs_m30] = kellydistributionsummary(output_etfs);
%%
[unwindedtrades,carriedtrades,tbl2check] = charlotte_backtest_period('code','512100','fromdate','2023-08-25','todate','2023-08-28','kellytables',strat_etfs_m30,'showlogs',false,'figureidx',4,'frequency','30m','nfractal',4);
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\etfs\'];
try
    cd(dir_);
catch
    mkdir(dir_);
    cd(dir_);
end
save([dir_,'strat_daily_etfs.mat'],'strat_daily_etfs');
fprintf('daily etfs strat M-file saved...\n');

save([dir_,'tblreport_etfs.mat'],'tblreport_etfs');
fprintf('daily etfs tbl report M-file saved...\n');
%
