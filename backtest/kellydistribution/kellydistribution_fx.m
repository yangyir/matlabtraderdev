names_fx = {'usdx';'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';...
    'eurjpy';'eurchf';'gbpeur';'gbpjpy';'audjpy';...
    'usdcnh'};

output_fx_daily = fractal_kelly_summary('codes',names_fx,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');

%%
[~,~,tbl_fx_daily,~,~,~,~,strat_fx_daily] = kellydistributionsummary(output_fx_daily);
%
[tbl_report_fx_daily,stats_report_fx_daily] = kellydistributionreport(tbl_fx_daily,strat_fx_daily);

%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
try
    cd(dir_);
catch
    mkdir(dir_);
    cd(dir_);
end
save([dir_,'strat_fx_daily.mat'],'strat_fx_daily');
fprintf('strat M-file saved...\n');

save([dir_,'tbl_report_fx_daily.mat'],'tbl_report_fx_daily');
fprintf('tbl report M-file saved...\n');

save([dir_,'output_fx_daily.mat'],'output_fx_daily');
fprintf('output M-file saved...\n');
%
filename = [getenv('onedrive'),'\fractal backtest\kelly distribution\tbl_report_fx_daily.xlsx'];
writetable(tbl_report_fx_daily,filename,'Sheet',1,'Range','A1');
fprintf('excel file saved...\n');