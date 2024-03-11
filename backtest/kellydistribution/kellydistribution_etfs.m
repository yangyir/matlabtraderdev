[~,~,codes_index,codes_sector,codes_stock] = isinequitypool('');
codes_etfs = [codes_index;codes_sector];

output_etfs = fractal_kelly_summary('codes',codes_etfs,'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[~,~,tbl_etfs,~,~,~,~,strat_daily_etfs] = kellydistributionsummary(output_etfs);
[tblreport_etfs,stats_etfs,tbl_byasset_etfs] = kellydistributionreport(tbl_etfs,strat_daily_etfs);