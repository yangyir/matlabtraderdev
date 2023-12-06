%
codes_ch_eqindex = {'000001.SH';...%'��ָ֤��'
    '000300.SH';...%'����300ָ��'
    '000016.SH';...%'��֤50ָ��'
    '000905.SH';...%'��֤500ָ��'
    '000852.SH';...%'��֤1000ָ��'
    '399006.SZ';...%'��ҵ��ָ��'
    '000688.SH';...%'�ƴ�50ָ��'
    '000015.SH';...%'����ָ��'
    };

output_eqindexcn = fractal_kelly_summary('codes',codes_ch_eqindex,'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[tc_eqindexcn,tb_eqindexcn,tbl_eqindexcn,k_l_eqindexcn,k_s_eqindexcn,tblbyasset_l_eqindexcn,tblbyasset_s_eqindexcn] = kellydistrubitionsummary(output_eqindexcn);
%%
signal_l_valid_eqindexcn = k_l_eqindexcn.opensignal_unique_l(logical(k_l_eqindexcn.use_unique_l));
signal_s_valid_eqindexcn = k_s_eqindexcn.opensignal_unique_s(logical(k_s_eqindexcn.use_unique_s));
assetlist_eqindexcn = unique([tblbyasset_l_eqindexcn.assetlist;tblbyasset_s_eqindexcn.assetlist]);
nasset = size(assetlist_eqindexcn,1);
%
WMat_L_eqindexcn = zeros(length(signal_l_valid_eqindexcn),nasset);
RMat_L_eqindexcn = WMat_L_eqindexcn;
KMat_L_eqindexcn = WMat_L_eqindexcn;
for i = 1:length(signal_l_valid_eqindexcn)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_eqindexcn,'assetname',assetlist_eqindexcn{j},'direction','l','signalname',signal_l_valid_eqindexcn{i});
        WMat_L_eqindexcn(i,j) = ret.W;
        RMat_L_eqindexcn(i,j) = ret.R;
        KMat_L_eqindexcn(i,j) = ret.K;
    end
end
%
WMat_S_eqindexcn = zeros(length(signal_s_valid_eqindexcn),nasset);
RMat_S_eqindexcn = WMat_S_eqindexcn;
KMat_S_eqindexcn = WMat_S_eqindexcn;
for i = 1:length(signal_s_valid_eqindexcn)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_eqindexcn,'assetname',assetlist_eqindexcn{j},'direction','s','signalname',signal_s_valid_eqindexcn{i});
        WMat_S_eqindexcn(i,j) = ret.W;
        RMat_S_eqindexcn(i,j) = ret.R;
        KMat_S_eqindexcn(i,j) = ret.K;
    end
end
%
%%
strat_daily_eqindexcn = struct('tblbyasset_l',tblbyasset_l_eqindexcn,...
    'tblbyasset_s',tblbyasset_s_eqindexcn,...
    'kelly_table_l',k_l_eqindexcn,...
    'kelly_table_s',k_s_eqindexcn,...
    tc_eqindexcn{1}.name,tc_eqindexcn{1}.table,...
    tc_eqindexcn{2}.name,tc_eqindexcn{2}.table,...
    tc_eqindexcn{3}.name,tc_eqindexcn{3}.table,...
    tc_eqindexcn{4}.name,tc_eqindexcn{4}.table,...
    'breachuplvlup_tb',tb_eqindexcn{1}.table,...
    'breachdnlvldn_tb',tb_eqindexcn{2}.table,...
    'breachupsshighvalue_tb',tb_eqindexcn{3}.table,...
    'breachdnbshighvalue_tb',tb_eqindexcn{4}.table,...
    'breachuplvlup_tc',tb_eqindexcn{5}.table,...
    'breachdnlvldn_tc',tb_eqindexcn{6}.table,...
    'breachupsshighvalue_tc',tb_eqindexcn{7}.table,...
    'breachdnbshighvalue_tc',tb_eqindexcn{8}.table,...
    'kelly_matrix_l',KMat_L_eqindexcn,...
    'kelly_matrix_s',KMat_S_eqindexcn,...
    'winprob_matrix_l',WMat_L_eqindexcn,...
    'winprob_matrix_s',WMat_S_eqindexcn,...
    'signal_l',{signal_l_valid_eqindexcn},...
    'signal_s',{signal_s_valid_eqindexcn},...
    'asset_list',{assetlist_eqindexcn'});
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexcn\'];
save([dir_,'strat_daily_eqindexcn.mat'],'strat_daily_eqindexcn');
fprintf('file saved...\n');