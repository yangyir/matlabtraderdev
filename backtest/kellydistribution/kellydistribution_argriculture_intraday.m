foldername = [getenv('onedrive'),'\matlabdev\industrial\'];
shortcodes = {'fg';'hc';'i';'j';'jm';'rb';'v'};
codes_industry = cell(10000,1);
ncodes = 0;
for i = 1:length(shortcodes)
    foldername_i = [foldername,shortcodes{i}];
    listing_i = dir(foldername_i);
    for j = 3:size(listing_i,1)
        ncodes = ncodes + 1;
        fn_j = listing_i(j).name;
        codes_industry{ncodes,1} = fn_j(1:end-4);
    end
end
codes_industry = codes_industry(1:ncodes,:);
%
output_industry = fractal_kelly_summary('codes',codes_industry,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_industry_i,~,~,~,~,strat_intraday_industry] = kellydistributionsummary(output_industry);
%
[tbl_report_industry_i,stats_report_industry_i] = kellydistributionreport(tbl_industry_i,strat_intraday_industry);
%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\industry\'];
try
    cd(dir_);
catch
    mkdir(dir_);
end
save([dir_,'strat_intraday_industry.mat'],'strat_intraday_industry');
fprintf('file saved...\n');

%%