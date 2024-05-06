folder_eqindex = [getenv('onedrive'),'\matlabdev\eqindex\'];
codes_eqindex = cell(10000,1);
ncodes = 0;
listing_eqindex = dir(folder_eqindex);
subfolder_eqindex = cell(size(listing_eqindex,1)-2,1);
for j = 3:size(listing_eqindex,1)
    subfolder_eqindex = [folder_eqindex,listing_eqindex(j).name,'\'];
    listing_ij = dir(subfolder_eqindex);
    for k = 3:size(listing_ij)
        ncodes = ncodes + 1;
        fn_ij = listing_ij(k).name;
        codes_eqindex{ncodes,1} = fn_ij(1:end-4);
    end
end
codes_eqindex = codes_eqindex(1:ncodes,:);
%%
output_eqindexfut = fractal_kelly_summary('codes',codes_eqindex,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_eqindexfut,~,~,~,~,strat_eqindexfut] = kellydistributionsummary(output_eqindexfut,'useactiveonly',true);
%66
[tblreport_eqindexfut,statsreport_eqindexfut] = kellydistributionreport(tbl_eqindexfut,strat_eqindexfut);

%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\'];
save([dir_,'strat_eqindexfut.mat'],'strat_eqindexfut');
save([dir_,'tblreport_eqindexfut.mat'],'tblreport_eqindexfut');
fprintf('files of eqindexfut saved...\n');
