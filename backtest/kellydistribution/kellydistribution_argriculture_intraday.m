foldername = [getenv('onedrive'),'\matlabdev\agriculture\'];
shortcodes = {'oi';'p';'y';'m';'rm';'a';'ap';'c';'CF';'jd';'lh';'ru';'SR'};
codes_agriculture = cell(10000,1);
ncodes = 0;
for i = 1:length(shortcodes)
    foldername_i = [foldername,shortcodes{i}];
    listing_i = dir(foldername_i);
    for j = 3:size(listing_i,1)
        ncodes = ncodes + 1;
        fn_j = listing_i(j).name;
        codes_agriculture{ncodes,1} = fn_j(1:end-4);
    end
end
codes_agriculture = codes_agriculture(1:ncodes,:);
%
output_agriculture = fractal_kelly_summary('codes',codes_agriculture,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_agriculture_i,~,~,~,~,strat_intraday_agriculture] = kellydistributionsummary(output_agriculture);
%
[tbl_report_agriculture_i,stats_report_agriculture_i] = kellydistributionreport(tbl_agriculture_i,strat_intraday_agriculture);
%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\agriculture\'];
save([dir_,'strat_intraday_agriculture.mat'],'strat_intraday_agriculture');
fprintf('file saved...\n');

%%