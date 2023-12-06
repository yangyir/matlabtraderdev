%%
codes_c = {
    'c1901';'c1905';'c1909';...
    'c2001';'c2005';'c2009';...
    'c2101';'c2105';'c2109';...
    'c2201';'c2205';'c2209';...
    'c2301';'c2305';'c2307';'c2309';'c2311';...
    'c2401';...
    };
%
codes_cf = {
    'CF901';'CF905';'CF909';...
    'CF001';'CF005';'CF009';...
    'CF101';'CF105';'CF109';...
    'CF201';'CF205';'CF209';...
    'CF301';'CF305';'CF309';...
    'CF401';...
    };
%
codes_sr = {
    'SR901';'SR905';'SR909';...
    'SR001';'SR005';'SR009';...
    'SR101';'SR105';'SR109';...
    'SR201';'SR205';'SR209';...
    'SR301';'SR303';'SR305';'SR307';'SR309';...
    'SR401';...
    };
%
codes_lh = {
    'lh2109';...
    'lh2201';'lh2203';'lh2205';'lh2209';...
    'lh2301';'lh2305';'lh2307';'lh2309';'lh2311';...
    'lh2401';...
    };
%
output_softagri = fractal_kelly_summary('codes',[codes_c;codes_cf;codes_sr;codes_lh],'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[tc_softagri_i,tb_softagri_i,tbl_softagri_i,k_l_softagri_i,k_s_softagri_i,tblbyasset_l_softagri_i,tblbyasset_s_softagri_i] = kellydistrubitionsummary(output_softagri);
%%
signal_l_valid_softagri = k_l_softagri_i.opensignal_unique_l(logical(k_l_softagri_i.use_unique_l));
signal_s_valid_softagri = k_s_softagri_i.opensignal_unique_s(logical(k_s_softagri_i.use_unique_s));
assetlist_softagri = unique([tblbyasset_l_softagri_i.assetlist;tblbyasset_s_softagri_i.assetlist]);
nasset = size(assetlist_softagri,1);
%
WMat_L_softagri_i = zeros(length(signal_l_valid_softagri),nasset);
RMat_L_softagri_i = WMat_L_softagri_i;
KMat_L_softagri_i = WMat_L_softagri_i;
for i = 1:length(signal_l_valid_softagri)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_softagri,'assetname',assetlist_softagri{j},'direction','l','signalname',signal_l_valid_softagri{i});
        WMat_L_softagri_i(i,j) = ret.W;
        RMat_L_softagri_i(i,j) = ret.R;
        KMat_L_softagri_i(i,j) = ret.K;
    end
end
%
WMat_S_softagri_i = zeros(length(signal_s_valid_softagri),nasset);
RMat_S_softagri_i = WMat_S_softagri_i;
KMat_S_softagri_i = WMat_S_softagri_i;
for i = 1:length(signal_s_valid_softagri)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_softagri,'assetname',assetlist_softagri{j},'direction','s','signalname',signal_s_valid_softagri{i});
        WMat_S_softagri_i(i,j) = ret.W;
        RMat_S_softagri_i(i,j) = ret.R;
        KMat_S_softagri_i(i,j) = ret.K;
    end
end
%
%%
strat_intraday_softagri = struct('tblbyasset_l',tblbyasset_l_softagri_i,...
    'tblbyasset_s',tblbyasset_s_softagri_i,...
    'kelly_table_l',k_l_softagri_i,...
    'kelly_table_s',k_s_softagri_i,...
    tc_softagri_i{1}.name,tc_softagri_i{1}.table,...
    tc_softagri_i{2}.name,tc_softagri_i{2}.table,...
    tc_softagri_i{3}.name,tc_softagri_i{3}.table,...
    tc_softagri_i{4}.name,tc_softagri_i{4}.table,...
    'breachuplvlup_tb',tb_softagri_i{1}.table,...
    'breachdnlvldn_tb',tb_softagri_i{2}.table,...
    'breachupsshighvalue_tb',tb_softagri_i{3}.table,...
    'breachdnbshighvalue_tb',tb_softagri_i{4}.table,...
    'breachuplvlup_tc',tc_softagri_i{5}.table,...
    'breachdnlvldn_tc',tc_softagri_i{6}.table,...
    'breachupsshighvalue_tc',tc_softagri_i{7}.table,...
    'breachdnbshighvalue_tc',tc_softagri_i{8}.table,...
    'breachuphighsc13',tc_softagri_i{9}.table,...
    'breachdnlowbc13',tc_softagri_i{10}.table,...
    'kelly_matrix_l',KMat_L_softagri_i,...
    'kelly_matrix_s',KMat_S_softagri_i,...
    'winprob_matrix_l',WMat_L_softagri_i,...
    'winprob_matrix_s',WMat_S_softagri_i,...
    'signal_l',{signal_l_valid_softagri},...
    'signal_s',{signal_s_valid_softagri},...
    'asset_list',{assetlist_softagri'});
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\softagri\'];
save([dir_,'strat_intraday_softagri.mat'],'strat_intraday_softagri');
fprintf('file saved...\n');