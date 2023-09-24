%% run this once a week on weekend
if ~exist('w','var'),w = cWind;end
codes_wind = {
    'AU.SHF';'AG.SHF';...
    'CU.SHF';'AL.SHF';'ZN.SHF';'PB.SHF';'NI.SHF';'SN.SHF';...
    'TA.CZC';'L.DCE';'PP.DCE';'MA.CZC';'ZC.CZC';'SC.INE';'FU.SHF';'PG.DCE';'SA.CZC';'UR.CZC';...
    'SR.CZC';'CF.CZC';'C.DCE';'JD.DCE';'A.DCE';'M.DCE';'LH.DCE';...
    'Y.DCE';'P.DCE';'OI.CZC';'RM.CZC';'AP.CZC';'RU.SHF';...
    'J.DCE';'JM.DCE';'RB.SHF';'I.DCE';'HC.SHF';'FG.CZC';'V.DCE'};
activecodes = cell(length(codes_wind),1);
lastbd = getlastbusinessdate;
lastbdstr = datestr(lastbd,'yyyy-mm-dd');
for i = 1:length(codes_wind)
    [wdata,~,~,~] = w.ds_.wsd(codes_wind{i},'open,high,low,close','2000-01-01',lastbdstr);
    [wdata2,~,~,~] = w.ds_.wsd(codes_wind{i},'trade_hiscode,close','2000-01-01',lastbdstr);
    idx = ~isnan(sum(wdata,2));
    activecodes{i} = wdata2(idx);
end
codes_ctp_list = cell(length(codes_wind),1);
codes_wind_list = cell(length(codes_wind),1);
for i = 1:length(codes_wind)
    temp = unique(activecodes{i});
    temp2 = temp;
    idx = ones(length(temp),1);
    for j = 1:length(temp)
        if isempty(temp{j}), idx(j) = 0;continue;end
        temp{j} = str2ctp(temp{j}(1:end-4));
    end
    idx = logical(idx);
    codes_ctp_list{i} = temp(idx);
    codes_wind_list{i} = temp2(idx);
    fprintf('done with code list of %s\n',codes_wind{i});
end
%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty_domestic\'];
list = struct('asset_shortcode',codes_wind,'codes_ctp_list',codes_ctp_list,'codes_wind_list',codes_wind_list);
save([dir_,'comdty_domestic_list.mat'],'list');
%% run this once a week on weekend
codes_comdty_all = codes_ctp_list{1};
for i = 2:size(codes_ctp_list,1)
    tmp = [codes_comdty_all;codes_ctp_list{i}];
    codes_comdty_all = tmp;
