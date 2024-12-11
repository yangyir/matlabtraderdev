dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\'];
foldername = [getenv('onedrive'),'\matlabdev\govtbond\'];
% shortcodes = {'tf';'t';'tl'};
shortcodes = {'t';'tl'};
codes_govtbondfut = cell(10000,1);
ncodes = 0;
for i = 1:length(shortcodes)
    foldername_i = [foldername,shortcodes{i}];
    listing_i = dir(foldername_i);
    for j = 3:size(listing_i,1)
        fn_j = listing_i(j).name;
        if isempty(strfind(fn_j,'_'))
            ncodes = ncodes + 1;
            codes_govtbondfut{ncodes,1} = fn_j(1:end-4);
        end
    end
end
codes_govtbondfut = codes_govtbondfut(1:ncodes,:);
extra_codes = {'T1512';'T1603';'T1606';'T1609';'T1612';'T1703'};
codes_govtbondfut_daily = [extra_codes;codes_govtbondfut];

%%
%
output_govtbondfut_daily = fractal_kelly_summary('codes',codes_govtbondfut_daily,'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_govtbondfut_daily,~,~,~,~,strat_govtbondfut_daily] = kellydistributionsummary(output_govtbondfut_daily,'useactiveonly',true);
%
[tblreport_govtbondfut_daily,statsreport_govtbondfut_daily] = kellydistributionreport(tbl_govtbondfut_daily,strat_govtbondfut_daily);
%%

%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\'];
save([dir_,'strat_govtbondfut_daily.mat'],'strat_govtbondfut_daily');
fprintf('file saved...\n');
