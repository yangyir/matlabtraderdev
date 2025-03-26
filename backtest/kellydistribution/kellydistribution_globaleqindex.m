fn_eqindex = {'dowjones';'nasdaq';'spx500';...
    'ftse100';'cac40';'dax';...
    'n225';...
    'hsi'};
%
output_globaleqindex_daily = fractal_kelly_summary('codes',fn_eqindex,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both',...
    'nfractal',2);
%
[~,~,tbl_globaleqindex_daily,~,~,~,~,strat_globaleqindex_daily] = kellydistributionsummary(output_globaleqindex_daily);
%
[tbl_report_globaleqindex_daily,stats_report_globaleqindex_daily] = kellydistributionreport(tbl_globaleqindex_daily,strat_globaleqindex_daily);

%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\globaleqindex\'];
try
    cd(dir_);
catch
    mkdir(dir_);
    cd(dir_);
end
save([dir_,'strat_globaleqindex_daily.mat'],'strat_globaleqindex_daily');
fprintf('strat M-file saved...\n');

save([dir_,'tbl_report_globaleqindex_daily.mat'],'tbl_report_globaleqindex_daily');
fprintf('tbl report M-file saved...\n');

save([dir_,'output_globaleqindex_daily.mat'],'output_globaleqindex_daily');
fprintf('output M-file saved...\n');
%
% filename = [getenv('onedrive'),'\fractal backtest\kelly distribution\tbl_report_globaleqindex_daily.xlsx'];
% writetable(tbl_report_globaleqindex_daily,filename,'Sheet',1,'Range','A1');
% fprintf('excel file saved...\n');