%
codes_ch_eqindex = {'000001.SH';...%'��ָ֤��'
    '000300.SH';...%'����300ָ��'
    '000016.SH';...%'��֤50ָ��'
    '000905.SH';...%'��֤500ָ��'
    '000852.SH';...%'��֤1000ָ��'
    '399006.SZ';...%'��ҵ��ָ��'
    '000688.SH';...%'�ƴ�50ָ��'
    '000015.SH';...%'����ָ��'
    };
output_eqindexcn = fractal_kelly_summary('codes',codes_ch_eqindex,'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[~,~,tbl_eqindexcn,~,~,~,~,strat_daily_eqindexcn] = kellydistributionsummary(output_eqindexcn);
[tblreport_eqindexcn,stats_eqindexcn] = kellydistributionreport(tbl_eqindexcn,strat_daily_eqindexcn);
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexcn\'];
save([dir_,'strat_daily_eqindexcn.mat'],'strat_daily_eqindexcn');
fprintf('file saved...\n');
