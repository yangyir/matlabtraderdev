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
%%
output_govtbondfut_30m = fractal_kelly_summary('codes',codes_govtbondfut,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_govtbondfut_30m,~,~,~,~,strat_govtbondfut_30m] = kellydistributionsummary(output_govtbondfut_30m,'useactiveonly',true);
%
[tblreport_govtbondfut_30m,statsreport_govtbondfut_30m] = kellydistributionreport(tbl_govtbondfut_30m,strat_govtbondfut_30m);
%%
output_govtbondfut_5m = fractal_kelly_summary('codes',codes_govtbondfut,'frequency','intraday-5m','usefractalupdate',0,'usefibonacci',1,'direction','both');
%strat_govtbondfut_5m
[~,~,tbl_govtbondfut_5m,~,~,~,~,strat_govtbondfut_5m] = kellydistributionsummary(output_govtbondfut_5m,'useactiveonly',true);
%
[tblreport_govtbondfut_5m,statsreport_govtbondfut_5m] = kellydistributionreport(tbl_govtbondfut_5m,strat_govtbondfut_5m);
%%
output_govtbondfut_15m = fractal_kelly_summary('codes',codes_govtbondfut,'frequency','intraday-15m','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_govtbondfut_15m,~,~,~,~,strat_govtbondfut_15m] = kellydistributionsummary(output_govtbondfut_15m,'useactiveonly',true);
%
[tblreport_govtbondfut_15m,statsreport_govtbondfut_15m] = kellydistributionreport(tbl_govtbondfut_15m,strat_govtbondfut_15m);
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\'];
save([dir_,'strat_govtbondfut_30m.mat'],'strat_govtbondfut_30m');
save([dir_,'tblreport_govtbondfut_30m.mat'],'tblreport_govtbondfut_30m');
save([dir_,'strat_govtbondfut_5m.mat'],'strat_govtbondfut_5m');
save([dir_,'tblreport_govtbondfut_5m.mat'],'tblreport_govtbondfut_5m');
save([dir_,'strat_govtbondfut_15m.mat'],'strat_govtbondfut_15m');
save([dir_,'tblreport_govtbondfut_15m.mat'],'tblreport_govtbondfut_15m');
fprintf('file saved...\n');
