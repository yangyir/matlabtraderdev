%global macro
%
names_pm = {'xau';'xag'};
names_fx = {'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf'; 'eurjpy';'audjpy';};
names_bm = {'lmecopper';'lmealuminum';'lmezinic';'lmelead';'lmenickel';'lmetin'};
names_ei = { 'dowjones';'nasdaq';'spx500';'ftse100';'cac40';'dax';'n225';'hsi'};
%%
output_pm_daily = fractal_kelly_summary('codes',names_pm,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both','nfractal',2);
[~,~,tbl_pm_daily,~,~,~,~,strat_pm_daily] = kellydistributionsummary(output_pm_daily);
[tblreport_pm_daily,stats_report_pm_daily] = kellydistributionreport(tbl_pm_daily,strat_pm_daily);
%
output_fx_daily = fractal_kelly_summary('codes',names_fx,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both','nfractal',2);
[~,~,tbl_fx_daily,~,~,~,~,strat_fx_daily] = kellydistributionsummary(output_fx_daily);
[tblreport_fx_daily,stats_report_fx_daily] = kellydistributionreport(tbl_fx_daily,strat_fx_daily);
%
output_bm_daily = fractal_kelly_summary('codes',names_bm,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both','nfractal',2);
[~,~,tbl_bm_daily,~,~,~,~,strat_bm_daily] = kellydistributionsummary(output_bm_daily);
[tblreport_bm_daily,stats_report_bm_daily] = kellydistributionreport(tbl_bm_daily,strat_bm_daily);
%
output_ei_daily = fractal_kelly_summary('codes',names_ei,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both','nfractal',2);
[~,~,tbl_ei_daily,~,~,~,~,strat_ei_daily] = kellydistributionsummary(output_ei_daily);
[tblreport_ei_daily,stats_report_ei_daily] = kellydistributionreport(tbl_ei_daily,strat_ei_daily);
%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\globalmacro\'];
try
    cd(dir_);
catch
    mkdir(dir_);
    cd(dir_);
end
save([dir_,'strat_pm_daily.mat'],'strat_pm_daily');
save([dir_,'tblreport_pm_daily.mat'],'tblreport_pm_daily');
save([dir_,'output_pm_daily.mat'],'output_pm_daily');
fprintf('files of pm saved...\n');
%
save([dir_,'strat_fx_daily.mat'],'strat_fx_daily');
save([dir_,'tblreport_fx_daily.mat'],'tblreport_fx_daily');
save([dir_,'output_fx_daily.mat'],'output_fx_daily');
fprintf('files of fx saved...\n');
%
save([dir_,'strat_bm_daily.mat'],'strat_bm_daily');
save([dir_,'tblreport_bm_daily.mat'],'tblreport_bm_daily');
save([dir_,'output_bm_daily.mat'],'output_bm_daily');
fprintf('files of bm saved...\n');
%
save([dir_,'strat_ei_daily.mat'],'strat_ei_daily');
save([dir_,'tblreport_ei_daily.mat'],'tblreport_ei_daily');
save([dir_,'output_ei_daily.mat'],'output_ei_daily');
fprintf('files of ei saved...\n');

%%
n_pm = size(names_pm,1);
n_fx = size(names_fx,1);
n_bm = size(names_bm,1);
n_ei = size(names_ei,1);
for i = 1:4
    if i == 1
        names2use = names_pm;
        n = n_pm;
    elseif i == 2
        names2use = names_fx;
        n = n_fx;
    elseif i == 3
        names2use = names_bm;
        n = n_bm;
    elseif i == 4
        names2use = names_ei;
        n = n_ei;
    end
    
    tblpnls = cell(n,1);
    tblout2s = cell(n,1);
    statsouts = cell(n,1);
    for j = 1:n
        [tblpnls{j},tblout2s{j},statsouts{j}] = charlotte_gensingleassetprofile('assetname',names2use{j},'frequency','daily');
    end
    maxpnldrawdown = zeros(n,1);varpnldrawdown = zeros(n,1);
    varpnl = zeros(n,1);avgpnl = zeros(n,1);stdpnl = zeros(n,1);
    sharpratio = zeros(n,1);
    maxtradepnldrawdown = zeros(n,1);vartradepnldrawdown = zeros(n,1);
    avgtradepnl = zeros(n,1);stdtradepnl = zeros(n,1);
    Ns = zeros(n,1);Ws = zeros(n,1);Rs = zeros(n,1);Ks = zeros(n,1);
    maxretdrawdown = zeros(n,1);varretsdrawdown = zeros(n,1);
    varret = zeros(n,1);avgret = zeros(n,1);stdret = zeros(n,1);
    maxtraderetdrawdown = zeros(n,1);
    vartraderetdrawdown = zeros(n,1);
    for j = 1:n
        maxpnldrawdown(j) = statsouts{j}.maxpnldrawdown;
        varpnldrawdown(j) = statsouts{j}.varpnldrawdown;
        varpnl(j) = statsouts{j}.varpnl;
        avgpnl(j) = statsouts{j}.avgpnl;
        stdpnl(j) = statsouts{j}.stdpnl;
        sharpratio(j) = statsouts{j}.sharpratio;
        maxtradepnldrawdown(j) = statsouts{j}.maxtradepnldrawdown;
        vartradepnldrawdown(j) = statsouts{j}.vartradepnldrawdown;
        avgtradepnl(j) = statsouts{j}.avgtradepnl;
        stdtradepnl(j) = statsouts{j}.stdtradepnl;
        Ns(j) = statsouts{j}.N;
        Ws(j) = statsouts{j}.W;
        Rs(j) = statsouts{j}.R;
        Ks(j) = statsouts{j}.K;
        maxretdrawdown(j) = statsouts{j}.maxretdrawdown;
        varretsdrawdown(j) = statsouts{j}.varretsdrawdown;
        varret(j) = statsouts{j}.varret;
        avgret(j) = statsouts{j}.avgret;
        stdret(j) = statsouts{j}.stdret;
        maxtraderetdrawdown(j) = statsouts{j}.maxtraderetdrawdown;
        vartraderetdrawdown(j) = statsouts{j}.vartraderetdrawdown;
    end
    statsreport_ = table(names_fx,maxpnldrawdown,varpnldrawdown,varpnl,avgpnl,stdpnl,...
        sharpratio,maxtradepnldrawdown,vartradepnldrawdown,avgtradepnl,stdtradepnl,...
        Ns,Ws,Rs,Ks,maxretdrawdown,varretsdrawdown,varret,avgret,stdret,...
        maxtraderetdrawdown,vartraderetdrawdown);
    %
    if i == 1
        save([dir_,'statsreport_pm_daily.mat'],'statsreport_');
        fprintf('stats report of pm saved...\n');
    elseif i == 2
        save([dir_,'statsreport_fx_daily.mat'],'statsreport_');
        fprintf('stats report of fx saved...\n');
    elseif i == 3
        save([dir_,'statsreport_bm_daily.mat'],'statsreport_');
        fprintf('stats report of bm saved...\n');
    elseif i == 4
        save([dir_,'statsreport_ei_daily.mat'],'statsreport_');
        fprintf('stats report of ei saved...\n');
    end
        
    

end
