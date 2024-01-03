%
codes_comdty = cell(10000,1);
ncodes = 0;
categories = {'agriculture';'basemetal';'energy';'industrial';'preciousmetal'};
useflags = [1;1;1;1;1];
for i = 1:length(categories)
    if ~useflags(i),continue;end
    folder_i = [getenv('onedrive'),'\matlabdev\',categories{i},'\'];
    listing_i = dir(folder_i);
    subfolder_i = cell(size(listing_i,1)-2,1);
    for j = 3:size(listing_i,1)
        subfolder_i = [folder_i,listing_i(j).name,'\'];
        listing_ij = dir(subfolder_i);
        for k = 3:size(listing_ij)
            ncodes = ncodes + 1;
            fn_ij = listing_ij(k).name;
            codes_comdty{ncodes,1} = fn_ij(1:end-4);
        end
    end
end
codes_comdty = codes_comdty(1:ncodes,:);
%
output_comdty_i = fractal_kelly_summary('codes',codes_comdty,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_comdty_i,~,~,~,~,strat_comdty_i] = kellydistributionsummary(output_comdty_i);
%
[tbl_report_comdty_i,stats_report_comdty_i] = kellydistributionreport(tbl_comdty_i,strat_comdty_i);

dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\'];
try
    cd(dir_);
catch
    mkdir(dir_);
    cd(dir_);
end
save([dir_,'strat_comdty_i.mat'],'strat_comdty_i');
fprintf('strat M-file saved...\n');

filename = [getenv('onedrive'),'\fractal backtest\kelly distribution\tbl_report_comdty_i.xlsx'];
writetable(tbl_report_comdty_i,filename,'Sheet',1,'Range','A1');
fprintf('excel file saved...\n');

%%
% startdate = '2023-12-18';
% output_grease_active = fractal_kelly_summary('codes',codes_grease_active,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both','fromdate',startdate);
% [~,~,tbl_grease_active,~,~,~,~] = kellydistributionsummary(output_grease_active);
% distributionfile = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\grease\strat_intraday_grease.mat']);
% tbl_report_grease_active = kellydistributionreport(tbl_grease_active,distributionfile.strat_intraday_grease);
%%