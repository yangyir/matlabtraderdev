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

        if ~isempty(strfind(fn_ij,'_1m')),continue;end
        if ~isempty(strfind(fn_ij,'_5m')),continue;end
        if ~isempty(strfind(fn_ij,'_15m')),continue;end
        
        if ~isempty(strfind(fn_ij,'2509')),continue;end
        
        if  ~isempty(strfind(lower(fn_ij),'im')) ||~isempty(strfind(lower(fn_ij),'ic')) 
            ncodes = ncodes + 1;
            codes_eqindex{ncodes,1} = fn_ij(1:end-4);
        end
            
    end
end
codes_eqindex = codes_eqindex(1:ncodes,:);
%%
output_eqindexfut_m30 = fractal_kelly_summary('codes',codes_eqindex,'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_eqindexfut_m30,~,~,~,~,strat_eqindexfut_m30] = kellydistributionsummary(output_eqindexfut_m30,'useactiveonly',true);
%
[tblreport_eqindexfut_m30,statsreport_eqindexfut_m30] = kellydistributionreport(tbl_eqindexfut_m30,strat_eqindexfut_m30);
%%
output_eqindexfut_m5 = fractal_kelly_summary('codes',codes_eqindex,'frequency','intraday-5m','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_eqindexfut_m5,~,~,~,~,strat_eqindexfut_m5] = kellydistributionsummary(output_eqindexfut_m5,'useactiveonly',true);
%
[tblreport_eqindexfut_m5,statsreport_eqindexfut_m5] = kellydistributionreport(tbl_eqindexfut_m5,strat_eqindexfut_m5);


%%
tbl2check_eqindexfut_m5 = cell(ncodes,1);
parfor i = 1:ncodes
    [dt1,dt2] = irene_findactiveperiod('code',codes_eqindex{i});
    if isempty(dt1) || isempty(dt2), continue;end
    dt1 = datestr(dt1,'yyyy-mm-dd');
    dt2 = datestr(dt2,'yyyy-mm-dd');
    [~,~,tbl2check_eqindexfut_m5{i}] = charlotte_backtest_period('code',codes_eqindex{i},'fromdate',dt1,'todate',dt2,'kellytables',strat_eqindexfut_m5,'showlogs',false,'doplot',false,'frequency','5m');
end

tbl2check_eqindexfut_m5_all = tbl2check_eqindexfut_m5{1};
for i = 2:ncodes
    temp_m5 = [tbl2check_eqindexfut_m5_all;tbl2check_eqindexfut_m5{i}];
    tbl2check_eqindexfut_m5_all = temp_m5;
end
%%
[winp_running,r_running,kelly_running] = calcrunningkelly(tbl2check_eqindexfut_m5_all.pnlrel);
Wret = winp_running(end);
Rret = r_running(end);
Kret = kelly_running(end);
pnlretcum = cumsum(tbl2check_eqindexfut_m5_all.pnlrel);
pnlretmax = pnlretcum;
for j = 1:length(pnlretmax)
    pnlretmax(j) = max(pnlretcum(1:j));
    if pnlretmax(j) < 0, pnlretmax(j) = 0;end
end
pnlretdrawdown = pnlretcum - pnlretmax;
pnlretdrawdownmax = min(pnlretdrawdown);
   
statsout_m5 = struct('asset','eqindex_1000',...
    'nTotal',size(tbl2check_eqindexfut_m5_all.pnlrel,1),...
    'Pwin',Wret,...
    'Rret',Rret,...
    'Kret',Kret,...
    'MaxDrawdownret',pnlretdrawdownmax);
%%
regressiontestcombo = regressiontest_fractal('code','IM2509',...
    'datefrom','2025-09-02',...
    'dateto','2025-09-02',...
    'frequency','5m',...
    'kellytabledir',[getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\'],...
    'kellytablename','strat_eqindexfut_m5.mat');

%%
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\'];
save([dir_,'strat_eqindexfut_m30.mat'],'strat_eqindexfut_m30');
save([dir_,'tblreport_eqindexfut_m30.mat'],'tblreport_eqindexfut_m30');
fprintf('STRAT of eqindexfut m30 saved...\n');
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\'];
save([dir_,'strat_eqindexfut_m5.mat'],'strat_eqindexfut_m5');
save([dir_,'tblreport_eqindexfut_m5.mat'],'tblreport_eqindexfut_m5');
fprintf('STRAT of eqindexfut m5 saved...\n');
