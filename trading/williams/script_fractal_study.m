path = [getenv('onedrive'),'\fractal backtest\'];
filename = 'output_comdtyfut.mat';
data = load([path,filename]);
fprintf('output_comdtyfut loaded...\n');

%%
for i = 1:size(data.output_comdtyfut.tblb,1) 
    if i == 1
        tblb_data_combo = data.output_comdtyfut.tblb{i};
        tbls_data_combo = data.output_comdtyfut.tbls{i};
    else
        tempnew = [tblb_data_combo;data.output_comdtyfut.tblb{i}];
        tblb_data_combo = tempnew;
        tempnew = [tbls_data_combo;data.output_comdtyfut.tbls{i}];
        tbls_data_combo = tempnew;
    end
end
fprintf('data consolidated...\n');
%%
direction2check = -1;
signal2check = 'mediumbreach-trendconfirmed';
if direction2check == 1
    if ~strcmpi(signal2check,'all')
        idx2check = strcmpi(tblb_data_combo(:,11),signal2check);
        tblb2check = tblb_data_combo(idx2check,:);
    else
        tblb2check = tblb_data_combo;
    end
else
    if ~strcmpi(signal2check,'all')
        idx2check = strcmpi(tbls_data_combo(:,11),signal2check);
        tblb2check = tbls_data_combo(idx2check,:);
    else
        tblb2check = tbls_data_combo;
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