foldername = [getenv('onedrive'),'\matlabdev\govtbond\'];
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\'];
shortcodes = {'tf';'t';'tl'};
codes_govtbondfut_tf = cell(1000,1);
codes_govtbondfut_t = cell(1000,1);
codes_govtbondfut_tl = cell(1000,1);

%
ncodes = 0;
foldername_tf = [foldername,shortcodes{1}];
listing_tf = dir(foldername_tf);
for j = 3:size(listing_tf,1)
    fn_j = listing_tf(j).name;
    if isempty(strfind(fn_j,'_'))
        ncodes = ncodes + 1;
        codes_govtbondfut_tf{ncodes,1} = fn_j(1:end-4);
    end
end
codes_govtbondfut_tf = codes_govtbondfut_tf(1:ncodes,:);
%
ncodes = 0;
foldername_t = [foldername,shortcodes{2}];
listing_t = dir(foldername_t);
for j = 3:size(listing_t,1)
    fn_j = listing_t(j).name;
    if isempty(strfind(fn_j,'_'))
        ncodes = ncodes + 1;
        codes_govtbondfut_t{ncodes,1} = fn_j(1:end-4);
    end
end
codes_govtbondfut_t = codes_govtbondfut_t(1:ncodes,:);
%
ncodes = 0;
foldername_tl = [foldername,shortcodes{3}];
listing_tl = dir(foldername_tl);
for j = 3:size(listing_tl,1)
    fn_j = listing_tl(j).name;
    if isempty(strfind(fn_j,'_'))
        ncodes = ncodes + 1;
        codes_govtbondfut_tl{ncodes,1} = fn_j(1:end-4);
    end
end
codes_govtbondfut_tl = codes_govtbondfut_tl(1:ncodes,:);
%

%%
output_govtbondfut_30m = fractal_kelly_summary('codes',[codes_govtbondfut_t;codes_govtbondfut_tl],...
    'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_govtbondfut_30m,~,~,~,~,strat_govtbondfut_30m] = kellydistributionsummary(output_govtbondfut_30m,'useactiveonly',true);
%
[tblreport_govtbondfut_30m,statsreport_govtbondfut_30m] = kellydistributionreport(tbl_govtbondfut_30m,strat_govtbondfut_30m);
% save([dir_,'strat_govtbondfut_30m.mat'],'strat_govtbondfut_30m');
% save([dir_,'tblreport_govtbondfut_30m.mat'],'tblreport_govtbondfut_30m');
% fprintf('file of 30m-govtbond saved...\n');
%%
output_govtbondfut_5m = fractal_kelly_summary('codes',codes_govtbondfut_tl,...
    'frequency','intraday-5m','usefractalupdate',0,'usefibonacci',1,'direction','both');

[~,~,tbl_govtbondfut_5m,~,~,~,~,strat_govtbondfut_5m] = kellydistributionsummary(output_govtbondfut_5m,'useactiveonly',true);
%
[tblreport_govtbondfut_5m,statsreport_govtbondfut_5m] = kellydistributionreport(tbl_govtbondfut_5m,strat_govtbondfut_5m);
%
save([dir_,'strat_govtbondfut_5m.mat'],'strat_govtbondfut_5m');
save([dir_,'tblreport_govtbondfut_5m.mat'],'tblreport_govtbondfut_5m');
fprintf('file of 5m-govtbond saved...\n');
%%
output_govtbondfut_15m = fractal_kelly_summary('codes',[codes_govtbondfut_t;codes_govtbondfut_tl],...
    'frequency','intraday-15m','usefractalupdate',0,'usefibonacci',1,'direction','both');
%
[~,~,tbl_govtbondfut_15m,~,~,~,~,strat_govtbondfut_15m] = kellydistributionsummary(output_govtbondfut_15m,'useactiveonly',true);
%
[tblreport_govtbondfut_15m,statsreport_govtbondfut_15m] = kellydistributionreport(tbl_govtbondfut_15m,strat_govtbondfut_15m);
%
save([dir_,'strat_govtbondfut_15m.mat'],'strat_govtbondfut_15m');
save([dir_,'tblreport_govtbondfut_15m.mat'],'tblreport_govtbondfut_15m');
%
fprintf('file saved...\n');
