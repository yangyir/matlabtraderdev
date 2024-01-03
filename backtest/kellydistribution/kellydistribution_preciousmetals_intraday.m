foldername = [getenv('onedrive'),'\matlabdev\preciousmetal\'];
shortcodes = {'ag';'au'};
codes_preciousmetal = cell(10000,1);
ncodes = 0;
for i = 1:length(shortcodes)
    foldername_i = [foldername,shortcodes{i}];
    listing_i = dir(foldername_i);
    for j = 3:size(listing_i,1)
        ncodes = ncodes + 1;
        fn_j = listing_i(j).name;
        codes_preciousmetal{ncodes,1} = fn_j(1:end-4);
    end
end
codes_preciousmetal = codes_preciousmetal(1:ncodes,:);
%
output_preciousmetal = fractal_kelly_summary('codes',codes_preciousmetal,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_preciousmetal_i,~,~,~,~,strat_intraday_preciousmetal] = kellydistributionsummary(output_preciousmetal);
%
[tbl_report_preciousmetal_i,stats_report_preciousmetal_i] = kellydistributionreport(tbl_preciousmetal_i,strat_intraday_preciousmetal);
%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\preciousmetal\'];
try
    cd(dir_);
catch
    mkdir(dir_);
end
save([dir_,'strat_intraday_preciousmetal.mat'],'strat_intraday_preciousmetal');
fprintf('strat M-file saved...\n');

filename = [getenv('onedrive'),'\fractal backtest\kelly distribution\tbl_report_preciousmetal_i.xlsx'];
writetable(tbl_report_preciousmetal_i,filename,'Sheet',1,'Range','A1');
fprintf('excel file saved...\n');