folder_eqindex = [getenv('onedrive'),'\matlabdev\eqindex\'];
codes_eqindex = cell(10000,1);
ncodes = 0;
listing_eqindex = dir(folder_eqindex);
subfolder_eqindex = cell(size(listing_eqindex,1)-2,1);
for j = 3:size(listing_eqindex,1)
    subfolder_eqindex = [folder_eqindex,listing_eqindex(j).name,'\'];
    listing_ij = dir(subfolder_eqindex);
    for k = 3:size(listing_ij)
        
        fn_ij = listing_ij(k).name;
        
%         if ~(isempty(strfind(lower(fn_ij),'if')) || ...
%                 isempty(strfind(lower(fn_ij),'ih')) || ...
%                 isempty(strfind(lower(fn_ij),'ic')) || ...
%                 isempty(strfind(lower(fn_ij),'im')))
%             continue;
%         end
        
        if isempty(strfind(lower(fn_ij),'ic'))
            continue;
        end
        
        if ~isempty(strfind(fn_ij,'_1m')),continue;end
        if ~isempty(strfind(fn_ij,'_5m')),continue;end
        if ~isempty(strfind(fn_ij,'_15m')),continue;end
        
        ncodes = ncodes + 1;
        
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
tbl2check_eqindexfut_m30 = cell(ncodes,1);
parfor i = 1:ncodes
    [dt1,dt2] = irene_findactiveperiod('code',codes_eqindex{i});
    if isempty(dt1) || isempty(dt2), continue;end
    dt1 = datestr(dt1,'yyyy-mm-dd');
    dt2 = datestr(dt2,'yyyy-mm-dd');
    [~,~,tbl2check_eqindexfut_m30{i}] = charlotte_backtest_period('code',codes_eqindex{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_eqindexfut,'showlogs',false,'doplot',false,'frequency','30m');
end

tbl2check_eqindexfut_30m_all = tbl2check_eqindexfut_m30{1};
for i = 2:ncodes
    temp_30m = [tbl2check_eqindexfut_30m_all;tbl2check_eqindexfut_m30{i}];
    tbl2check_eqindexfut_30m_all = temp_30m;
end

%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\'];
save([dir_,'strat_eqindexfut.mat'],'strat_eqindexfut');
save([dir_,'tblreport_eqindexfut.mat'],'tblreport_eqindexfut');
fprintf('files of eqindexfut saved...\n');
