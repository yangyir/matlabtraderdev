codes_TF = {
    'TF1403';'TF1406';'TF1409';'TF1412';...
    'TF1503';'TF1506';'TF1509';'TF1512';...
    'TF1603';'TF1606';'TF1609';'TF1612';...
    'TF1703';'TF1706';'TF1709';'TF1712';...
    'TF1803';'TF1806';'TF1809';'TF1812';...
    'TF1903';'TF1906';'TF1909';'TF1912';...
    'TF2003';'TF2006';'TF2009';'TF2012';...
    'TF2103';'TF2106';'TF2109';'TF2112';...
    'TF2203';'TF2206';'TF2209';'TF2212';...
    'TF2303';'TF2306';'TF2309';'TF2312';...
    'TF2403';...
    };

codes_T = {'T1509';'T1512';...
    'T1603';'T1606';'T1609';'T1612';...
    'T1703';'T1706';'T1709';'T1712';...
    'T1803';'T1806';'T1809';'T1812';...
    'T1903';'T1906';'T1909';'T1912';...
    'T2003';'T2006';'T2009';'T2012';...
    'T2103';'T2106';'T2109';'T2112';...
    'T2203';'T2206';'T2209';'T2212';...
    'T2303';'T2306';'T2309';'T2312';...
    'T2403';...
    };
codes_TL = {'TL2309';'TL2312';...
    'TL2403'};
%
output_govtbondfut_daily = fractal_kelly_summary('codes',[codes_TF;codes_T;codes_TL],'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');

%%
[~,~,tbl_govtbondfut_daily,~,~,~,~,strat_govtbondfut_daily] = kellydistributionsummary(output_govtbondfut_daily,true);
[tblreport_govtbondfut_daily,statsreport_govtbondfut_daily] = kellydistributionreport(tbl_govtbondfut_daily,strat_govtbondfut_daily);
close all;

%%

%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\'];
save([dir_,'strat_daily_govtbondfut.mat'],'strat_daily_govtbondfut');
fprintf('file saved...\n');
