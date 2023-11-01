%%
codes_j = {
    'j1901';'j1905';'j1909';...
    'j2001';'j2005';'j2009';...
    'j2101';'j2105';'j2109';...
    'j2201';'j2205';'j2209';...
    'j2301';'j2305';'j2309';...
    'j2401';...
    };
%
codes_jm = {
    'jm1901';'jm1905';'jm1909';...
    'jm2001';'jm2005';'jm2009';...
    'jm2101';'jm2105';'jm2109';...
    'jm2201';'jm2205';'jm2209';...
    'jm2301';'jm2305';'jm2309';...
    'jm2401';...
    };
%
codes_i = {
    'i1901';'i1905';'i1909';...
    'i2001';'i2005';'i2009';...
    'i2101';'i2105';'i2109';...
    'i2201';'i2205';'i2209';...
    'i2301';'i2305';'i2309';...
    'i2401';...
    };
%
codes_rb = {
    'rb1901';'rb1905';'rb1910';...
    'rb2001';'rb2005';'rb2010';...
    'rb2101';'rb2105';'rb2110';...
    'rb2201';'rb2205';'rb2210';...
    'rb2301';'rb2305';'rb2310';...
    'rb2401';...
    };
%
codes_hc = {
    'hc1901';'hc1905';'hc1910';...
    'hc2001';'hc2005';'hc2010';...
    'hc2101';'hc2105';'hc2110';...
    'hc2201';'hc2205';'hc2210';...
    'hc2301';'hc2305';'hc2310';...
    'hc2401';...
    };
%
output_blackmetal = fractal_kelly_summary('codes',[codes_j;codes_jm;codes_i;codes_rb;codes_hc],'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[tc_blackmetal_i,tb_blackmetal_i,tbl_blackmetal_i,k_l_blackmetal_i,k_s_blackmetal_i,tblbyasset_l_blackmetal_i,tblbyasset_s_blackmetal_i] = kellydistrubitionsummary(output_blackmetal);
%%
signal_l_valid_blackmetal = k_l_blackmetal_i.opensignal_unique_l(logical(k_l_blackmetal_i.use_unique_l));
signal_s_valid_blackmetal = k_s_blackmetal_i.opensignal_unique_s(logical(k_s_blackmetal_i.use_unique_s));
assetlist_blackmetal = unique([tblbyasset_l_blackmetal_i.assetlist;tblbyasset_s_blackmetal_i.assetlist]);
nasset = size(assetlist_blackmetal,1);
%
WMat_L_blackmetal_i = zeros(length(signal_l_valid_blackmetal),nasset);
RMat_L_blackmetal_i = WMat_L_blackmetal_i;
KMat_L_blackmetal_i = WMat_L_blackmetal_i;
for i = 1:length(signal_l_valid_blackmetal)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_blackmetal,'assetname',assetlist_blackmetal{j},'direction','l','signalname',signal_l_valid_blackmetal{i});
        WMat_L_blackmetal_i(i,j) = ret.W;
        RMat_L_blackmetal_i(i,j) = ret.R;
        KMat_L_blackmetal_i(i,j) = ret.K;
    end
end
%
WMat_S_blackmetal_i = zeros(length(signal_s_valid_blackmetal),nasset);
RMat_S_blackmetal_i = WMat_S_blackmetal_i;
KMat_S_blackmetal_i = WMat_S_blackmetal_i;
for i = 1:length(signal_s_valid_blackmetal)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_blackmetal,'assetname',assetlist_blackmetal{j},'direction','s','signalname',signal_s_valid_blackmetal{i});
        WMat_S_blackmetal_i(i,j) = ret.W;
        RMat_S_blackmetal_i(i,j) = ret.R;
        KMat_S_blackmetal_i(i,j) = ret.K;
    end
end
%
%%
strat_intraday_blackmetal = struct('tblbyasset_l',tblbyasset_l_blackmetal_i,...
    'tblbyasset_s',tblbyasset_s_blackmetal_i,...
    'kelly_table_l',k_l_blackmetal_i,...
    'kelly_table_s',k_s_blackmetal_i,...
    tc_blackmetal_i{1}.name,tc_blackmetal_i{1}.table,...
    tc_blackmetal_i{2}.name,tc_blackmetal_i{2}.table,...
    tc_blackmetal_i{3}.name,tc_blackmetal_i{3}.table,...
    tc_blackmetal_i{4}.name,tc_blackmetal_i{4}.table,...
    'breachuplvlup_tb',tb_blackmetal_i{1}.table,...
    'breachdnlvldn_tb',tb_blackmetal_i{2}.table,...
    'breachupsshighvalue_tb',tb_blackmetal_i{3}.table,...
    'breachdnbshighvalue_tb',tb_blackmetal_i{4}.table,...
    'breachuplvlup_tc',tb_blackmetal_i{5}.table,...
    'breachdnlvldn_tc',tb_blackmetal_i{6}.table,...
    'breachupsshighvalue_tc',tb_blackmetal_i{7}.table,...
    'breachdnbshighvalue_tc',tb_blackmetal_i{8}.table,...
    'kelly_matrix_l',KMat_L_blackmetal_i,...
    'kelly_matrix_s',KMat_S_blackmetal_i,...
    'winprob_matrix_l',WMat_L_blackmetal_i,...
    'winprob_matrix_s',WMat_S_blackmetal_i,...
    'signal_l',{signal_l_valid_blackmetal},...
    'signal_s',{signal_s_valid_blackmetal},...
    'asset_list',{assetlist_blackmetal'});
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\blackmetal\'];
save([dir_,'strat_intraday_blackmetal.mat'],'strat_intraday_blackmetal');
fprintf('file saved...\n');
