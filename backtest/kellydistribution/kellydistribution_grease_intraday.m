foldername = [getenv('onedrive'),'\matlabdev\agriculture\'];
shortcodes = {'oi';'p';'y';'m';'rm';'a'};
codes_grease = cell(10000,1);
ncodes = 0;
for i = 1:length(shortcodes)
    foldername_i = [foldername,shortcodes{i}];
    listing_i = dir(foldername_i);
    for j = 3:size(listing_i,1)
        ncodes = ncodes + 1;
        fn_j = listing_i(j).name;
        codes_grease{ncodes,1} = fn_j(1:end-4);
    end
end
codes_grease = codes_grease(1:ncodes,:);
%
output_grease = fractal_kelly_summary('codes',codes_grease,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_grease_i,~,~,~,~,strat_intraday_grease] = kellydistributionsummary(output_grease);
%
[tbl_report_grease_i,stats_report_grease_i] = kellydistributionreport(tbl_grease_i,strat_intraday_grease);
%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\grease\'];
save([dir_,'strat_intraday_grease.mat'],'strat_intraday_grease');
fprintf('file saved...\n');
%%
startdate = '2023-11-17';
codes_grease_active = {codes_oi{end};codes_p{end};codes_y{end};codes_m{end};codes_rm{end};codes_a{end}};
output_grease_active = fractal_kelly_summary('codes',codes_grease_active,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both','fromdate',startdate);
[~,~,tbl_grease_active,~,~,~,~] = kellydistributionsummary(output_grease_active);
distributionfile = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\grease\strat_intraday_grease.mat']);
tbl_report_grease_active = kellydistributionreport(tbl_grease_active,distributionfile.strat_intraday_grease);
%%