end
idx_use = ones(length(codes_comdty_all),1);
lastbd = getlastbusinessdate;
for i = 1:length(codes_comdty_all)
    fut = code2instrument(codes_comdty_all{i});
    if isempty(fut.last_trade_date1)
        idx_use(i) = 0;
        fprintf('%s not to use as no future info is availabe....\n',codes_comdty_all{i});
        continue;
    end
    d = cDataFileIO.loadDataFromTxtFile([getenv('DATAPATH'),'dailybar\',codes_comdty_all{i},'_daily.txt']);
    if ~isnumeric(d)
        try
            savedailybarfromwind(w,codes_comty_all{i});
            d = cDataFileIO.loadDataFromTxtFile([getenv('DATAPATH'),'dailybar\',codes_comdty_all{i},'_daily.txt']);
            if ~isnumeric(d)
                idx_use(i) = 0;
                fprintf('%s not to use as no data is available....\n',codes_comdty_all{i});
            end
        catch
            idx_use(i) = 0;
            fprintf('%s not to use as no data is available....\n',codes_comdty_all{i});
        end
    else
        if d(end,1) < lastbd && fut.last_trade_date1 > lastbd && d(end,1) < fut.last_trade_date1
            savedailybarfromwind(w,codes_comdty_all{i});
            d = cDataFileIO.loadDataFromTxtFile([getenv('DATAPATH'),'dailybar\',codes_comdty_all{i},'_daily.txt']);
        end
        if size(d,1) < 13
            idx_use(i) = 0;
            fprintf('%s not to use as insuffient data....\n',codes_comdty_all{i});
        end
    end
end
idx_use = logical(idx_use);
codes_comdty_all = codes_comdty_all(idx_use);
%% it takes a long time to run the following code
comdty_domestic_daily = fractal_kelly_summary('codes',codes_comdty_all,'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
yy = year(today);
ww = weeknum(today);
if ww < 10
    tag = [num2str(yy),'w0',num2str(ww)];
else
    tag = [num2str(yy),'w',num2str(ww)];
end
save([dir_,'comdty_domestic_daily_',tag,'.mat'],'comdty_domestic_daily');
%% the following is for data analysis
d = load([dir_,'comdty_domestic_daily_',tag,'.mat']);
props = fields(d);
comdty_domestic_daily = d.(props{1});
%%
kellyb_unique = comdty_domestic_daily.kellyb_unique;
nkellyb = size(kellyb_unique,1);
use_unique_l = nan(nkellyb,1);
opensignal_unique_l =  kellyb_unique.opensignal_l_unique;
ntrades_unique_l = kellyb_unique.ntrades_unique_l;
kelly_unique_l = kellyb_unique.kelly_unique_l;
winp_unique_l = kellyb_unique.winprob_unique_l;
r_unique_l = kellyb_unique.r_unique_l;
winavgpnl_unique_l = kellyb_unique.winavgpnl_unique_l;
lossavgpnl_unique_l = kellyb_unique.lossavgpnl_unique_l;
expectedpnl_unique_l = winp_unique_l.*winavgpnl_unique_l+(1-winp_unique_l).*lossavgpnl_unique_l;
stdevpnl_unique_l = sqrt(winp_unique_l.*winavgpnl_unique_l.^2+(1-winp_unique_l).*lossavgpnl_unique_l.^2-expectedpnl_unique_l.^2);
sharp_unique_l = expectedpnl_unique_l./stdevpnl_unique_l;
for i = 1:nkellyb
    signal_i = opensignal_unique_l{i};
    if strcmpi(signal_i,'mediumbreach-sshighvalue') || strcmpi(signal_i,'breachup-highsc13-negative') || ...
            strcmpi(signal_i,'weakbreach') || strcmpi(signal_i,'strongbreach-trendbreak') || ...
            strcmpi(signal_i,'mediumbreach-trendbreak') || strcmpi(signal_i,'closetolvlup')
        use_unique_l(i) = 0;
    elseif strcmpi(signal_i,'volblowup') || strcmpi(signal_i,'volblowup2') || ...
            strcmpi(signal_i,'breachup-lvlup') || strcmpi(signal_i,'breachup-sshighvalue') || ...
            strcmpi(signal_i,'breachup-highsc13') || strcmpi(signal_i,'strongbreach-trendconfirmed') || ...
            strcmpi(signal_i,'mediumbreach-trendconfirmed')
        use_unique_l(i) = 1;
    else
        if kelly_unique_l(i) >= 0.15 && sharp_unique_l(i) >= 3/sqrt(252) && winp_unique_l(i) >= 0.4
            use_unique_l(i) = 1;
        else
            use_unique_l(i) = 0;
        end
    end
end
kelly_table_l = table(opensignal_unique_l,ntrades_unique_l,winp_unique_l,r_unique_l,kelly_unique_l,sharp_unique_l,use_unique_l);
%
kellys_unique = comdty_domestic_daily.kellys_unique;
nkellys = size(kellys_unique,1);
use_unique_s = nan(nkellys,1);
opensignal_unique_s =  kellys_unique.opensignal_s_unique;
ntrades_unique_s = kellys_unique.ntrades_unique_s;
kelly_unique_s = kellys_unique.kelly_unique_s;
winp_unique_s = kellys_unique.winprob_unique_s;
r_unique_s = kellys_unique.r_unique_s;
winavgpnl_unique_s = kellys_unique.winavgpnl_unique_s;
lossavgpnl_unique_s = kellys_unique.lossavgpnl_unique_s;
expectedpnl_unique_s = winp_unique_s.*winavgpnl_unique_s+(1-winp_unique_s).*lossavgpnl_unique_s;
stdevpnl_unique_s = sqrt(winp_unique_s.*winavgpnl_unique_s.^2+(1-winp_unique_s).*lossavgpnl_unique_s.^2-expectedpnl_unique_s.^2);
sharp_unique_s = expectedpnl_unique_s./stdevpnl_unique_s;
for i = 1:nkellys
    signal_i = opensignal_unique_s{i};
    if strcmpi(signal_i,'mediumbreach-sshighvalue') || strcmpi(signal_i,'breachdn-lowbc13-positive') || ...
            strcmpi(signal_i,'weakbreach') || strcmpi(signal_i,'strongbreach-trendbreak') || ...
            strcmpi(signal_i,'mediumbreach-trendbreak') || strcmpi(signal_i,'closetolvldn')
        use_unique_s(i) = 0;
    elseif strcmpi(signal_i,'volblowup') || strcmpi(signal_i,'volblowup2') || ...
            strcmpi(signal_i,'breachdn-lvldn') || strcmpi(signal_i,'breachdn-bshighvalue') || ...
            strcmpi(signal_i,'breachup-lowbc13') || strcmpi(signal_i,'strongbreach-trendconfirmed') || ...
            strcmpi(signal_i,'mediumbreach-trendconfirmed')
        use_unique_s(i) = 1;
    else
        if kelly_unique_s(i) >= 0.15 && sharp_unique_s(i) >= 3/sqrt(252) && winp_unique_s(i) >= 0.4
            use_unique_s(i) = 1;
        else
            use_unique_s(i) = 0;
        end
    end
end
kelly_table_s = table(opensignal_unique_s,ntrades_unique_s,winp_unique_s,r_unique_s,kelly_unique_s,sharp_unique_s,use_unique_s);
%%
[rp_tc,rp_tb,tbl] = kellydistrubitionsummary(comdty_domestic_daily);
%%
strat_comdty_domestic_daily = struct('kelly_table_l',kelly_table_l,...
    'kelly_table_s',kelly_table_s,...
    rp_tc{1}.name,rp_tc{1}.table,...
    rp_tc{2}.name,rp_tc{2}.table,...
    rp_tc{3}.name,rp_tc{3}.table,...
    rp_tc{4}.name,rp_tc{4}.table,...
    'breachuplvlup_tb',rp_tb{1}.table,...
    'breachdnlvldn_tb',rp_tb{2}.table,...
    'breachupsshighvalue_tb',rp_tb{3}.table,...
    'breachdnbshighvalue_tb',rp_tb{4}.table);
save([dir_,'strat_comdty_domestic_daily_',tag,'.mat'],'strat_comdty_domestic_daily');
%%
signal_l_valid = kelly_table_l.opensignal_unique_l(logical(kelly_table_l.use_unique_l));
signalcolumn = comdty_domestic_daily.kellyb.OpenSignal_L;
signalidx = zeros(length(signalcolumn),1);
for i = 1:length(signalcolumn)
    signalidx(i) = sum(strcmpi(signalcolumn{i},signal_l_valid));
end
signalidx = logical(signalidx);
vlookuptbl_valid_l = comdty_domestic_daily.kellyb(signalidx,:);
ntrades_l = sum(cell2mat(vlookuptbl_valid_l.NumOfTrades_L));  
nwintrades_l = sum(cell2mat(vlookuptbl_valid_l.NumOfTrades_L).*cell2mat(vlookuptbl_valid_l.WinProb_L));
winavgpnl_l = sum(cell2mat(vlookuptbl_valid_l.NumOfTrades_L).*cell2mat(vlookuptbl_valid_l.WinProb_L).*cell2mat(vlookuptbl_valid_l.WinAvgPnL_L))/nwintrades_l;
lossavgpnl_l = sum(cell2mat(vlookuptbl_valid_l.NumOfTrades_L).*(1-cell2mat(vlookuptbl_valid_l.WinProb_L)).*cell2mat(vlookuptbl_valid_l.LossAvgPnL_L))/(ntrades_l-nwintrades_l);
W_L_ALL = nwintrades_l/ntrades_l;
R_L_ALL = abs(winavgpnl_l/lossavgpnl_l);
K_L_ALL = W_L_ALL - (1-W_L_ALL)/R_L_ALL;
%
signal_s_valid = kelly_table_s.opensignal_unique_s(logical(kelly_table_s.use_unique_s));
signalcolumn = comdty_domestic_daily.kellys.OpenSignal_S;
signalidx = zeros(length(signalcolumn),1);
for i = 1:length(signalcolumn)
    signalidx(i) = sum(strcmpi(signalcolumn{i},signal_s_valid));
end
signalidx = logical(signalidx);
vlookuptbl_valid_s = comdty_domestic_daily.kellys(signalidx,:);
ntrades_s = sum(cell2mat(vlookuptbl_valid_s.NumOfTrades_S));
nwintrades_s = sum(cell2mat(vlookuptbl_valid_s.NumOfTrades_S).*cell2mat(vlookuptbl_valid_s.WinProb_S));
winavgpnl_s = sum(cell2mat(vlookuptbl_valid_s.NumOfTrades_S).*cell2mat(vlookuptbl_valid_s.WinProb_S).*cell2mat(vlookuptbl_valid_s.WinAvgPnL_S))/nwintrades_s;
lossavgpnl_s = sum(cell2mat(vlookuptbl_valid_s.NumOfTrades_S).*(1-cell2mat(vlookuptbl_valid_s.WinProb_S)).*cell2mat(vlookuptbl_valid_s.LossAvgPnL_S))/(ntrades_l-nwintrades_s);
W_S_ALL = nwintrades_s/ntrades_s;
R_S_ALL = abs(winavgpnl_s/lossavgpnl_s);
K_S_ALL = W_S_ALL - (1-W_S_ALL)/R_S_ALL;
%
assetcolumn = vlookuptbl_valid_l.Asset_L;
%
assetlist = unique(assetcolumn);
nasset = length(assetlist);
N_L = zeros(nasset+1,1);
W_L = zeros(nasset+1,1);
R_L = zeros(nasset+1,1);
K_L = zeros(nasset+1,1);
for i = 1:nasset
    assetidx = strcmpi(assetcolumn,assetlist{i});
    tbl_i = vlookuptbl_valid_l(assetidx,:);
    ntrades = sum(cell2mat(tbl_i.NumOfTrades_L));
    nwintrades = sum(cell2mat(tbl_i.NumOfTrades_L).*cell2mat(tbl_i.WinProb_L));
    winavgpnl = sum(cell2mat(tbl_i.NumOfTrades_L).*cell2mat(tbl_i.WinProb_L).*cell2mat(tbl_i.WinAvgPnL_L))/nwintrades;
    lossavgpnl = sum(cell2mat(tbl_i.NumOfTrades_L).*(1-cell2mat(tbl_i.WinProb_L)).*cell2mat(tbl_i.LossAvgPnL_L))/(ntrades-nwintrades);
    N_L(i) = ntrades;
    W_L(i) = nwintrades/ntrades;
    R_L(i) = abs(winavgpnl/lossavgpnl);
    K_L(i) = W_L(i) - (1-W_L(i))/R_L(i);
end
assetlist{nasset+1,1} = 'all';
W_L(nasset+1,1) = W_L_ALL;
R_L(nasset+1,1) = R_L_ALL;
K_L(nasset+1,1) = K_L_ALL;
N_L(nasset+1,1) = sum(N_L(1:end-1));
tblbyasset_L = table(assetlist,N_L,W_L,R_L,K_L);
tblbyasset_L = sortrows(tblbyasset_L,'K_L','descend');
%
assetcolumn = vlookuptbl_valid_s.Asset_S;
%
assetlist = unique(assetcolumn);
nasset = length(assetlist);
N_S = zeros(nasset+1,1);
W_S = zeros(nasset+1,1);
R_S = zeros(nasset+1,1);
K_S = zeros(nasset+1,1);
for i = 1:nasset
    assetidx = strcmpi(assetcolumn,assetlist{i});
    tbl_i = vlookuptbl_valid_s(assetidx,:);
    ntrades = sum(cell2mat(tbl_i.NumOfTrades_S));
    nwintrades = sum(cell2mat(tbl_i.NumOfTrades_S).*cell2mat(tbl_i.WinProb_S));
    winavgpnl = sum(cell2mat(tbl_i.NumOfTrades_S).*cell2mat(tbl_i.WinProb_S).*cell2mat(tbl_i.WinAvgPnL_S))/nwintrades;
    lossavgpnl = sum(cell2mat(tbl_i.NumOfTrades_S).*(1-cell2mat(tbl_i.WinProb_S)).*cell2mat(tbl_i.LossAvgPnL_S))/(ntrades-nwintrades);
    N_S(i) = ntrades;
    W_S(i) = nwintrades/ntrades;
    R_S(i) = abs(winavgpnl/lossavgpnl);
    K_S(i) = W_S(i) - (1-W_S(i))/R_S(i);
end
assetlist{nasset+1,1} = 'all';
W_S(nasset+1,1) = W_S_ALL;
R_S(nasset+1,1) = R_S_ALL;
K_S(nasset+1,1) = K_S_ALL;
N_S(nasset+1,1) = sum(N_S(1:end-1));
tblbyasset_S = table(assetlist,N_S,W_S,R_S,K_S);
tblbyasset_S = sortrows(tblbyasset_S,'K_S','descend');

%%
WMat_L = zeros(nasset,length(signal_l_valid));
RMat_L = WMat_L;
KMat_L = WMat_L;
for i = 1:nasset
    for j = 1:length(signal_l_valid)
        ret = kellyempirical('distribution',comdty_domestic_daily,'assetname',assetlist{i},'direction','l','signalname',signal_l_valid{j});
        WMat_L(i,j) = ret.W;
        RMat_L(i,j) = ret.R;
        KMat_L(i,j) = ret.K;
    end
end
%%
WMat_S = zeros(nasset,length(signal_s_valid));
RMat_S = WMat_S;
KMat_S = WMat_S;
for i = 1:nasset
    for j = 1:length(signal_s_valid)
        ret = kellyempirical('distribution',comdty_domestic_daily,'assetname',assetlist{i},'direction','s','signalname',signal_s_valid{j});
        WMat_S(i,j) = ret.W;
        RMat_S(i,j) = ret.R;
        KMat_S(i,j) = ret.K;
    end
end
%%
strat_comdty_domestic_daily2 = struct('assetlist',{assetlist},...
    'signal_l_valid',{signal_l_valid},...
    'w_mat_l',WMat_L,...
    'r_mat_l',RMat_L,...
    'k_mat_l',KMat_L,...
    'signal_s_valid',{signal_s_valid},...
    'w_mat_s',WMat_S,...
    'r_mat_s',RMat_S,...
    'k_mat_s',KMat_S);
save([dir_,'strat_comdty_domestic_daily2_',tag,'.mat'],'strat_comdty_domestic_daily2');
