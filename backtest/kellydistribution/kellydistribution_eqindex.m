%
codes_ch_eqindex = {'000001.SH';...%'上证指数'
    '000300.SH';...%'沪深300指数'
    '000016.SH';...%'上证50指数'
    '000905.SH';...%'中证500指数'
    '000852.SH';...%'中证1000指数'
    '399006.SZ';...%'创业板指数'
    '000688.SH';...%'科创50指数'
    '000015.SH';...%'红利指数'
    };
output_eqindexcn = fractal_kelly_summary('codes',codes_ch_eqindex,'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[~,~,tbl_eqindexcn,~,~,~,~,strat_daily_eqindexcn] = kellydistributionsummary(output_eqindexcn);
[tblreport_eqindexcn,stats_eqindexcn] = kellydistributionreport(tbl_eqindexcn,strat_daily_eqindexcn);
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexcn\'];
save([dir_,'strat_daily_eqindexcn.mat'],'strat_daily_eqindexcn');
fprintf('file saved...\n');
