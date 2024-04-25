datapath = [getenv('datapath'),'dailybar\'];
listing = dir(datapath);
nfiles = size(listing,1);

listcodes = cell(nfiles,1);
listassets = cell(nfiles,1);
ncode = 0;
for i = 3:nfiles
    this_name = listing(i).name;
    this_code = this_name(1:end-10);
    this_instr = code2instrument(this_code);
    if isempty(this_instr.asset_name), continue;end
    if strcmpi(this_instr.asset_name,'eqindex_300') || strcmpi(this_instr.asset_name,'eqindex_50')  || strcmpi(this_instr.asset_name,'eqindex_1000') || strcmpi(this_instr.asset_name,'eqindex_500') || ...
            strcmpi(this_instr.asset_name,'govtbond_10y') || strcmpi(this_instr.asset_name,'govtbond_30y') || strcmpi(this_instr.asset_name,'govtbond_5y') || ...
            strcmpi(this_instr.asset_name,'thermal coal')
        continue;
    end
    ncode = ncode + 1;
    listcodes{ncode,1} = this_code;
    listassets{ncode,1} = this_instr.asset_name;
end
listcodes = listcodes(1:ncode,:);
listassets = listassets(1:ncode,:);
tbl = table(listcodes,listassets);
listassetsunique = unique(listassets);
%%
output_comdty_daily = fractal_kelly_summary('codes',listcodes,'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[~,~,tbl_comdty_daily,~,~,~,~,strat_comdty_daily] = kellydistributionsummary(output_comdty_daily,'useactiveonly',true);
%%
[tbl_report_comdty_daily,stats_report_comdty_daily] = kellydistributionreport(tbl_comdty_daily,strat_comdty_daily);
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\'];
try
    cd(dir_);
catch
    mkdir(dir_);
    cd(dir_);
end
save([dir_,'strat_comdty_daily.mat'],'strat_comdty_daily');
fprintf('daily strat M-file saved...\n');

save([dir_,'tbl_report_comdty_daily.mat'],'tbl_report_comdty_daily');
fprintf('daily tbl report M-file saved...\n');

save([dir_,'output_comdty_daily.mat'],'output_comdty_daily');
fprintf('daily output M-file saved...\n');
%
filename = [getenv('onedrive'),'\fractal backtest\kelly distribution\tblreport_comdty_daily.xlsx'];
writetable(tbl_report_comdty_daily,filename,'Sheet',1,'Range','A1');
fprintf('excel file saved...\n');

%%
idx_i = strcmpi(listassets,'soybean oil');
codes_i = listcodes(idx_i);
output_comdty_i = fractal_kelly_summary('codes',codes_i,'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
