%%
%the following part firstly restruct the data
%0.load data
path = [getenv('onedrive'),'\fractal backtest\'];
filename = 'output_comdtyfut.mat';
data = load([path,filename]);
fprintf('output_comdtyfut loaded...\n');
%1.consolidate all tblb and tbls
tblb_data_consolidated = data.output_comdtyfut.tblb{1};
tbls_data_consolidated = data.output_comdtyfut.tbls{1};
%NOTE:the code above is hard-coded
%********************************************************************
for i = 2:size(data.output_comdtyfut.tblb,1) 
    tempnew = [tblb_data_consolidated;data.output_comdtyfut.tblb{i}];
    tblb_data_consolidated = tempnew;
    tempnew = [tbls_data_consolidated;data.output_comdtyfut.tbls{i}];
    tbls_data_consolidated = tempnew;
end
fprintf('data consolidated...\n');
nb = size(tblb_data_consolidated,1);
ns = size(tbls_data_consolidated,1);
idxb = ones(nb,1);
idxs = ones(ns,1);
for i = 1:nb
    %a.remove trades with unsatified open condition
    %b.remove trades with null pnl
    if ~isempty(tblb_data_consolidated{i,10}),idxb(i) = 0;end
    if isempty(tblb_data_consolidated{i,18}),idxb(i) = 0;end
end
for i = 1:ns
    %a.remove trades with unsatified open condition
    %b.remove trades with null pnl
    if ~isempty(tbls_data_consolidated{i,10}),idxs(i) = 0;end
    if isempty(tbls_data_consolidated{i,18}),idxs(i) = 0;end
end
idxb = logical(idxb);
idxs = logical(idxs);
tblb_data_consolidated = tblb_data_consolidated(idxb,:);
tbls_data_consolidated = tbls_data_consolidated(idxs,:);
%
%2.extract useful information
nb = size(tblb_data_consolidated,1);
opentype_b = zeros(nb,1);%1-weak;2-medium;3-strong
opensignal_b = cell(nb,1);
code_b = cell(nb,1);
assetnam_b = cell(nb,1);
openprice_b = zeros(nb,1);
opennotional_b = zeros(nb,1);
opendatetime_b = zeros(nb,1);
opendate_b = zeros(nb,1);
openid_b = zeros(nb,1);
closestr_b = cell(nb,1);
pnlrel_b = zeros(nb,1);
trendflag_b = zeros(nb,1);

for i = 1:nb
    opentype_b(i) = tblb_data_consolidated{i,2};
    opensignal_b{i} = tblb_data_consolidated{i,11};
    code_b{i} = tblb_data_consolidated{i,14};
    fut = code2instrument(code_b{i});
    assetnam_b{i} = fut.asset_name;
    openprice_b(i) = tblb_data_consolidated{i,17};
    opennotional_b(i) = openprice_b(i)*fut.contract_size;
    opendatetime_b(i) = tblb_data_consolidated{i,13};
    opendate_b(i) = getlastbusinessdate(opendatetime_b(i));
    openid_b(i) = tblb_data_consolidated{i,15};
    closestr_b{i} = tblb_data_consolidated{i,19};
    pnlrel_b(i) = tblb_data_consolidated{i,18}/opennotional_b(i);
    trendflag_b(i) = tblb_data_consolidated{i,37};
end
tbl_extractedinfo_b = table(code_b,assetnam_b,opentype_b,opensignal_b,openid_b,opendatetime_b,opendate_b,openprice_b,opennotional_b,pnlrel_b,closestr_b,trendflag_b);
%
ns = size(tbls_data_consolidated,1);
opentype_s = zeros(ns,1);%1-weak;2-medium;3-strong
opensignal_s = cell(ns,1);
code_s = cell(ns,1);
assetnam_s = cell(ns,1);
openprice_s = zeros(ns,1);
opennotional_s = zeros(ns,1);
opendatetime_s = zeros(ns,1);
opendate_s = zeros(ns,1);
openid_s = zeros(ns,1);
closestr_s = cell(ns,1);
pnlrel_s = zeros(ns,1);
trendflag_s = zeros(ns,1);

for i = 1:ns
    opentype_s(i) = tbls_data_consolidated{i,2};
    opensignal_s{i} = tbls_data_consolidated{i,11};
    code_s{i} = tbls_data_consolidated{i,14};
    fut = code2instrument(code_s{i});
    assetnam_s{i} = fut.asset_name;
    openprice_s(i) = tbls_data_consolidated{i,17};
    opennotional_s(i) = openprice_s(i)*fut.contract_size;
    opendatetime_s(i) = tbls_data_consolidated{i,13};
    opendate_s(i) = getlastbusinessdate(opendatetime_s(i));
    openid_s(i) = tbls_data_consolidated{i,15};
    closestr_s{i} = tbls_data_consolidated{i,19};
    pnlrel_s(i) = tbls_data_consolidated{i,18}/opennotional_s(i);
    trendflag_s(i) = tbls_data_consolidated{i,37};
end
tbl_extractedinfo_s = table(code_s,assetnam_s,opentype_s,opensignal_s,openid_s,opendatetime_s,opendate_s,openprice_s,opennotional_s,pnlrel_s,closestr_s,trendflag_s);
%
%%
% 3. plot bmtc(buy-medium-trendconfirmed),bstc(buy-strong-trendconfirmed)
% and smtc(sell-medium-trendconfirmed),sstc(sell-strong-trendconfirmed)
idx_bmtc = zeros(nb,1);
idx_bstc = zeros(nb,1);
idx_smtc = zeros(ns,1);
idx_sstc = zeros(ns,1);
for i = 1:nb
    if opentype_b(i) == 2 && trendflag_b(i) == 1
        idx_bmtc(i) = 1;
    end
    if opentype_b(i) == 3 && trendflag_b(i) == 1
        idx_bstc(i) = 1;
    end
end
idx_bmtc = logical(idx_bmtc);
idx_bstc = logical(idx_bstc);
for i = 1:ns
    if opentype_s(i) == 2 && trendflag_s(i) == 1
        idx_smtc(i) = 1;
    end
    if opentype_s(i) == 3 && trendflag_s(i) == 1
        idx_sstc(i) = 1;
    end
end
idx_smtc = logical(idx_smtc);
idx_sstc = logical(idx_sstc);
tbl_bmtc = tbl_extractedinfo_b(idx_bmtc,:);
tbl_bstc = tbl_extractedinfo_b(idx_bstc,:);
tbl_smtc = tbl_extractedinfo_s(idx_smtc,:);
tbl_sstc = tbl_extractedinfo_s(idx_sstc,:);
for i = 1:4
    if i == 1
        pnl2check = tbl_bmtc.pnlrel_b;
        figuretitlestr = 'b-medium-trending';
    elseif i == 2
        pnl2check = tbl_bstc.pnlrel_b;
        figuretitlestr = 'b-strong-trending';
    elseif i == 3
        pnl2check = tbl_smtc.pnlrel_s;
        figuretitlestr = 's-medium-trending';
    elseif i == 4
        pnl2check = tbl_sstc.pnlrel_s;
        figuretitlestr = 's-strong-trending';
    end
    [winp_running,R_running,kelly_running] = calcrunningkelly(pnl2check);
    if i == 1
        close all;
        set(0,'defaultfigurewindowstyle','docked');
        fprintf('report of trending trasactions:\n');
        fprintf('\t%20s\t%5s\t%3s%9s\n','type','winp','R','kelly')
    end
    figure(i+1);
    subplot(311);plot(winp_running,'r');title(figuretitlestr);ylabel('win prob');grid on;
    subplot(312);plot(R_running,'b');ylabel('win/loss');grid on;
    subplot(313);plot(kelly_running,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
    fprintf('\t%20s\t%2.1f%%\t%1.1f%8.1f%%\n',figuretitlestr,mean(winp_running(end-99:end))*100,mean(R_running(end-99:end)),mean(kelly_running(end-99:end))*100);
    if i == 4
        fprintf('\n');
    end
end
%%
%4.group by each asset in bmtc,bstc,smtc and sstc
reportbyasset = cell(4,1);
for i = 1:4
    if i == 1
        pnl2check = tbl_bmtc.pnlrel_b;
        asset2check = tbl_bmtc.assetnam_b;
    elseif i == 2
        pnl2check = tbl_bstc.pnlrel_b;
        asset2check = tbl_bstc.assetnam_b;
    elseif i == 3
        pnl2check = tbl_smtc.pnlrel_s;
        asset2check = tbl_smtc.assetnam_s;
    elseif i == 4
        pnl2check = tbl_sstc.pnlrel_s;
        asset2check = tbl_sstc.assetnam_s;
    end
    asset = unique(asset2check);
    nasset = size(asset,1);
    N = zeros(nasset,1);
    W = zeros(nasset,1);
    R = zeros(nasset,1);
    K = zeros(nasset,1);
    runningw = cell(nasset,1);
    ruuningr = cell(nasset,1);
    runningk = cell(nasset,1);
    for j = 1:nasset
        idx_j = strcmpi(asset2check,asset{j});
        pnl_j = pnl2check(idx_j);
        [w_j,r_j,k_j] = calcrunningkelly(pnl_j);
        N(j) = size(w_j,1);
        W(j) = w_j(end);
        R(j) = r_j(end);
        K(j) = k_j(end);
        runningw{j} = w_j;
        ruuningr{j} = r_j;
        runningk{j} = k_j;
    end
    tblreport = table(asset,N,W,R,K);
    tblreport = sortrows(tblreport,'K','descend');
    reportbyasset{i}.table = tblreport;
    reportbyasset{i}.runningw = runningw;
    reportbyasset{i}.runningr = ruuningr;
    reportbyasset{i}.runningk = runningk;
end

%%

direction2check = -1;
signal2check = 'mediumbreach-trendconfirmed';
if direction2check == 1
    if ~strcmpi(signal2check,'all')
        idx2check = strcmpi(tblb_data_consolidated(:,11),signal2check);
        tblb2check = tblb_data_consolidated(idx2check,:);
    else
        tblb2check = tblb_data_consolidated;
    end
else
    if ~strcmpi(signal2check,'all')
        idx2check = strcmpi(tbls_data_consolidated(:,11),signal2check);
        tblb2check = tbls_data_consolidated(idx2check,:);
    else
        tblb2check = tbls_data_consolidated;
    end
end
%1.check whether the win probability converges with the Law of Large Numbers
winp_running = zeros(size(tblb2check,1),1);
winflag = winp_running;
nvalidtrade = 0;
nwintrade = 0;
for i = 1:size(tblb2check,1)
    if isempty(tblb2check{i,18})
        winflag(i,1) = 0;
    else
        nvalidtrade = nvalidtrade + 1;
        if tblb2check{i,18} >= 0
            winflag(i,1) = 1;
            nwintrade = nwintrade + 1;
        else
            winflag(i,1) = 0;
        end
    end
    winflag(i,2) = nvalidtrade;
    winflag(i,3) = nwintrade;
end
for i = 1:size(tblb2check,1)
    winp_running(i) = winflag(i,3)/winflag(i,2);
end
%2.check whether R,i.e.the ratio between win avg pnl and loss avg pnl
%converges with the Law of Large Numbers
winavgpnl_running = zeros(size(tblb2check,1),1);
lossavgpnl_running = zeros(size(tblb2check,1),1);
pnl_ret = zeros(size(tblb2check,1),1);
wintotalpnl = 0;
losstotalpnl = 0;
for i = 1:size(tblb2check,1)
    if ~isempty(tblb2check{i,18})
        fut = code2instrument(tblb2check{i,14});
        pnl_ret(i) = tblb2check{i,18}/tblb2check{i,17}/fut.contract_size;
        if pnl_ret(i) >= 0
            wintotalpnl = wintotalpnl + pnl_ret(i);
        else
            losstotalpnl = losstotalpnl + pnl_ret(i);
        end
    end
    nwin_i = winflag(i,3);
    nloss_i = winflag(i,2) - winflag(i,3);
    winavgpnl_running(i) = wintotalpnl/nwin_i;
    lossavgpnl_running(i) = losstotalpnl/nloss_i;
end
R_running = abs(winavgpnl_running./lossavgpnl_running);
%3.check whether Kelly Criteria converges
kelly_running = winp_running - (1-winp_running)./R_running;
figure(2);
if direction2check == 1
    titlestr = ['long-',signal2check];
else
    titlestr = ['short-',signal2check];
end
subplot(311);plot(winp_running,'r');title(titlestr);ylabel('win prob');grid on;
subplot(312);plot(R_running,'b');ylabel('win/loss');grid on;
subplot(313);plot(kelly_running,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
tbl_output = tblb2check;
for i = 1:size(tbl_output,1)
    tbl_output{i,18} = pnl_ret(i);
end
%%
if direction2check == 1
    tbl2check = data.output_comdtyfut.kellyb(strcmpi(data.output_comdtyfut.kellyb.OpenSignal_L,signal2check),:);
else
    tbl2check = data.output_comdtyfut.kellys(strcmpi(data.output_comdtyfut.kellys.OpenSignal_S,signal2check),:);
end
assets = cell(size(tbl2check,1),1);
for i = 1:size(tbl2check,1)
    if direction2check == 1
        code_i = tbl2check.Code_L{i};
    else
        code_i = tbl2check.Code_S{i};
    end
    asset_i = code2instrument(code_i);
    assets{i} = asset_i.asset_name;
end
assetunique = unique(assets);
winavgunique = zeros(size(assetunique,1),1);
lossavgunique = winavgunique;
runique = winavgunique;
kunique = winavgunique;
wpunique = winavgunique;
nunqiue = winavgunique;
for i = 1:size(assetunique,1)
    idx = strcmpi(assets,assetunique{i});
    tbl_i = tbl2check(idx,:);
    nwin_i = 0;
    ntotal_i = 0;
    wintotalpnl_i = 0;
    losstotalpnl_i = 0;
    for j = 1:size(tbl_i,1)
        if direction2check == 1
            ntotal_i = ntotal_i + tbl_i.NumOfTrades_L{j};
            nwin_i = nwin_i + tbl_i.NumOfTrades_L{j}*tbl_i.WinProb_L{j};
            wintotalpnl_i = wintotalpnl_i + tbl_i.NumOfTrades_L{j}*tbl_i.WinProb_L{j}*tbl_i.WinAvgPnL_L{j};
            losstotalpnl_i = losstotalpnl_i + tbl_i.NumOfTrades_L{j}*(1-tbl_i.WinProb_L{j})*tbl_i.LossAvgPnL_L{j};
        else
            ntotal_i = ntotal_i + tbl_i.NumOfTrades_S{j};
            nwin_i = nwin_i + tbl_i.NumOfTrades_S{j}*tbl_i.WinProb_S{j};
            wintotalpnl_i = wintotalpnl_i + tbl_i.NumOfTrades_S{j}*tbl_i.WinProb_S{j}*tbl_i.WinAvgPnL_S{j};
            losstotalpnl_i = losstotalpnl_i + tbl_i.NumOfTrades_S{j}*(1-tbl_i.WinProb_S{j})*tbl_i.LossAvgPnL_S{j};
        end
    end
    winavgunique(i) = wintotalpnl_i/nwin_i;
    lossavgunique(i) = losstotalpnl_i/(ntotal_i-nwin_i);
    runique(i) = abs(winavgunique(i)/lossavgunique(i));
    wpunique(i) = nwin_i/ntotal_i;
    kunique(i) = wpunique(i) - (1-wpunique(i))/runique(i);
    nunqiue(i) = ntotal_i;
end
tblbyasset = table(assetunique,nunqiue,wpunique,winavgunique,lossavgunique,runique,kunique);
tblbyasset = sortrows(tblbyasset,'kunique','descend');

%%
% regress with dummy variables
y = tbl_output(:,18);
isvolup1 = zeros(size(tbl_output,1),1);
isvolup2 = isvolup1;
isalligatorfailed = isvolup1;
issshighvalue = isvolup1;
issshighbreach = isvolup1;
isschighbreach = isvolup1;
istrend = isvolup1;
isbsreverse = isvolup1;
isbcreverse = isvolup1;

for i = 1:size(tbl_output,1)
    if tbl_output{i,25}
        isvolup1(i) = 1;
    end
    if tbl_output{i,26}
        isvolup2(i) = 1;
    end
    if strcmpi(tbl_output{i,29}, 'jaw<teeth<lips') ||...
            strcmpi(tbl_output{i,29}, 'teeth<jaw<lips') || ...
            strcmpi(tbl_output{i,29}, 'teeth<lips<jaw')
        isalligatorfailed(i) = 0;
    else
        isalligatorfailed(i) = 1;
    end
    if tbl_output{i,32}
        issshighvalue(i) = 1;
    end
    if tbl_output{i,33}
        issshighbreach(i) = 1;
    end
    if tbl_output{i,36}
        isschighbreach(i) = 1;
    end
    if tbl_output{i,37}
        istrend(i) = 1;
    end
    if tbl_output{i,38}
        isbsreverse(i) = 1;
    end
    if tbl_output{i,39}
        isbcreverse(i) = 1;
    end
end
%%
y = pnl_ret;
X = [isvolup1,isvolup2,isalligatorfailed,issshighvalue,issshighbreach,isschighbreach,istrend,isbsreverse,isbcreverse];
mdl = fitlm(X,y,'linear')
%%
code = 'sc2304';
openid_l = 427;
idx_code = -1;
for i = 1:length(codes_all)
    if strcmpi(codes_all{i},code)
        idx_code = i;break
    end
end
code_data = data.output_comdtyfut.data{idx_code};
ret_anyb = fractal_tradeinfo_anyb('code',code,...
    'openid',openid_l,...
    'extrainfo',code_data,...
    'frequency','intraday',...
    'debug',true,...
    'plot',true,...
    'usefractalupdate',0,...
    'usefibonacci',1);
display(ret_anyb);
%%
code = 'c2005';
openid_l = 266;
idx_code = -1;
for i = 1:length(codes_all)
    if strcmpi(codes_all{i},code)
        idx_code = i;break
    end
end
code_data = data.output_comdtyfut.data{idx_code};
ret_anys = fractal_tradeinfo_anys('code',code,...
    'openid',openid_l,...
    'extrainfo',code_data,...
    'frequency','intraday',...
    'debug',true,...
    'plot',true,...
    'usefractalupdate',0,...
    'usefibonacci',1);
display(ret_anys);
%%
signal_l = {'volblowup',0.25;'breachup-lvlup',0.25;'breachup-highsc13',0.25;...
    'breachup-sshighvalue',0.25;'strongbreach-trendconfirmed',0.25;...
    'mediumbreach-trendconfirmed',0.25;'volblowup2',0.25};
signal_s = {'volblowup',0.25;'breachdn-lvldn',0.25;'breachdn-lowbc13',0.25;...
    'breachdn-bshighvalue',0.25;'strongbreach-trendconfirmed',0.25;...
    'mediumbreach-trendconfirmed',0.25;'volblowup2',0.25};
for i = 1:size(signal_l,1)
    if i == 1
        idx_l = strcmpi(tblb_data_consolidated(:,11),signal_l{i,1});
    else
        idx_l = idx_l | strcmpi(tblb_data_consolidated(:,11),signal_l{i,1});
    end    
end
tblb_used = tblb_data_consolidated(idx_l,:);
for i = 1:size(signal_s,1)
    if i == 1
        idx_s = strcmpi(tbls_data_consolidated(:,11),signal_s{i,1});
    else
        idx_s = idx_s | strcmpi(tbls_data_consolidated(:,11),signal_s{i,1});
    end    
end
tbls_used = tbls_data_consolidated(idx_s,:);
tbl_used = [tblb_used;tbls_used];
%
signalname = tbl_used(:,11);
opentime = tbl_used(:,13);
codename = tbl_used(:,14);
openid_b = tbl_used(:,15);
opendirection = tbl_used(:,16);
openprice_b = tbl_used(:,17);
pnlabs = tbl_used(:,18);
pnlret = zeros(size(tbl_used,1),1);
opennotional_b = pnlret;

idxkeep = ones(size(tbl_used,1),1);

for i = 1:size(tbl_used,1)
    if isempty(codename{i}) || isempty(pnlabs{i})
        idxkeep(i) = 0;
    else
        fut = code2instrument(codename{i});
        if ~isempty(pnlabs{i})
            pnlret(i) = pnlabs{i}/openprice_b{i}/fut.contract_size;
            opennotional_b(i) = openprice_b{i}*fut.contract_size;
        else
            opennotional_b(i) = openprice_b{i}*fut.contract_size;
        end
    end
end
idxkeep = logical(idxkeep);
signalname = signalname(idxkeep);
opentime = opentime(idxkeep);opentime = cell2mat(opentime);
codename = codename(idxkeep);
openid_b = openid_b(idxkeep);openid_b = cell2mat(openid_b);
opendirection = opendirection(idxkeep);opendirection = cell2mat(opendirection);
openprice_b = openprice_b(idxkeep);openprice_b = cell2mat(openprice_b);
pnlabs = pnlabs(idxkeep);pnlabs = cell2mat(pnlabs);
pnlret = pnlret(idxkeep);
opennotional_b = opennotional_b(idxkeep);

tblused = table(signalname,opentime,codename,openid_b,opendirection,openprice_b,pnlabs,pnlret,opennotional_b);
tblused = sortrows(tblused,'opentime','ascend');


