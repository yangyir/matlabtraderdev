function [res,tblselected] = charlotte_table_trendanalysis2(inputtable,inputmode,strattable)
%long trend modes:
modes_l = {'bmtc';'bstc';'breachup-lvlup';'breachup-sshighvalue';'breachup-highsc13'};
%short trend
modes_s = {'smtc';'sstc';'breachdn-lvldn';'breachdn-bshighvalue';'breachdn-lowbc13'};

inputcode = inputtable.code{1};


if strcmpi(inputmode,'bmtc')
    modes = {'bmtc';'mediumbreach-trendconfirmed';'volblowup';'volblowup2';'conditional-uptrendconfirmed';'bmtc-all'};
    %
    idx_1 = inputtable.direction == 1 & ...
    strcmpi(inputtable.tradername,'medium') & ...
    (strcmpi(inputtable.opensignal,'mediumbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
    output_1 = kellyratio2(inputtable.pnlrel(idx_1,:));
    p_empirical = zeros(length(modes),1);k_empirical = p_empirical;n_empirical = k_empirical;wa_empirical = k_empirical;la_empirical = wa_empirical;
    p_calib = p_empirical;k_calib = p_calib;n_calib = p_calib;wa_calib = k_calib;la_calib = wa_calib;
    n_empirical(1) = output_1.n;
    p_empirical(1) = output_1.w;
    k_empirical(1) = output_1.k;
    wa_empirical(1) = output_1.winavg;
    la_empirical(1) = output_1.lossavg;
    n_calib(1) = strattable.bmtc.N(strcmpi(strattable.bmtc.asset,inputcode));
    p_calib(1) = strattable.bmtc.W(strcmpi(strattable.bmtc.asset,inputcode));
    k_calib(1) = strattable.bmtc.K(strcmpi(strattable.bmtc.asset,inputcode));
    try
        wa_calib(1) = strattable.bmtc.winavg(strcmpi(strattable.bmtc.asset,inputcode));
        la_calib(1) = strattable.bmtc.lossavg(strcmpi(strattable.bmtc.asset,inputcode));
    catch
        wa_calib(1) = NaN;
        la_calib(1) = NaN;
    end
    %
    %
    idx_2 = inputtable.direction == 1 & ...
        strcmpi(inputtable.tradername,'medium') & ...
        strcmpi(inputtable.opensignal,'mediumbreach-trendconfirmed');
    output_2 = kellyratio2(inputtable.pnlrel(idx_2,:));
    n_empirical(2) = output_2.n;
    p_empirical(2) = output_2.w;
    k_empirical(2) = output_2.k;
    wa_empirical(2) = output_2.winavg;
    la_empirical(2) = output_2.lossavg;
    n_calib(2) = NaN;
    p_calib(2) = kelly_w('mediumbreach-trendconfirmed',inputcode,strattable.signal_l,strattable.asset_list,strattable.winprob_matrix_l);
    k_calib(2) = kelly_k('mediumbreach-trendconfirmed',inputcode,strattable.signal_l,strattable.asset_list,strattable.kelly_matrix_l);
    wa_calib(2) = NaN;
    la_calib(2) = NaN;
    %
    %
    idx_3 = inputtable.direction == 1 & ...
        strcmpi(inputtable.tradername,'medium') & ...
        strcmpi(inputtable.opensignal,'volblowup');
    output_3 = kellyratio2(inputtable.pnlrel(idx_3,:));
    n_empirical(3) = output_3.n;
    p_empirical(3) = output_3.w;
    k_empirical(3) = output_3.k;
    wa_empirical(3) = output_3.winavg;
    la_empirical(3) = output_3.lossavg;
    n_calib(3) = NaN;
    p_calib(3) = kelly_w('volblowup',inputcode,strattable.signal_l,strattable.asset_list,strattable.winprob_matrix_l);
    k_calib(3) = kelly_k('volblowup',inputcode,strattable.signal_l,strattable.asset_list,strattable.kelly_matrix_l);
    wa_calib(3) = NaN;
    la_calib(3) = NaN;
    %
    %
    idx_4 = inputtable.direction == 1 & ...
        strcmpi(inputtable.tradername,'medium') & ...
        strcmpi(inputtable.opensignal,'volblowup2');
    output_4 = kellyratio2(inputtable.pnlrel(idx_4,:));
    n_empirical(4) = output_4.n;
    p_empirical(4) = output_4.w;
    k_empirical(4) = output_4.k;
    wa_empirical(4) = output_4.winavg;
    la_empirical(4) = output_4.lossavg;
    n_calib(4) = NaN;
    p_calib(4) = kelly_w('volblowup2',inputcode,strattable.signal_l,strattable.asset_list,strattable.winprob_matrix_l);
    k_calib(4) = kelly_k('volblowup2',inputcode,strattable.signal_l,strattable.asset_list,strattable.kelly_matrix_l);
    wa_calib(4) = NaN;
    la_calib(4) = NaN;
    %
    %
    idx_5 = inputtable.direction == 1 & ...
        strcmpi(inputtable.tradername,'medium') & ...
        strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed');
    output_5 = kellyratio2(inputtable.pnlrel(idx_5,:));
    n_empirical(5) = output_5.n;
    p_empirical(5) = output_5.w;
    k_empirical(5) = output_5.k;
    wa_empirical(5) = output_5.winavg;
    la_empirical(5) = output_5.lossavg;
    n_calib(5) = NaN;
    p_calib(5) = NaN;
    k_calib(5) = NaN;
    wa_calib(5) = NaN;
    la_calib(5) = NaN;
    %
    %
    idx_6 = inputtable.direction == 1 & ...
    strcmpi(inputtable.tradername,'medium') & ...
    (strcmpi(inputtable.opensignal,'mediumbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
    output_6 = kellyratio2(inputtable.pnlrel(idx_6,:));
    n_empirical(6) = output_6.n;
    p_empirical(6) = output_6.w;
    k_empirical(6) = output_6.k;
    wa_empirical(6) = output_6.winavg;
    la_empirical(6) = output_6.lossavg;
    n_calib(6) = NaN;
    p_calib(6) = NaN;
    k_calib(6) = NaN;
    wa_calib(6) = NaN;
    la_calib(6) = NaN;

    res = table(modes,n_empirical,p_empirical,k_empirical,wa_empirical,la_empirical,n_calib,p_calib,k_calib,wa_calib,la_calib);
    tblselected = inputtable(idx_6,:);
    %
elseif strcmpi(inputmode,'bstc')
    modes = {'bstc';'strongbreach-trendconfirmed';'volblowup';'volblowup2';'conditional-uptrendconfirmed';'bstc-all'};
    %
    idx_1 = inputtable.direction == 1 & ...
    strcmpi(inputtable.tradername,'strong') & ...
    (strcmpi(inputtable.opensignal,'strongbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
    output_1 = kellyratio2(inputtable.pnlrel(idx_1,:));
    p_empirical = zeros(length(modes),1);k_empirical = p_empirical;n_empirical = k_empirical;wa_empirical = k_empirical;la_empirical = wa_empirical;
    p_calib = p_empirical;k_calib = p_calib;n_calib = p_calib;wa_calib = k_calib;la_calib = wa_calib;
    n_empirical(1) = output_1.n;
    p_empirical(1) = output_1.w;
    k_empirical(1) = output_1.k;
    wa_empirical(1) = output_1.winavg;
    la_empirical(1) = output_1.lossavg;
    n_calib(1) = strattable.bstc.N(strcmpi(strattable.bstc.asset,inputcode));
    p_calib(1) = strattable.bstc.W(strcmpi(strattable.bstc.asset,inputcode));
    k_calib(1) = strattable.bstc.K(strcmpi(strattable.bstc.asset,inputcode));
    try
        wa_calib(1) = strattable.bstc.winavg(strcmpi(strattable.bstc.asset,inputcode));
        la_calib(1) = strattable.bstc.lossavg(strcmpi(strattable.bstc.asset,inputcode));
    catch
        wa_calib(1) = NaN;
        la_calib(1) = NaN;
    end
    %
    %
    idx_2 = inputtable.direction == 1 & ...
        strcmpi(inputtable.tradername,'strong') & ...
        strcmpi(inputtable.opensignal,'strongbreach-trendconfirmed');
    output_2 = kellyratio2(inputtable.pnlrel(idx_2,:));
    n_empirical(2) = output_2.n;
    p_empirical(2) = output_2.w;
    k_empirical(2) = output_2.k;
    wa_empirical(2) = output_2.winavg;
    la_empirical(2) = output_2.lossavg;
    n_calib(2) = NaN;
    p_calib(2) = kelly_w('strongbreach-trendconfirmed',inputcode,strattable.signal_l,strattable.asset_list,strattable.winprob_matrix_l);
    k_calib(2) = kelly_k('strongbreach-trendconfirmed',inputcode,strattable.signal_l,strattable.asset_list,strattable.kelly_matrix_l);
    wa_calib(2) = NaN;
    la_calib(2) = NaN;
    %
    %
    idx_3 = inputtable.direction == 1 & ...
        strcmpi(inputtable.tradername,'strong') & ...
        strcmpi(inputtable.opensignal,'volblowup');
    output_3 = kellyratio2(inputtable.pnlrel(idx_3,:));
    n_empirical(3) = output_3.n;
    p_empirical(3) = output_3.w;
    k_empirical(3) = output_3.k;
    wa_empirical(3) = output_3.winavg;
    la_empirical(3) = output_3.lossavg;
    n_calib(3) = NaN;
    p_calib(3) = kelly_w('volblowup',inputcode,strattable.signal_l,strattable.asset_list,strattable.winprob_matrix_l);
    k_calib(3) = kelly_k('volblowup',inputcode,strattable.signal_l,strattable.asset_list,strattable.kelly_matrix_l);
    wa_calib(3) = NaN;
    la_calib(3) = NaN;
    %
    %
    idx_4 = inputtable.direction == 1 & ...
        strcmpi(inputtable.tradername,'strong') & ...
        strcmpi(inputtable.opensignal,'volblowup2');
    output_4 = kellyratio2(inputtable.pnlrel(idx_4,:));
    n_empirical(4) = output_4.n;
    p_empirical(4) = output_4.w;
    k_empirical(4) = output_4.k;
    wa_empirical(4) = output_4.winavg;
    la_empirical(4) = output_4.lossavg;
    n_calib(4) = NaN;
    p_calib(4) = kelly_w('volblowup2',inputcode,strattable.signal_l,strattable.asset_list,strattable.winprob_matrix_l);
    k_calib(4) = kelly_k('volblowup2',inputcode,strattable.signal_l,strattable.asset_list,strattable.kelly_matrix_l);
    wa_calib(4) = NaN;
    la_calib(4) = NaN;
    %
    %
    idx_5 = inputtable.direction == 1 & ...
        strcmpi(inputtable.tradername,'strong') & ...
        strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed');
    output_5 = kellyratio2(inputtable.pnlrel(idx_5,:));
    n_empirical(5) = output_5.n;
    p_empirical(5) = output_5.w;
    k_empirical(5) = output_5.k;
    wa_empirical(5) = output_5.winavg;
    la_empirical(5) = output_5.lossavg;
    n_calib(5) = NaN;
    p_calib(5) = NaN;
    k_calib(5) = NaN;
    wa_calib(5) = NaN;
    la_calib(5) = NaN;
    %
    %
    idx_6 = inputtable.direction == 1 & ...
    strcmpi(inputtable.tradername,'strong') & ...
    (strcmpi(inputtable.opensignal,'strongbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
    output_6 = kellyratio2(inputtable.pnlrel(idx_6,:));
    n_empirical(6) = output_6.n;
    p_empirical(6) = output_6.w;
    k_empirical(6) = output_6.k;
    wa_empirical(6) = output_6.winavg;
    la_empirical(6) = output_6.lossavg;
    n_calib(6) = NaN;
    p_calib(6) = NaN;
    k_calib(6) = NaN;
    wa_calib(6) = NaN;
    la_calib(6) = NaN;
    %
    res = table(modes,n_empirical,p_empirical,k_empirical,wa_empirical,la_empirical,n_calib,p_calib,k_calib,wa_calib,la_calib);
    tblselected = inputtable(idx_6,:);
    %

elseif strcmpi(inputmode,'breachup-lvlup')
    modes = {'breachup-lvlup';'conditional-uptrendconfirmed-1';'breachup-lvlup-all'};
    p_empirical = zeros(length(modes),1);k_empirical = p_empirical;n_empirical = k_empirical;wa_empirical = k_empirical;la_empirical = wa_empirical;
    p_calib = p_empirical;k_calib = p_calib;n_calib = p_calib;wa_calib = k_calib;la_calib = wa_calib;
    %
    idx_1 = inputtable.direction == 1 & ...
        strcmpi(inputtable.opensignal,'breachup-lvlup') & ...
        strcmpi(inputtable.countername,'tc');
    output_1 = kellyratio2(inputtable.pnlrel(idx_1,:));
    n_empirical(1) = output_1.n;
    p_empirical(1) = output_1.w;
    k_empirical(1) = output_1.k;
    wa_empirical(1) = output_1.winavg;
    la_empirical(1) = output_1.lossavg;
    n_calib(1) = strattable.breachuplvlup_tc.N(strcmpi(strattable.breachuplvlup_tc.asset,inputcode));
    p_calib(1) = strattable.breachuplvlup_tc.W(strcmpi(strattable.breachuplvlup_tc.asset,inputcode));
    k_calib(1) = strattable.breachuplvlup_tc.K(strcmpi(strattable.breachuplvlup_tc.asset,inputcode));
    try
        wa_calib(1) = strattable.breachuplvlup_tc.winavg(strcmpi(strattable.breachuplvlup_tc.asset,inputcode));
        la_calib(1) = strattable.breachuplvlup_tc.lossavg(strcmpi(strattable.breachuplvlup_tc.asset,inputcode));
    catch
        wa_calib(1) = NaN;
        la_calib(1) = NaN;
    end
    %
    %
    idx_2 = inputtable.direction == 1 & ...
        strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed-1');
    output_2 = kellyratio2(inputtable.pnlrel(idx_2,:));
    n_empirical(2) = output_2.n;
    p_empirical(2) = output_2.w;
    k_empirical(2) = output_2.k;
    wa_empirical(2) = output_2.winavg;
    la_empirical(2) = output_2.lossavg;
    n_calib(2) = NaN;
    p_calib(2) = NaN;
    k_calib(2) = NaN;
    wa_calib(2) = NaN;
    la_calib(2) = NaN;
    %
    %
    idx_3 = inputtable.direction == 1 & ...
        (strcmpi(inputtable.opensignal,'breachup-lvlup') | ...
        strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed-1')) & ...
        strcmpi(inputtable.countername,'tc');
    output_3 = kellyratio2(inputtable.pnlrel(idx_3,:));
    n_empirical(3) = output_3.n;
    p_empirical(3) = output_3.w;
    k_empirical(3) = output_3.k;
    wa_empirical(3) = output_3.winavg;
    la_empirical(3) = output_3.lossavg;
    n_calib(3) = NaN;
    p_calib(3) = NaN;
    k_calib(3) = NaN;
    wa_calib(3) = NaN;
    la_calib(3) = NaN;
    %
    res = table(modes,n_empirical,p_empirical,k_empirical,wa_empirical,la_empirical,n_calib,p_calib,k_calib,wa_calib,la_calib);
    tblselected = inputtable(idx_3,:);
    %
elseif strcmpi(inputmode,'breachup-sshighvalue')
    modes = {'breachup-sshighvalue';'conditional-uptrendconfirmed-2';'breachup-sshighvalue-all'};
    p_empirical = zeros(length(modes),1);k_empirical = p_empirical;n_empirical = k_empirical;wa_empirical = k_empirical;la_empirical = wa_empirical;
    p_calib = p_empirical;k_calib = p_calib;n_calib = p_calib;wa_calib = k_calib;la_calib = wa_calib;
    %
    idx_1 = inputtable.direction == 1 & ...
        strcmpi(inputtable.opensignal,'breachup-sshighvalue') & ...
        strcmpi(inputtable.countername,'tc');
    output_1 = kellyratio2(inputtable.pnlrel(idx_1,:));
    n_empirical(1) = output_1.n;
    p_empirical(1) = output_1.w;
    k_empirical(1) = output_1.k;
    wa_empirical(1) = output_1.winavg;
    la_empirical(1) = output_1.lossavg;
    n_calib(1) = strattable.breachupsshighvalue_tc.N(strcmpi(strattable.breachupsshighvalue_tc.asset,inputcode));
    p_calib(1) = strattable.breachupsshighvalue_tc.W(strcmpi(strattable.breachupsshighvalue_tc.asset,inputcode));
    k_calib(1) = strattable.breachupsshighvalue_tc.K(strcmpi(strattable.breachupsshighvalue_tc.asset,inputcode));
    try
        wa_calib(1) = strattable.breachupsshighvalue_tc.winavg(strcmpi(strattable.breachupsshighvalue_tc.asset,inputcode));
        la_calib(1) = strattable.breachupsshighvalue_tc.lossavg(strcmpi(strattable.breachupsshighvalue_tc.asset,inputcode));
    catch
        wa_calib(1) = NaN;
        la_calib(1) = NaN;
    end
    %
    %
    idx_2 = inputtable.direction == 1 & ...
        strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed-2');
    output_2 = kellyratio2(inputtable.pnlrel(idx_2,:));
    n_empirical(2) = output_2.n;
    p_empirical(2) = output_2.w;
    k_empirical(2) = output_2.k;
    wa_empirical(2) = output_2.winavg;
    la_empirical(2) = output_2.lossavg;
    n_calib(2) = NaN;
    p_calib(2) = NaN;
    k_calib(2) = NaN;
    wa_calib(2) = NaN;
    la_calib(2) = NaN;
    %
    %
    idx_3 = inputtable.direction == 1 & ...
        (strcmpi(inputtable.opensignal,'breachup-sshighvalue') | ...
        strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed-2')) & ...
        strcmpi(inputtable.countername,'tc');
    output_3 = kellyratio2(inputtable.pnlrel(idx_3,:));
    n_empirical(3) = output_3.n;
    p_empirical(3) = output_3.w;
    k_empirical(3) = output_3.k;
    wa_empirical(3) = output_3.winavg;
    la_empirical(3) = output_3.lossavg;
    n_calib(3) = NaN;
    p_calib(3) = NaN;
    k_calib(3) = NaN;
    wa_calib(3) = NaN;
    la_calib(3) = NaN;
    %
    res = table(modes,n_empirical,p_empirical,k_empirical,wa_empirical,la_empirical,n_calib,p_calib,k_calib,wa_calib,la_calib);
    tblselected = inputtable(idx_3,:);
    %
elseif strcmpi(inputmode,'breachup-highsc13')
    modes = {'breachup-highsc13';'conditional-uptrendconfirmed-3';'breachup-highsc13-all'};
    p_empirical = zeros(length(modes),1);k_empirical = p_empirical;n_empirical = k_empirical;wa_empirical = k_empirical;la_empirical = wa_empirical;
    p_calib = p_empirical;k_calib = p_calib;n_calib = p_calib;wa_calib = k_calib;la_calib = wa_calib;
    %
    idx_1 = inputtable.direction == 1 & ...
        strcmpi(inputtable.opensignal,'breachup-highsc13');
    output_1 = kellyratio2(inputtable.pnlrel(idx_1,:));
    n_empirical(1) = output_1.n;
    p_empirical(1) = output_1.w;
    k_empirical(1) = output_1.k;
    wa_empirical(1) = output_1.winavg;
    la_empirical(1) = output_1.lossavg;
    n_calib(1) = strattable.breachuphighsc13.N(strcmpi(strattable.breachuphighsc13.asset,inputcode));
    p_calib(1) = strattable.breachuphighsc13.W(strcmpi(strattable.breachuphighsc13.asset,inputcode));
    k_calib(1) = strattable.breachuphighsc13.K(strcmpi(strattable.breachuphighsc13.asset,inputcode));
    try
        wa_calib(1) = strattable.breachuphighsc13.winavg(strcmpi(strattable.breachuphighsc13.asset,inputcode));
        la_calib(1) = strattable.breachuphighsc13.lossavg(strcmpi(strattable.breachuphighsc13.asset,inputcode));
    catch
        wa_calib(1) = NaN;
        la_calib(1) = NaN;
    end
    %
    %
    idx_2 = inputtable.direction == 1 & ...
        strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed-3');
    output_2 = kellyratio2(inputtable.pnlrel(idx_2,:));
    n_empirical(2) = output_2.n;
    p_empirical(2) = output_2.w;
    k_empirical(2) = output_2.k;
    wa_empirical(2) = output_2.winavg;
    la_empirical(2) = output_2.lossavg;
    n_calib(2) = NaN;
    p_calib(2) = NaN;
    k_calib(2) = NaN;
    wa_calib(2) = NaN;
    la_calib(2) = NaN;
    %
    %
    idx_3 = inputtable.direction == 1 & ...
        (strcmpi(inputtable.opensignal,'breachup-highsc13') | ...
        strcmpi(inputtable.opensignal,'conditional-uptrendconfirmed-3'));
    output_3 = kellyratio2(inputtable.pnlrel(idx_3,:));
    n_empirical(3) = output_3.n;
    p_empirical(3) = output_3.w;
    k_empirical(3) = output_3.k;
    wa_empirical(3) = output_3.winavg;
    la_empirical(3) = output_3.lossavg;
    n_calib(3) = NaN;
    p_calib(3) = NaN;
    k_calib(3) = NaN;
    wa_calib(3) = NaN;
    la_calib(3) = NaN;
    %
    res = table(modes,n_empirical,p_empirical,k_empirical,wa_empirical,la_empirical,n_calib,p_calib,k_calib,wa_calib,la_calib);
    tblselected = inputtable(idx_3,:);
    %

elseif strcmpi(inputmode,'smtc')
    modes = {'smtc';'mediumbreach-trendconfirmed';'volblowup';'volblowup2';'conditional-dntrendconfirmed';'smtc-all'};
    %
    idx_1 = inputtable.direction == -1 & ...
    strcmpi(inputtable.tradername,'medium') & ...
    (strcmpi(inputtable.opensignal,'mediumbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
    output_1 = kellyratio2(inputtable.pnlrel(idx_1,:));
    p_empirical = zeros(length(modes),1);k_empirical = p_empirical;n_empirical = k_empirical;wa_empirical = k_empirical;la_empirical = wa_empirical;
    p_calib = p_empirical;k_calib = p_calib;n_calib = p_calib;wa_calib = k_calib;la_calib = wa_calib;
    n_empirical(1) = output_1.n;
    p_empirical(1) = output_1.w;
    k_empirical(1) = output_1.k;
    wa_empirical(1) = output_1.winavg;
    la_empirical(1) = output_1.lossavg;
    n_calib(1) = strattable.smtc.N(strcmpi(strattable.smtc.asset,inputcode));
    p_calib(1) = strattable.smtc.W(strcmpi(strattable.smtc.asset,inputcode));
    k_calib(1) = strattable.smtc.K(strcmpi(strattable.smtc.asset,inputcode));
    try
        wa_calib(1) = strattable.smtc.winavg(strcmpi(strattable.smtc.asset,inputcode));
        la_calib(1) = strattable.smtc.lossavg(strcmpi(strattable.smtc.asset,inputcode));
    catch
        wa_calib(1) = NaN;
        la_calib(1) = NaN;
    end
    %
    %
    idx_2 = inputtable.direction == -1 & ...
        strcmpi(inputtable.tradername,'medium') & ...
        strcmpi(inputtable.opensignal,'mediumbreach-trendconfirmed');
    output_2 = kellyratio2(inputtable.pnlrel(idx_2,:));
    n_empirical(2) = output_2.n;
    p_empirical(2) = output_2.w;
    k_empirical(2) = output_2.k;
    wa_empirical(2) = output_2.winavg;
    la_empirical(2) = output_2.lossavg;
    n_calib(2) = NaN;
    p_calib(2) = kelly_w('mediumbreach-trendconfirmed',inputcode,strattable.signal_s,strattable.asset_list,strattable.winprob_matrix_s);
    k_calib(2) = kelly_k('mediumbreach-trendconfirmed',inputcode,strattable.signal_s,strattable.asset_list,strattable.kelly_matrix_s);
    wa_calib(2) = NaN;
    la_calib(2) = NaN;
    %
    %
    idx_3 = inputtable.direction == -1 & ...
        strcmpi(inputtable.tradername,'medium') & ...
        strcmpi(inputtable.opensignal,'volblowup');
    output_3 = kellyratio2(inputtable.pnlrel(idx_3,:));
    n_empirical(3) = output_3.n;
    p_empirical(3) = output_3.w;
    k_empirical(3) = output_3.k;
    wa_empirical(3) = output_3.winavg;
    la_empirical(3) = output_3.lossavg;
    n_calib(3) = NaN;
    p_calib(3) = kelly_w('volblowup',inputcode,strattable.signal_s,strattable.asset_list,strattable.winprob_matrix_s);
    k_calib(3) = kelly_k('volblowup',inputcode,strattable.signal_s,strattable.asset_list,strattable.kelly_matrix_s);
    wa_calib(3) = NaN;
    la_calib(3) = NaN;
    %
    %
    idx_4 = inputtable.direction == -1 & ...
        strcmpi(inputtable.tradername,'medium') & ...
        strcmpi(inputtable.opensignal,'volblowup2');
    output_4 = kellyratio2(inputtable.pnlrel(idx_4,:));
    n_empirical(4) = output_4.n;
    p_empirical(4) = output_4.w;
    k_empirical(4) = output_4.k;
    wa_empirical(4) = output_4.winavg;
    la_empirical(4) = output_4.lossavg;
    n_calib(4) = NaN;
    p_calib(4) = kelly_w('volblowup2',inputcode,strattable.signal_s,strattable.asset_list,strattable.winprob_matrix_s);
    k_calib(4) = kelly_k('volblowup2',inputcode,strattable.signal_s,strattable.asset_list,strattable.kelly_matrix_s);
    wa_calib(4) = NaN;
    la_calib(4) = NaN;
    %
    %
    idx_5 = inputtable.direction == -1 & ...
        strcmpi(inputtable.tradername,'medium') & ...
        strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed');
    output_5 = kellyratio2(inputtable.pnlrel(idx_5,:));
    n_empirical(5) = output_5.n;
    p_empirical(5) = output_5.w;
    k_empirical(5) = output_5.k;
    wa_empirical(5) = output_5.winavg;
    la_empirical(5) = output_5.lossavg;
    n_calib(5) = NaN;
    p_calib(5) = NaN;
    k_calib(5) = NaN;
    wa_calib(5) = NaN;
    la_calib(5) = NaN;
    %
    %
    idx_6 = inputtable.direction == -1 & ...
    strcmpi(inputtable.tradername,'medium') & ...
    (strcmpi(inputtable.opensignal,'mediumbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
    output_6 = kellyratio2(inputtable.pnlrel(idx_6,:));
    n_empirical(6) = output_6.n;
    p_empirical(6) = output_6.w;
    k_empirical(6) = output_6.k;
    wa_empirical(6) = output_6.winavg;
    la_empirical(6) = output_6.lossavg;
    n_calib(6) = NaN;
    p_calib(6) = NaN;
    k_calib(6) = NaN;
    wa_calib(6) = NaN;
    la_calib(6) = NaN;

    res = table(modes,n_empirical,p_empirical,k_empirical,wa_empirical,la_empirical,n_calib,p_calib,k_calib,wa_calib,la_calib);
    tblselected = inputtable(idx_6,:);

elseif strcmpi(inputmode,'sstc')
    modes = {'sstc';'strongbreach-trendconfirmed';'volblowup';'volblowup2';'conditional-dntrendconfirmed';'sstc-all'};
    %
    idx_1 = inputtable.direction == -1 & ...
    strcmpi(inputtable.tradername,'strong') & ...
    (strcmpi(inputtable.opensignal,'strongbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
    output_1 = kellyratio2(inputtable.pnlrel(idx_1,:));
    p_empirical = zeros(length(modes),1);k_empirical = p_empirical;n_empirical = k_empirical;wa_empirical = k_empirical;la_empirical = wa_empirical;
    p_calib = p_empirical;k_calib = p_calib;n_calib = p_calib;wa_calib = k_calib;la_calib = wa_calib;
    n_empirical(1) = output_1.n;
    p_empirical(1) = output_1.w;
    k_empirical(1) = output_1.k;
    wa_empirical(1) = output_1.winavg;
    la_empirical(1) = output_1.lossavg;
    n_calib(1) = strattable.sstc.N(strcmpi(strattable.sstc.asset,inputcode));
    p_calib(1) = strattable.sstc.W(strcmpi(strattable.sstc.asset,inputcode));
    k_calib(1) = strattable.sstc.K(strcmpi(strattable.sstc.asset,inputcode));
    try
        wa_calib(1) = strattable.sstc.winavg(strcmpi(strattable.sstc.asset,inputcode));
        la_calib(1) = strattable.sstc.lossavg(strcmpi(strattable.sstc.asset,inputcode));
    catch
        wa_calib(1) = NaN;
        la_calib(1) = NaN;
    end
    %
    %
    idx_2 = inputtable.direction == -1 & ...
        strcmpi(inputtable.tradername,'strong') & ...
        strcmpi(inputtable.opensignal,'strongbreach-trendconfirmed');
    output_2 = kellyratio2(inputtable.pnlrel(idx_2,:));
    n_empirical(2) = output_2.n;
    p_empirical(2) = output_2.w;
    k_empirical(2) = output_2.k;
    wa_empirical(2) = output_2.winavg;
    la_empirical(2) = output_2.lossavg;
    n_calib(2) = NaN;
    p_calib(2) = kelly_w('strongbreach-trendconfirmed',inputcode,strattable.signal_s,strattable.asset_list,strattable.winprob_matrix_s);
    k_calib(2) = kelly_k('strongbreach-trendconfirmed',inputcode,strattable.signal_s,strattable.asset_list,strattable.kelly_matrix_s);
    wa_calib(2) = NaN;
    la_calib(2) = NaN;
    %
    %
    idx_3 = inputtable.direction == -1 & ...
        strcmpi(inputtable.tradername,'strong') & ...
        strcmpi(inputtable.opensignal,'volblowup');
    output_3 = kellyratio2(inputtable.pnlrel(idx_3,:));
    n_empirical(3) = output_3.n;
    p_empirical(3) = output_3.w;
    k_empirical(3) = output_3.k;
    wa_empirical(3) = output_3.winavg;
    la_empirical(3) = output_3.lossavg;
    n_calib(3) = NaN;
    p_calib(3) = kelly_w('volblowup',inputcode,strattable.signal_s,strattable.asset_list,strattable.winprob_matrix_s);
    k_calib(3) = kelly_k('volblowup',inputcode,strattable.signal_s,strattable.asset_list,strattable.kelly_matrix_s);
    wa_calib(3) = NaN;
    la_calib(3) = NaN;
    %
    %
    idx_4 = inputtable.direction == -1 & ...
        strcmpi(inputtable.tradername,'strong') & ...
        strcmpi(inputtable.opensignal,'volblowup2');
    output_4 = kellyratio2(inputtable.pnlrel(idx_4,:));
    n_empirical(4) = output_4.n;
    p_empirical(4) = output_4.w;
    k_empirical(4) = output_4.k;
    wa_empirical(4) = output_4.winavg;
    la_empirical(4) = output_4.lossavg;
    n_calib(4) = NaN;
    p_calib(4) = kelly_w('volblowup2',inputcode,strattable.signal_s,strattable.asset_list,strattable.winprob_matrix_s);
    k_calib(4) = kelly_k('volblowup2',inputcode,strattable.signal_s,strattable.asset_list,strattable.kelly_matrix_s);
    wa_calib(4) = NaN;
    la_calib(4) = NaN;
    %
    %
    idx_5 = inputtable.direction == -1 & ...
        strcmpi(inputtable.tradername,'strong') & ...
        strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed');
    output_5 = kellyratio2(inputtable.pnlrel(idx_5,:));
    n_empirical(5) = output_5.n;
    p_empirical(5) = output_5.w;
    k_empirical(5) = output_5.k;
    wa_empirical(5) = output_5.winavg;
    la_empirical(5) = output_5.lossavg;
    n_calib(5) = NaN;
    p_calib(5) = NaN;
    k_calib(5) = NaN;
    wa_calib(5) = NaN;
    la_calib(5) = NaN;
    %
    %
    idx_6 = inputtable.direction == -1 & ...
    strcmpi(inputtable.tradername,'strong') & ...
    (strcmpi(inputtable.opensignal,'strongbreach-trendconfirmed') | ...
    strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed') | ...
    strcmpi(inputtable.opensignal,'volblowup') | ...
    strcmpi(inputtable.opensignal,'volblowup2'));
    output_6 = kellyratio2(inputtable.pnlrel(idx_6,:));
    n_empirical(6) = output_6.n;
    p_empirical(6) = output_6.w;
    k_empirical(6) = output_6.k;
    wa_empirical(6) = output_6.winavg;
    la_empirical(6) = output_6.lossavg;
    n_calib(6) = NaN;
    p_calib(6) = NaN;
    k_calib(6) = NaN;
    wa_calib(6) = NaN;
    la_calib(6) = NaN;
    %
    res = table(modes,n_empirical,p_empirical,k_empirical,wa_empirical,la_empirical,n_calib,p_calib,k_calib,wa_calib,la_calib);
    tblselected = inputtable(idx_6,:);
    %

    
elseif strcmpi(inputmode,'breachdn-lvldn')
    modes = {'breachdn-lvldn';'conditional-dntrendconfirmed-1';'breachdn-lvldn-all'};
    p_empirical = zeros(length(modes),1);k_empirical = p_empirical;n_empirical = k_empirical;wa_empirical = k_empirical;la_empirical = wa_empirical;
    p_calib = p_empirical;k_calib = p_calib;n_calib = p_calib;wa_calib = k_calib;la_calib = wa_calib;
    %
    idx_1 = inputtable.direction == -1 & ...
        strcmpi(inputtable.opensignal,'breachdn-lvldn') & ...
        strcmpi(inputtable.countername,'tc');
    output_1 = kellyratio2(inputtable.pnlrel(idx_1,:));
    n_empirical(1) = output_1.n;
    p_empirical(1) = output_1.w;
    k_empirical(1) = output_1.k;
    wa_empirical(1) = output_1.winavg;
    la_empirical(1) = output_1.lossavg;
    n_calib(1) = strattable.breachdnlvldn_tc.N(strcmpi(strattable.breachdnlvldn_tc.asset,inputcode));
    p_calib(1) = strattable.breachdnlvldn_tc.W(strcmpi(strattable.breachdnlvldn_tc.asset,inputcode));
    k_calib(1) = strattable.breachdnlvldn_tc.K(strcmpi(strattable.breachdnlvldn_tc.asset,inputcode));
    try
        wa_calib(1) = strattable.breachdnlvldn_tc.winavg(strcmpi(strattable.breachdnlvldn_tc.asset,inputcode));
        la_calib(1) = strattable.breachdnlvldn_tc.lossavg(strcmpi(strattable.breachdnlvldn_tc.asset,inputcode));
    catch
        wa_calib(1) = NaN;
        la_calib(1) = NaN;
    end
    %
    %
    idx_2 = inputtable.direction == -1 & ...
        strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed-1');
    output_2 = kellyratio2(inputtable.pnlrel(idx_2,:));
    n_empirical(2) = output_2.n;
    p_empirical(2) = output_2.w;
    k_empirical(2) = output_2.k;
    wa_empirical(2) = output_2.winavg;
    la_empirical(2) = output_2.lossavg;
    n_calib(2) = NaN;
    p_calib(2) = NaN;
    k_calib(2) = NaN;
    wa_calib(2) = NaN;
    la_calib(2) = NaN;
    %
    %
    idx_3 = inputtable.direction == -1 & ...
        (strcmpi(inputtable.opensignal,'breachdn-lvldn') | ...
        strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed-1')) & ...
        strcmpi(inputtable.countername,'tc');
    output_3 = kellyratio2(inputtable.pnlrel(idx_3,:));
    n_empirical(3) = output_3.n;
    p_empirical(3) = output_3.w;
    k_empirical(3) = output_3.k;
    wa_empirical(3) = output_3.winavg;
    la_empirical(3) = output_3.lossavg;
    n_calib(3) = NaN;
    p_calib(3) = NaN;
    k_calib(3) = NaN;
    wa_calib(3) = NaN;
    la_calib(3) = NaN;
    %
    res = table(modes,n_empirical,p_empirical,k_empirical,wa_empirical,la_empirical,n_calib,p_calib,k_calib,wa_calib,la_calib);
    tblselected = inputtable(idx_3,:);
    %
elseif strcmpi(inputmode,'breachdn-bshighvalue')
    modes = {'breachdn-bshighvalue';'conditional-dntrendconfirmed-2';'breachdn-bshighvalue-all'};
    p_empirical = zeros(length(modes),1);k_empirical = p_empirical;n_empirical = k_empirical;wa_empirical = k_empirical;la_empirical = wa_empirical;
    p_calib = p_empirical;k_calib = p_calib;n_calib = p_calib;wa_calib = k_calib;la_calib = wa_calib;
    %
    idx_1 = inputtable.direction == -1 & ...
        strcmpi(inputtable.opensignal,'breachdn-bshighvalue') & ...
        strcmpi(inputtable.countername,'tc');
    output_1 = kellyratio2(inputtable.pnlrel(idx_1,:));
    n_empirical(1) = output_1.n;
    p_empirical(1) = output_1.w;
    k_empirical(1) = output_1.k;
    wa_empirical(1) = output_1.winavg;
    la_empirical(1) = output_1.lossavg;
    n_calib(1) = strattable.breachdnbshighvalue_tc.N(strcmpi(strattable.breachdnbshighvalue_tc.asset,inputcode));
    p_calib(1) = strattable.breachdnbshighvalue_tc.W(strcmpi(strattable.breachdnbshighvalue_tc.asset,inputcode));
    k_calib(1) = strattable.breachdnbshighvalue_tc.K(strcmpi(strattable.breachdnbshighvalue_tc.asset,inputcode));
    try
        wa_calib(1) = strattable.breachdnbshighvalue_tc.winavg(strcmpi(strattable.breachdnbshighvalue_tc.asset,inputcode));
        la_calib(1) = strattable.breachdnbshighvalue_tc.lossavg(strcmpi(strattable.breachdnbshighvalue_tc.asset,inputcode));
    catch
        wa_calib(1) = NaN;
        la_calib(1) = NaN;
    end
        
    %
    %
    idx_2 = inputtable.direction == -1 & ...
        strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed-2');
    output_2 = kellyratio2(inputtable.pnlrel(idx_2,:));
    n_empirical(2) = output_2.n;
    p_empirical(2) = output_2.w;
    k_empirical(2) = output_2.k;
    wa_empirical(2) = output_2.winavg;
    la_empirical(2) = output_2.lossavg;
    n_calib(2) = NaN;
    p_calib(2) = NaN;
    k_calib(2) = NaN;
    wa_calib(2) = NaN;
    la_calib(2) = NaN;
    %
    %
    idx_3 = inputtable.direction == -1 & ...
        (strcmpi(inputtable.opensignal,'breachdn-bshighvalue') | ...
        strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed-2')) & ...
        strcmpi(inputtable.countername,'tc');
    output_3 = kellyratio2(inputtable.pnlrel(idx_3,:));
    n_empirical(3) = output_3.n;
    p_empirical(3) = output_3.w;
    k_empirical(3) = output_3.k;
    wa_empirical(3) = output_3.winavg;
    la_empirical(3) = output_3.lossavg;
    n_calib(3) = NaN;
    p_calib(3) = NaN;
    k_calib(3) = NaN;
    wa_calib(3) = NaN;
    la_calib(3) = NaN;
    %
    res = table(modes,n_empirical,p_empirical,k_empirical,wa_empirical,la_empirical,n_calib,p_calib,k_calib,wa_calib,la_calib);
    tblselected = inputtable(idx_3,:);
    %
elseif strcmpi(inputmode,'breachdn-lowbc13')
    modes = {'breachdn-lowbc13';'conditional-dntrendconfirmed-3';'breachdn-lowbc13-all'};
    p_empirical = zeros(length(modes),1);k_empirical = p_empirical;n_empirical = k_empirical;wa_empirical = k_empirical;la_empirical = wa_empirical;
    p_calib = p_empirical;k_calib = p_calib;n_calib = p_calib;wa_calib = k_calib;la_calib = wa_calib;
    %
    idx_1 = inputtable.direction == -1 & ...
        strcmpi(inputtable.opensignal,'breachdn-lowbc13');
    output_1 = kellyratio2(inputtable.pnlrel(idx_1,:));
    n_empirical(1) = output_1.n;
    p_empirical(1) = output_1.w;
    k_empirical(1) = output_1.k;
    wa_empirical(1) = output_1.winavg;
    la_empirical(1) = output_1.lossavg;
    n_calib(1) = strattable.breachdnlowbc13.N(strcmpi(strattable.breachdnlowbc13.asset,inputcode));
    p_calib(1) = strattable.breachdnlowbc13.W(strcmpi(strattable.breachdnlowbc13.asset,inputcode));
    k_calib(1) = strattable.breachdnlowbc13.K(strcmpi(strattable.breachdnlowbc13.asset,inputcode));
    try
        wa_calib(1) = strattable.breachdnlowbc13.winavg(strcmpi(strattable.breachdnlowbc13.asset,inputcode));
        la_calib(1) = strattable.breachdnlowbc13.lossavg(strcmpi(strattable.breachdnlowbc13.asset,inputcode));
    catch
        wa_calib(1) = NaN;
        la_calib(1) = NaN;
    end    
    %
    %
    idx_2 = inputtable.direction == -1 & ...
        strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed-3');
    output_2 = kellyratio2(inputtable.pnlrel(idx_2,:));
    n_empirical(2) = output_2.n;
    p_empirical(2) = output_2.w;
    k_empirical(2) = output_2.k;
    wa_empirical(2) = output_2.winavg;
    la_empirical(2) = output_2.lossavg;
    n_calib(2) = NaN;
    p_calib(2) = NaN;
    k_calib(2) = NaN;
    wa_calib(2) = NaN;
    la_calib(2) = NaN;
    %
    %
    idx_3 = inputtable.direction == -1 & ...
        (strcmpi(inputtable.opensignal,'breachdn-lowbc13') | ...
        strcmpi(inputtable.opensignal,'conditional-dntrendconfirmed-3'));
    output_3 = kellyratio2(inputtable.pnlrel(idx_3,:));
    n_empirical(3) = output_3.n;
    p_empirical(3) = output_3.w;
    k_empirical(3) = output_3.k;
    wa_empirical(3) = output_3.winavg;
    la_empirical(3) = output_3.lossavg;
    n_calib(3) = NaN;
    p_calib(3) = NaN;
    k_calib(3) = NaN;
    wa_calib(3) = NaN;
    la_calib(3) = NaN;
    %
    res = table(modes,n_empirical,p_empirical,k_empirical,wa_empirical,la_empirical,n_calib,p_calib,k_calib,wa_calib,la_calib);
    tblselected = inputtable(idx_3,:);
end






end