function [stratbest,tablebest,tradesbest] = kellybest(obj,varargin)
% a cFORM public method to generate the kelly table of the trades with the
% best open price
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('DateFrom','',@ischar);
    p.addParameter('DateTo','',@ischar);
    
    p.parse(varargin{:});
    
    dt1str = p.Results.DateFrom;
    dt2str = p.Results.DateTo;

    gentrades = 0;
    ncodes = length(obj.codes_);
    for i = 1:ncodes
        if obj.trades_best_{i}.latest_ == 0
            gentrades = 1;
            break;
        end
    end
    
    if gentrades
        obj.gen_trades_best;
    end

    [tablebest,tradesbest] = obj.run_trades_best('datefrom',dt1str,'dateto',dt2str);


    ModeTrend = {'bmtc';...
        'bstc';...
        'smtc';...
        'sstc';...
        'breachuplvlup_tc';...
        'breachdnlvldn_tc';...
        'breachupsshighvalue_tc';...
        'breachdnbshighvalue_tc';...
        'breachuphighsc13';...
        'breachdnlowbc13'};
    
    nmodes = length(ModeTrend);

    table_modebreakdown_percode = cell(ncodes,1);
    for i = 1:ncodes
        tblbest_i = tablebest{i};     
    
        N = zeros(nmodes,1);
        W = zeros(nmodes,1);
        R = zeros(nmodes,1);
        K = zeros(nmodes,1);
        winavg = zeros(nmodes,1);
        lossavg = zeros(nmodes,1);
        L95 = zeros(nmodes,1);

        idx_notspecial = ~(strcmpi(tblbest_i.opensignal,'breachup-lvlup') | ...
            strcmpi(tblbest_i.opensignal,'breachdn-lvldn') | ...
            strcmpi(tblbest_i.opensignal,'breachup-sshighvalue') | ...
            strcmpi(tblbest_i.opensignal,'breachdn-bshighvalue') | ...
            strcmpi(tblbest_i.opensignal,'breachup-highsc13') | ...
            strcmpi(tblbest_i.opensignal,'breachdn-lowbc13') | ...
            strcmpi(tblbest_i.opensignal,'unset'));

        idx_long = tblbest_i.direction == 1;
        idx_short = tblbest_i.direction == -1;
        idx_medium = strcmpi(tblbest_i.tradername,'medium');
        idx_strong = strcmpi(tblbest_i.tradername,'strong');
        idx_trend = strcmpi(tblbest_i.countername,'tc');

        idx_bmtc = idx_long & idx_medium & idx_trend & idx_notspecial;
        idx_bstc = idx_long & idx_strong & idx_trend & idx_notspecial;
        idx_smtc = idx_short & idx_medium & idx_trend & idx_notspecial;
        idx_sstc = idx_short & idx_strong & idx_trend & idx_notspecial;

        kout_bmtc = kellyratio2(tblbest_i.pnlrel(idx_bmtc));
        N(1) = kout_bmtc.n;W(1) = kout_bmtc.w;R(1) = kout_bmtc.r;K(1) = kout_bmtc.k;winavg(1) = kout_bmtc.winavg;lossavg(1) = kout_bmtc.lossavg;L95(1) = kout_bmtc.loss95;

        kout_bstc = kellyratio2(tblbest_i.pnlrel(idx_bstc));
        N(2) = kout_bstc.n;W(2) = kout_bstc.w;R(2) = kout_bstc.r;K(2) = kout_bstc.k;winavg(2) = kout_bstc.winavg;lossavg(2) = kout_bstc.lossavg;L95(2) = kout_bstc.loss95;

        kout_smtc = kellyratio2(tblbest_i.pnlrel(idx_smtc));
        N(3) = kout_smtc.n;W(3) = kout_smtc.w;R(3) = kout_smtc.r;K(3) = kout_smtc.k;winavg(3) = kout_smtc.winavg;lossavg(3) = kout_smtc.lossavg;L95(3) = kout_smtc.loss95;

        kout_sstc = kellyratio2(tblbest_i.pnlrel(idx_sstc));
        N(4) = kout_sstc.n;W(4) = kout_sstc.w;R(4) = kout_sstc.r;K(4) = kout_sstc.k;winavg(4) = kout_sstc.winavg;lossavg(4) = kout_sstc.lossavg;L95(4) = kout_sstc.loss95;
        %

        idx_lvluptc = strcmpi(tblbest_i.opensignal,'breachup-lvlup') & strcmpi(tblbest_i.countername,'tc');
        kout_lvluptc = kellyratio2(tblbest_i.pnlrel(idx_lvluptc));
        N(5) = kout_lvluptc.n;W(5) = kout_lvluptc.w;R(5) = kout_lvluptc.r;K(5) = kout_lvluptc.k;winavg(5) = kout_lvluptc.winavg;lossavg(5) = kout_lvluptc.lossavg;L95(5) = kout_lvluptc.loss95;

        %
        idx_lvldntc = strcmpi(tblbest_i.opensignal,'breachdn-lvldn') & strcmpi(tblbest_i.countername,'tc');
        kout_lvldn = kellyratio2(tblbest_i.pnlrel(idx_lvldntc));
        N(6) = kout_lvldn.n;W(6) = kout_lvldn.w;R(6) = kout_lvldn.r;K(6) = kout_lvldn.k;winavg(6) = kout_lvldn.winavg;lossavg(6) = kout_lvldn.lossavg;L95(6) = kout_lvldn.loss95;

        %
        idx_sshvtc = strcmpi(tblbest_i.opensignal,'breachup-sshighvalue') & strcmpi(tblbest_i.countername,'tc');
        kout_sshvtc = kellyratio2(tblbest_i.pnlrel(idx_sshvtc));
        N(7) = kout_sshvtc.n;W(7) = kout_sshvtc.w;R(7) = kout_sshvtc.r;K(7) = kout_sshvtc.k;winavg(7) = kout_sshvtc.winavg;lossavg(7) = kout_sshvtc.lossavg;L95(7) = kout_sshvtc.loss95;

        %
        idx_bshvtc = strcmpi(tblbest_i.opensignal,'breachdn-bshighvalue') & strcmpi(tblbest_i.countername,'tc');
        kout_bshvtc = kellyratio2(tblbest_i.pnlrel(idx_bshvtc));
        N(8) = kout_bshvtc.n;W(8) = kout_bshvtc.w;R(8) = kout_bshvtc.r;K(8) = kout_bshvtc.k;winavg(8) = kout_bshvtc.winavg;lossavg(8) = kout_bshvtc.lossavg;L95(8) = kout_bshvtc.loss95;

        %
        idx_sc13 = strcmpi(tblbest_i.opensignal,'breachup-highsc13') & strcmpi(tblbest_i.countername,'tc');
        kout_sc13 = kellyratio2(tblbest_i.pnlrel(idx_sc13));
        N(9) = kout_sc13.n;W(9) = kout_sc13.w;R(9) = kout_sc13.r;K(9) = kout_sc13.k;winavg(9) = kout_sc13.winavg;lossavg(9) = kout_sc13.lossavg;L95(9) = kout_sc13.loss95;

        %
        idx_bc13 = strcmpi(tblbest_i.opensignal,'breachdn-lowbc13') & strcmpi(tblbest_i.countername,'tc');
        kout_bc13 = kellyratio2(tblbest_i.pnlrel(idx_bc13));
        N(10) = kout_bc13.n;W(10) = kout_bc13.w;R(10) = kout_bc13.r;K(10) = kout_bc13.k;winavg(10) = kout_bc13.winavg;lossavg(10) = kout_bc13.lossavg;L95(10) = kout_bc13.loss95;
        %

        table_modebreakdown_percode{i} = table(ModeTrend,N,W,R,K,winavg,lossavg,L95);
    end


    stratbest = struct;
    asset = obj.codes_;
    for i = 1:size(ModeTrend,1)
        N = zeros(ncodes,1);
        W = zeros(ncodes,1);
        R = zeros(ncodes,1);
        K = zeros(ncodes,1);
        winavg = zeros(ncodes,1);
        lossavg = zeros(ncodes,1);
        L95 = zeros(ncodes,1);
        for j = 1:ncodes
            idx_j = strcmpi(table_modebreakdown_percode{j}.ModeTrend,ModeTrend{i});
            N(j) = table_modebreakdown_percode{j}.N(idx_j);
            W(j) = table_modebreakdown_percode{j}.W(idx_j);
            R(j) = table_modebreakdown_percode{j}.R(idx_j);
            K(j) = table_modebreakdown_percode{j}.K(idx_j);
            winavg(j) = table_modebreakdown_percode{j}.winavg(idx_j);
            lossavg(j) = table_modebreakdown_percode{j}.lossavg(idx_j);
            L95(j) = table_modebreakdown_percode{j}.L95(idx_j);
        end
        stratbest.(ModeTrend{i}) = table(asset,N,W,R,K,winavg,lossavg,L95);
    end

    tblbestall = tablebest{1};
    for i = 2:ncodes
        temp = [tblbestall;tablebest{i}];
        tblbestall = temp;
    end
    tblbestall = tblbestall(~strcmpi(tblbestall.opensignal,'unset'),:);
    
    stratbest.asset_list = asset';
    
    signal_l = unique(tblbestall.opensignal(tblbestall.direction == 1 & strcmpi(tblbestall.countername,'tc')));
    signal_s = unique(tblbestall.opensignal(tblbestall.direction == -1 & strcmpi(tblbestall.countername,'tc')));
    stratbest.signal_l = signal_l;
    stratbest.signal_s = signal_s;

    nsignal_l = length(signal_l);
    nsignal_s = length(signal_s);

    n_matrix_l = zeros(nsignal_l,ncodes);
    kelly_matrix_l = zeros(nsignal_l,ncodes);
    winprob_matrix_l = zeros(nsignal_l,ncodes);
    n_matrix_s = zeros(nsignal_s,ncodes);
    kelly_matrix_s = zeros(nsignal_s,ncodes);
    winprob_matrix_s = zeros(nsignal_s,ncodes);

    for i = 1:nsignal_l
        for j = 1:ncodes
            idx_ij = strcmpi(tblbestall.opensignal, signal_l{i}) & ...
                strcmpi(tblbestall.code,obj.codes_{j}) & ...
                tblbestall.direction == 1;
            k_ij = kellyratio2(tblbestall.pnlrel(idx_ij));
            kelly_matrix_l(i,j) = k_ij.k;
            winprob_matrix_l(i,j) = k_ij.w;
            n_matrix_l(i,j) = k_ij.n;
        end
    end

    for i = 1:nsignal_s
        for j = 1:ncodes
            idx_ij = strcmpi(tblbestall.opensignal, signal_s{i}) & ...
                strcmpi(tblbestall.code,obj.codes_{j}) & ...
                tblbestall.direction == -1;
            k_ij = kellyratio2(tblbestall.pnlrel(idx_ij));
            kelly_matrix_s(i,j) = k_ij.k;
            winprob_matrix_s(i,j) = k_ij.w;
            n_matrix_s(i,j) = k_ij.n;
        end
    end

    stratbest.n_matrix_l = n_matrix_l;
    stratbest.kelly_matrix_l = kelly_matrix_l;
    stratbest.winprob_matrix_l = winprob_matrix_l;
    %
    stratbest.n_matrix_s = n_matrix_s;
    stratbest.kelly_matrix_s = kelly_matrix_s;
    stratbest.winprob_matrix_s = winprob_matrix_s;
    %

end