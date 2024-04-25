%
% codes_IF = {'IF2001';'IF2002';'IF2003';'IF2004';'IF2005';'IF2006';'IF2007';'IF2008';'IF2009';'IF2010';'IF2011';'IF2012';...
%     'IF2101';'IF2102';'IF2103';'IF2104';'IF2105';'IF2106';'IF2107';'IF2108';'IF2109';'IF2110';'IF2111';'IF2112';...
%     'IF2201';'IF2202';'IF2203';'IF2204';'IF2205';'IF2206';'IF2207';'IF2208';'IF2209';'IF2210';'IF2211';'IF2212';...
%     'IF2301';'IF2302';'IF2303';'IF2304';'IF2305';'IF2306';'IF2307';'IF2308';'IF2309';'IF2310';'IF2311';'IF2312';...
%     };
% %
% codes_IH = {'IH2001';'IH2002';'IH2003';'IH2004';'IH2005';'IH2006';'IH2007';'IH2008';'IH2009';'IH2010';'IH2011';'IH2012';...
%     'IH2101';'IH2102';'IH2103';'IH2104';'IH2105';'IH2106';'IH2107';'IH2108';'IH2109';'IH2110';'IH2111';'IH2112';...
%     'IH2201';'IH2202';'IH2203';'IH2204';'IH2205';'IH2206';'IH2207';'IH2208';'IH2209';'IH2210';'IH2211';'IH2212';...
%     'IH2301';'IH2302';'IH2303';'IH2304';'IH2305';'IH2306';'IH2307';'IH2308';'IH2309';'IH2310';'IH2311';'IH2312';...
%     };
% %
% codes_IC = {'IC2001';'IC2002';'IC2003';'IC2004';'IC2005';'IC2006';'IC2007';'IC2008';'IC2009';'IC2010';'IC2011';'IC2012';...
%     'IC2101';'IC2102';'IC2103';'IC2104';'IC2105';'IC2106';'IC2107';'IC2108';'IC2109';'IC2110';'IC2111';'IC2112';...
%     'IC2201';'IC2202';'IC2203';'IC2204';'IC2205';'IC2206';'IC2207';'IC2208';'IC2209';'IC2210';'IC2211';'IC2212';...
%     'IC2301';'IC2302';'IC2303';'IC2304';'IC2305';'IC2306';'IC2307';'IC2308';'IC2309';'IC2310';'IC2311';'IC2312';...
%     };
% %
% codes_IM = {'IM2209';'IM2210';'IM2211';'IM2212';...
%     'IM2301';'IM2302';'IM2303';'IM2304';'IM2305';'IM2306';'IM2307';'IM2308';'IM2309';'IM2310';'IM2311';'IM2312';...
%     };

codes_eqindex = cell(10000,1);
ncodes = 0;
categories = {'eqindex'};



