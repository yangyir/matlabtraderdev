names_fx = {'usdx';'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';...
    'eurjpy';'eurchf';'gbpeur';'gbpjpy';'audjpy';...
    'usdcnh'};

output_daily_fx = fractal_kelly_summary('codes',names_fx,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[rp_tc_fx,rp_tb_fx,tbl_fx,k_l_fx,k_s_fx,tblbyasset_l_fx,tblbyasset_s_fx] = kellydistrubitionsummary(output_daily_fx);
%%
signal_l_valid_fx = k_l_fx.opensignal_unique_l(logical(k_l_fx.use_unique_l));
signal_s_valid_fx = k_s_fx.opensignal_unique_s(logical(k_s_fx.use_unique_s));
assetlist_fx = unique([tblbyasset_l_fx.assetlist;tblbyasset_s_fx.assetlist]);
nasset = size(assetlist_fx,1);
%%
WMat_L = zeros(length(signal_l_valid_fx),nasset);
RMat_L = WMat_L;
KMat_L = WMat_L;
for i = 1:length(signal_l_valid_fx)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_daily_fx,'assetname',assetlist_fx{j},'direction','l','signalname',signal_l_valid_fx{i});
        WMat_L(i,j) = ret.W;
        RMat_L(i,j) = ret.R;
        KMat_L(i,j) = ret.K;
    end
end
%%
WMat_S = zeros(length(signal_s_valid_fx),nasset);
RMat_S = WMat_S;
KMat_S = WMat_S;
for i = 1:length(signal_s_valid_fx)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_daily_fx,'assetname',assetlist_fx{j},'direction','s','signalname',signal_s_valid_fx{i});
        WMat_S(i,j) = ret.W;
        RMat_S(i,j) = ret.R;
        KMat_S(i,j) = ret.K;
    end
end
%%
strat_fx_daily = struct('tblbyasset_l',tblbyasset_l_fx,...
    '


'kelly_table_l',kelly_table_l,...
    'kelly_table_s',kelly_table_s,...
    rp_tc_fx{1}.name,rp_tc_fx{1}.table,...
    rp_tc_fx{2}.name,rp_tc_fx{2}.table,...
    rp_tc_fx{3}.name,rp_tc_fx{3}.table,...
    rp_tc_fx{4}.name,rp_tc_fx{4}.table,...
    'breachuplvlup_tb',rp_tb_fx{1}.table,...
    'breachdnlvldn_tb',rp_tb_fx{2}.table,...
    'breachupsshighvalue_tb',rp_tb_fx{3}.table,...
    'breachdnbshighvalue_tb',rp_tb_fx{4}.table);

%%