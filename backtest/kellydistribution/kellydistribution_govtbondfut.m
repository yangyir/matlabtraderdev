codes_TF = {
    'TF1403';'TF1406';'TF1409';'TF1412';...
    'TF1503';'TF1506';'TF1509';'TF1512';...
    'TF1603';'TF1606';'TF1609';'TF1612';...
    'TF1703';'TF1706';'TF1709';'TF1712';...
    'TF1803';'TF1806';'TF1809';'TF1812';...
    'TF1903';'TF1906';'TF1909';'TF1912';...
    'TF2003';'TF2006';'TF2009';'TF2012';...
    'TF2103';'TF2106';'TF2109';'TF2112';...
    'TF2203';'TF2206';'TF2209';'TF2212';...
    'TF2303';'TF2306';'TF2309';'TF2312';...
    };

codes_T = {'T1509';'T1512';...
    'T1603';'T1606';'T1609';'T1612';...
    'T1703';'T1706';'T1709';'T1712';...
    'T1803';'T1806';'T1809';'T1812';...
    'T1903';'T1906';'T1909';'T1912';...
    'T2003';'T2006';'T2009';'T2012';...
    'T2103';'T2106';'T2109';'T2112';...
    'T2203';'T2206';'T2209';'T2212';...
    'T2303';'T2306';'T2309';'T2312';...
    };
codes_TL = {'TL2309';'TL2312'};
%
output_govtbondfut = fractal_kelly_summary('codes',[codes_TF;codes_T;codes_TL],'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[~,tblb_data,~,tbls_data,data,tradesb,tradess,validtradesb,validtradess,kellyb,kellys] = fractal_gettradesummary('TF1806',...
            'frequency','daily',...
            'usefractalupdate',0,...
            'usefibonacci',1,...
            'direction','both');
%%
[tc_govtbondfut,tb_govtbondfut,tbl_govtbondfut,k_l_govtbondfut,k_s_govtbondfut,tblbyasset_l_govtbondfut,tblbyasset_s_govtbondfut] = kellydistrubitionsummary(output_govtbondfut);
%%
signal_l_valid_govtbondfut = k_l_govtbondfut.opensignal_unique_l(logical(k_l_govtbondfut.use_unique_l));
signal_s_valid_govtbondfut = k_s_govtbondfut.opensignal_unique_s(logical(k_s_govtbondfut.use_unique_s));
assetlist_govtbondfut = unique([tblbyasset_l_govtbondfut.assetlist;tblbyasset_s_govtbondfut.assetlist]);
nasset = size(assetlist_govtbondfut,1);
%
WMat_L_govtbondfut = zeros(length(signal_l_valid_govtbondfut),nasset);
RMat_L_govtbondfut = WMat_L_govtbondfut;
KMat_L_govtbondfut = WMat_L_govtbondfut;
for i = 1:length(signal_l_valid_govtbondfut)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_govtbondfut,'assetname',assetlist_govtbondfut{j},'direction','l','signalname',signal_l_valid_govtbondfut{i});
        WMat_L_govtbondfut(i,j) = ret.W;
        RMat_L_govtbondfut(i,j) = ret.R;
        KMat_L_govtbondfut(i,j) = ret.K;
    end
end
%
WMat_S_govtbondfut = zeros(length(signal_s_valid_govtbondfut),nasset);
RMat_S_govtbondfut = WMat_S_govtbondfut;
KMat_S_govtbondfut = WMat_S_govtbondfut;
for i = 1:length(signal_s_valid_govtbondfut)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_govtbondfut,'assetname',assetlist_govtbondfut{j},'direction','s','signalname',signal_s_valid_govtbondfut{i});
        WMat_S_govtbondfut(i,j) = ret.W;
        RMat_S_govtbondfut(i,j) = ret.R;
        KMat_S_govtbondfut(i,j) = ret.K;
    end
end
%
%%
strat_intraday_govtbondfut = struct('tblbyasset_l',tblbyasset_l_govtbondfut,...
    'tblbyasset_s',tblbyasset_s_govtbondfut,...
    'kelly_table_l',k_l_govtbondfut,...
    'kelly_table_s',k_s_govtbondfut,...
    tc_govtbondfut{1}.name,tc_govtbondfut{1}.table,...
    tc_govtbondfut{2}.name,tc_govtbondfut{2}.table,...
    tc_govtbondfut{3}.name,tc_govtbondfut{3}.table,...
    tc_govtbondfut{4}.name,tc_govtbondfut{4}.table,...
    'breachuplvlup_tb',tb_govtbondfut{1}.table,...
    'breachdnlvldn_tb',tb_govtbondfut{2}.table,...
    'breachupsshighvalue_tb',tb_govtbondfut{3}.table,...
    'breachdnbshighvalue_tb',tb_govtbondfut{4}.table,...
    'breachuplvlup_tc',tb_govtbondfut{5}.table,...
    'breachdnlvldn_tc',tb_govtbondfut{6}.table,...
    'breachupsshighvalue_tc',tb_govtbondfut{7}.table,...
    'breachdnbshighvalue_tc',tb_govtbondfut{8}.table,...
    'kelly_matrix_l',KMat_L_govtbondfut,...
    'kelly_matrix_s',KMat_S_govtbondfut,...
    'winprob_matrix_l',WMat_L_govtbondfut,...
    'winprob_matrix_s',WMat_S_govtbondfut,...
    'signal_l',{signal_l_valid_govtbondfut},...
    'signal_s',{signal_s_valid_govtbondfut},...
    'asset_list',{assetlist_govtbondfut'});
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\'];
save([dir_,'strat_daily_govtbondfut.mat'],'strat_daily_govtbondfut');
fprintf('file saved...\n');