folder_eqindex = [getenv('onedrive'),'\matlabdev\eqindex\'];
listing_eqindex = dir(folder_eqindex);
subfolder_eqindex = cell(size(listing_eqindex,1)-2,1);
for j = 3:size(listing_eqindex,1)
    subfolder_eqindex = [folder_eqindex,listing_eqindex(j).name,'\'];
    listing_ij = dir(subfolder_eqindex);
    for k = 3:size(listing_ij)
        ncodes = ncodes + 1;
        fn_ij = listing_ij(k).name;
        codes_eqindex{ncodes,1} = fn_ij(1:end-4);
    end
end

codes_eqindex = codes_eqindex(1:ncodes,:);
%%
output_eqindexfut = fractal_kelly_summary('codes',[codes_IF;codes_IH;codes_IC;codes_IM],'frequency','intraday','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[tc_eqindexfut_i,tb_eqindexfut_i,tbl_eqindexfut_i,k_l_eqindexfut_i,k_s_eqindexfut_i,tblbyasset_l_eqindexfut_i,tblbyasset_s_eqindexfut_i] = kellydistributionsummary(output_eqindexfut);
%%
signal_l_valideqindex = k_l_eqindexfut_i.opensignal_unique_l(logical(k_l_eqindexfut_i.use_unique_l));
signal_s_valideqindex = k_s_eqindexfut_i.opensignal_unique_s(logical(k_s_eqindexfut_i.use_unique_s));
assetlisteqindex = unique([tblbyasset_l_eqindexfut_i.assetlist;tblbyasset_s_eqindexfut_i.assetlist]);
nasset = size(assetlisteqindex,1);
%
WMat_L_eqindexfut_i = zeros(length(signal_l_valideqindex),nasset);
RMat_L_eqindexfut_i = WMat_L_eqindexfut_i;
KMat_L_eqindexfut_i = WMat_L_eqindexfut_i;
for i = 1:length(signal_l_valideqindex)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_eqindexfut,'assetname',assetlisteqindex{j},'direction','l','signalname',signal_l_valideqindex{i});
        WMat_L_eqindexfut_i(i,j) = ret.W;
        RMat_L_eqindexfut_i(i,j) = ret.R;
        KMat_L_eqindexfut_i(i,j) = ret.K;
    end
end
%
WMat_S_eqindexfut_i = zeros(length(signal_s_valideqindex),nasset);
RMat_S_eqindexfut_i = WMat_S_eqindexfut_i;
KMat_S_eqindexfut_i = WMat_S_eqindexfut_i;
for i = 1:length(signal_s_valideqindex)
    for j = 1:nasset
        ret = kellyempirical('distribution',output_eqindexfut,'assetname',assetlisteqindex{j},'direction','s','signalname',signal_s_valideqindex{i});
        WMat_S_eqindexfut_i(i,j) = ret.W;
        RMat_S_eqindexfut_i(i,j) = ret.R;
        KMat_S_eqindexfut_i(i,j) = ret.K;
    end
end
%
%%
strat_intraday_eqindexfut = struct('tblbyasset_l',tblbyasset_l_eqindexfut_i,...
    'tblbyasset_s',tblbyasset_s_eqindexfut_i,...
    'kelly_table_l',k_l_eqindexfut_i,...
    'kelly_table_s',k_s_eqindexfut_i,...
    tc_eqindexfut_i{1}.name,tc_eqindexfut_i{1}.table,...
    tc_eqindexfut_i{2}.name,tc_eqindexfut_i{2}.table,...
    tc_eqindexfut_i{3}.name,tc_eqindexfut_i{3}.table,...
    tc_eqindexfut_i{4}.name,tc_eqindexfut_i{4}.table,...
    'breachuplvlup_tb',tb_eqindexfut_i{1}.table,...
    'breachdnlvldn_tb',tb_eqindexfut_i{2}.table,...
    'breachupsshighvalue_tb',tb_eqindexfut_i{3}.table,...
    'breachdnbshighvalue_tb',tb_eqindexfut_i{4}.table,...
    'breachuplvlup_tc',tc_eqindexfut_i{5}.table,...
    'breachdnlvldn_tc',tc_eqindexfut_i{6}.table,...
    'breachupsshighvalue_tc',tc_eqindexfut_i{7}.table,...
    'breachdnbshighvalue_tc',tc_eqindexfut_i{8}.table,...
    'breachuphighsc13',tc_eqindexfut_i{9}.table,...
    'breachdnlowbc13',tc_eqindexfut_i{10}.table,...
    'kelly_matrix_l',KMat_L_eqindexfut_i,...
    'kelly_matrix_s',KMat_S_eqindexfut_i,...
    'winprob_matrix_l',WMat_L_eqindexfut_i,...
    'winprob_matrix_s',WMat_S_eqindexfut_i,...
    'signal_l',{signal_l_valideqindex},...
    'signal_s',{signal_s_valideqindex},...
    'asset_list',{assetlisteqindex'});
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\'];
save([dir_,'strat_intraday_eqindexfut.mat'],'strat_intraday_eqindexfut');
fprintf('file saved...\n');
%%
[tbl_report_eqindex_i,stats_report_eqindex_i] = kellydistributionreport(tbl_eqindexfut_i,strat_intraday_eqindexfut);