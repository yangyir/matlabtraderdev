function [reportbyasset_tc,reportbyasset_tb,tbl_extractedinfo] = kellydistrubitionsummary(inputstruct)
    %
    %1.consolidate all tblb and tbls
    tblb_data_consolidated = inputstruct.tblb{1};
    tbls_data_consolidated = inputstruct.tbls{1};
    %NOTE:the code above is hard-coded
    %********************************************************************
    for i = 2:size(inputstruct.tblb,1) 
        tempnew = [tblb_data_consolidated;inputstruct.tblb{i}];
        tblb_data_consolidated = tempnew;
        tempnew = [tbls_data_consolidated;inputstruct.tbls{i}];
        tbls_data_consolidated = tempnew;
    end
    fprintf('data consolidated...\n');
    nb = size(tblb_data_consolidated,1);
    ns = size(tbls_data_consolidated,1);
    idxb = ones(nb,1);
    idxs = ones(ns,1);
    colidx_comment1 = 10;
    colidx_pnl = 18;
    colidx_closeid = 20;
    for i = 1:nb
        %a.remove trades with unsatified open condition
        %b.remove trades with null pnl
        if ~isempty(tblb_data_consolidated{i,colidx_comment1}),idxb(i) = 0;end
        if isempty(tblb_data_consolidated{i,colidx_pnl}),idxb(i) = 0;end
        if isnan(tblb_data_consolidated{i,colidx_pnl}),idxb(i) = 0;end
        if isempty(tblb_data_consolidated{i,colidx_closeid}),idxb(i) = 0;end
    end
    for i = 1:ns
        %a.remove trades with unsatified open condition
        %b.remove trades with null pnl
        if ~isempty(tbls_data_consolidated{i,colidx_comment1}),idxs(i) = 0;end
        if isempty(tbls_data_consolidated{i,colidx_pnl}),idxs(i) = 0;end
        if isnan(tbls_data_consolidated{i,colidx_pnl}),idxs(i) = 0;end
        if isempty(tbls_data_consolidated{i,colidx_closeid}),idxs(i) = 0;end
    end
    idxb = logical(idxb);
    idxs = logical(idxs);
    tblb_data_consolidated = tblb_data_consolidated(idxb,:);
    tbls_data_consolidated = tbls_data_consolidated(idxs,:);
    %
    %2.extract useful information
    nb = size(tblb_data_consolidated,1);
    opentype_b = zeros(nb,1);%1-weak;2-medium;3-strong
    opensignal_b = cell(nb,1);
    code_b = cell(nb,1);
    assetname_b = cell(nb,1);
    direction_b = zeros(nb,1);
    openprice_b = zeros(nb,1);
    opennotional_b = zeros(nb,1);
    opendatetime_b = zeros(nb,1);
    opendate_b = zeros(nb,1);
    openid_b = zeros(nb,1);
    closestr_b = cell(nb,1);
    pnlrel_b = zeros(nb,1);
    trendflag_b = zeros(nb,1);

    for i = 1:nb
        opentype_b(i) = tblb_data_consolidated{i,2};
        opensignal_b{i} = tblb_data_consolidated{i,11};
        code_b{i} = tblb_data_consolidated{i,14};
        try
            fut = code2instrument(code_b{i});
        catch
            fprintf('error in code2instrument of %s\n',code_b{i});
            return
        end
        assetname_b{i} = fut.asset_name;
        if isempty(fut.asset_name),assetname_b{i} = code_b{i};end
        direction_b(i) = tblb_data_consolidated{i,16};
        openprice_b(i) = tblb_data_consolidated{i,17};
        opennotional_b(i) = openprice_b(i)*fut.contract_size;
        opendatetime_b(i) = tblb_data_consolidated{i,13};
        opendate_b(i) = getlastbusinessdate(opendatetime_b(i));
        openid_b(i) = tblb_data_consolidated{i,15};
        closestr_b{i} = tblb_data_consolidated{i,19};
        pnlrel_b(i) = tblb_data_consolidated{i,18}/opennotional_b(i);
        trendflag_b(i) = tblb_data_consolidated{i,37};
    end
    tbl_extractedinfo_b = table(code_b,assetname_b,opentype_b,opensignal_b,direction_b,openid_b,opendatetime_b,opendate_b,openprice_b,opennotional_b,pnlrel_b,closestr_b,trendflag_b);
    %
    ns = size(tbls_data_consolidated,1);
    opentype_s = zeros(ns,1);%1-weak;2-medium;3-strong
    opensignal_s = cell(ns,1);
    code_s = cell(ns,1);
    assetname_s = cell(ns,1);
    direction_s = zeros(ns,1);
    openprice_s = zeros(ns,1);
    opennotional_s = zeros(ns,1);
    opendatetime_s = zeros(ns,1);
    opendate_s = zeros(ns,1);
    openid_s = zeros(ns,1);
    closestr_s = cell(ns,1);
    pnlrel_s = zeros(ns,1);
    trendflag_s = zeros(ns,1);

    for i = 1:ns
        opentype_s(i) = tbls_data_consolidated{i,2};
        opensignal_s{i} = tbls_data_consolidated{i,11};
        code_s{i} = tbls_data_consolidated{i,14};
        fut = code2instrument(code_s{i});
        assetname_s{i} = fut.asset_name;
        if isempty(fut.asset_name),assetname_s{i} = code_s{i};end
        direction_s(i) = tbls_data_consolidated{i,16};
        openprice_s(i) = tbls_data_consolidated{i,17};
        opennotional_s(i) = openprice_s(i)*fut.contract_size;
        opendatetime_s(i) = tbls_data_consolidated{i,13};
        opendate_s(i) = getlastbusinessdate(opendatetime_s(i));
        openid_s(i) = tbls_data_consolidated{i,15};
        closestr_s{i} = tbls_data_consolidated{i,19};
        pnlrel_s(i) = tbls_data_consolidated{i,18}/opennotional_s(i);
        trendflag_s(i) = tbls_data_consolidated{i,37};
    end
    tbl_extractedinfo_s = table(code_s,assetname_s,opentype_s,opensignal_s,direction_s,openid_s,opendatetime_s,opendate_s,openprice_s,opennotional_s,pnlrel_s,closestr_s,trendflag_s);
    %
    % merge long/short table for further analysis
    code = [code_b;code_s];
    assetname = [assetname_b;assetname_s];
    opentype = [opentype_b;opentype_s];
    opensignal = [opensignal_b;opensignal_s];
    direction = [direction_b;direction_s];
    openid = [openid_b;openid_s];
    opendatetime = [opendatetime_b;opendatetime_s];
    opendate = [opendate_b;opendate_s];
    openprice = [openprice_b;openprice_s];
    opennotional = [opennotional_b;opennotional_s];
    pnlrel = [pnlrel_b;pnlrel_s];
    closestr = [closestr_b;closestr_s];
    trendflag = [trendflag_b;trendflag_s];
    tbl_extractedinfo = table(code,assetname,opentype,opensignal,direction,openid,opendatetime,opendate,openprice,opennotional,pnlrel,closestr,trendflag);
    tbl_extractedinfo = sortrows(tbl_extractedinfo,'opendatetime','ascend');
    fprintf('data extracted...\n');
    %
    % 3. plot bmtc(buy-medium-trendconfirmed),bstc(buy-strong-trendconfirmed)
    % and smtc(sell-medium-trendconfirmed),sstc(sell-strong-trendconfirmed)
    idx_bmtc = zeros(nb,1);
    idx_bstc = zeros(nb,1);
    idx_smtc = zeros(ns,1);
    idx_sstc = zeros(ns,1);
    for i = 1:nb
        if opentype_b(i) == 2 && trendflag_b(i) == 1
            idx_bmtc(i) = 1;
        end
        if opentype_b(i) == 3 && trendflag_b(i) == 1
            idx_bstc(i) = 1;
        end
    end
    idx_bmtc = logical(idx_bmtc);
    idx_bstc = logical(idx_bstc);
    for i = 1:ns
        if opentype_s(i) == 2 && trendflag_s(i) == 1
            idx_smtc(i) = 1;
        end
        if opentype_s(i) == 3 && trendflag_s(i) == 1
            idx_sstc(i) = 1;
        end
    end
    idx_smtc = logical(idx_smtc);
    idx_sstc = logical(idx_sstc);
    tbl_bmtc = tbl_extractedinfo_b(idx_bmtc,:);
    tbl_bstc = tbl_extractedinfo_b(idx_bstc,:);
    tbl_smtc = tbl_extractedinfo_s(idx_smtc,:);
    tbl_sstc = tbl_extractedinfo_s(idx_sstc,:);
    for i = 1:4
        if i == 1
            pnl2check = tbl_bmtc.pnlrel_b;
            figuretitlestr = 'b-medium-trending';
        elseif i == 2
            pnl2check = tbl_bstc.pnlrel_b;
            figuretitlestr = 'b-strong-trending';
        elseif i == 3
            pnl2check = tbl_smtc.pnlrel_s;
            figuretitlestr = 's-medium-trending';
        elseif i == 4
            pnl2check = tbl_sstc.pnlrel_s;
            figuretitlestr = 's-strong-trending';
        end
        [winp_running,R_running,kelly_running] = calcrunningkelly(pnl2check);
        if i == 1
            close all;
            set(0,'defaultfigurewindowstyle','docked');
            fprintf('report of trending trasactions:\n');
            fprintf('\t%25s\t%5s\t%3s%9s%9s\n','type','winp','R','kelly','#trades')
        end
        figure(i+1);
        subplot(311);plot(winp_running,'r');title(figuretitlestr);ylabel('win prob');grid on;
        subplot(312);plot(R_running,'b');ylabel('win/loss');grid on;
        subplot(313);plot(kelly_running,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
        fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d\n',figuretitlestr,winp_running(end)*100,R_running(end),kelly_running(end)*100,size(kelly_running,1));
        if i == 4
            fprintf('\n');
        end
    end
    %
    %4.group by each asset in bmtc,bstc,smtc and sstc
    reportbyasset_tc = cell(4,1);
    for i = 1:4
        if i == 1
            pnl2check = tbl_bmtc.pnlrel_b;
            asset2check = tbl_bmtc.assetname_b;
            reportbyasset_tc{i}.name = 'bmtc';
            reportbyasset_tc{i}.direction = 'b';
        elseif i == 2
            pnl2check = tbl_bstc.pnlrel_b;
            asset2check = tbl_bstc.assetname_b;
            reportbyasset_tc{i}.name = 'bstc';
            reportbyasset_tc{i}.direction = 'b';
        elseif i == 3
            pnl2check = tbl_smtc.pnlrel_s;
            asset2check = tbl_smtc.assetname_s;
            reportbyasset_tc{i}.name = 'smtc';
            reportbyasset_tc{i}.direction = 's';
        elseif i == 4
            pnl2check = tbl_sstc.pnlrel_s;
            asset2check = tbl_sstc.assetname_s;
            reportbyasset_tc{i}.name = 'sstc';
            reportbyasset_tc{i}.direction = 's';
        end
        asset = unique(asset2check);
        nasset = size(asset,1);
        N = zeros(nasset,1);
        W = zeros(nasset,1);
        R = zeros(nasset,1);
        K = zeros(nasset,1);
        runningw = cell(nasset,1);
        ruuningr = cell(nasset,1);
        runningk = cell(nasset,1);
        for j = 1:nasset
            idx_j = strcmpi(asset2check,asset{j});
            pnl_j = pnl2check(idx_j);
            [w_j,r_j,k_j] = calcrunningkelly(pnl_j);
            N(j) = size(w_j,1);
            W(j) = w_j(end);
            R(j) = r_j(end);
            K(j) = k_j(end);
            runningw{j} = w_j;
            ruuningr{j} = r_j;
            runningk{j} = k_j;
        end
        tblreport = table(asset,N,W,R,K);
        tblreport = sortrows(tblreport,'K','descend');
        reportbyasset_tc{i}.table = tblreport;
        reportbyasset_tc{i}.runningw = runningw;
        reportbyasset_tc{i}.runningr = ruuningr;
        reportbyasset_tc{i}.runningk = runningk;
    end
    %
    %5.check un-trended breachup-lvlup and breachdn-lvldn trades
    fprintf('\n');
    fprintf('report of special untrended trasactions:\n');
    idx_breachuplvlup_tb = zeros(nb,1);
    for i = 1:nb
        if strcmpi(tbl_extractedinfo_b.opensignal_b{i,1},'breachup-lvlup') && tbl_extractedinfo_b.trendflag_b(i) == 0
            idx_breachuplvlup_tb(i) = 1;
        end
    end
    idx_breachuplvlup_tb = logical(idx_breachuplvlup_tb);
    pnl_breachuplvlup_tb = tbl_extractedinfo_b.pnlrel_b(idx_breachuplvlup_tb);
    [winp_breachuplvlup_tb,R_breachuplvlup_tb,kelly_breachuplvlup_tb] = calcrunningkelly(pnl_breachuplvlup_tb);
    figure(6)
    subplot(311);plot(winp_breachuplvlup_tb,'r');title('breachup-lvlup-tb');ylabel('win prob');grid on;
    subplot(312);plot(R_breachuplvlup_tb,'b');ylabel('win/loss');grid on;
    subplot(313);plot(kelly_breachuplvlup_tb,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
    fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d\n','breachup-lvlup-tb',winp_breachuplvlup_tb(end)*100,R_breachuplvlup_tb(end),kelly_breachuplvlup_tb(end)*100,size(kelly_breachuplvlup_tb,1));
    %
    idx_breachdnlvldn_tb = zeros(ns,1);
    for i = 1:ns
        if strcmpi(tbl_extractedinfo_s.opensignal_s{i,1},'breachdn-lvldn') && tbl_extractedinfo_s.trendflag_s(i) == 0
            idx_breachdnlvldn_tb(i) = 1;
        end
    end
    idx_breachdnlvldn_tb = logical(idx_breachdnlvldn_tb);
    pnl_breachdnlvldn_tb = tbl_extractedinfo_s.pnlrel_s(idx_breachdnlvldn_tb);
    [winp_breachdnlvldn_tb,R_breachdnlvldn_tb,kelly_breachdnlvldn_tb] = calcrunningkelly(pnl_breachdnlvldn_tb);
    figure(7)
    subplot(311);plot(winp_breachdnlvldn_tb,'r');title('breachdn-lvldn-tb');ylabel('win prob');grid on;
    subplot(312);plot(R_breachdnlvldn_tb,'b');ylabel('win/loss');grid on;
    subplot(313);plot(kelly_breachdnlvldn_tb,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
    fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d\n','breachdn-lvldn-tb',winp_breachdnlvldn_tb(end)*100,R_breachdnlvldn_tb(end),kelly_breachdnlvldn_tb(end)*100,size(kelly_breachdnlvldn_tb,1));
    %
    %6.check un-trended breachup-sshighvalue and breachdn-bshighvalue
    idx_breachupsshighvalue_tb = zeros(nb,1);
    for i = 1:nb
        if strcmpi(tbl_extractedinfo_b.opensignal_b{i,1},'breachup-sshighvalue') && tbl_extractedinfo_b.trendflag_b(i) == 0
            idx_breachupsshighvalue_tb(i) = 1;
        end
    end
    idx_breachupsshighvalue_tb = logical(idx_breachupsshighvalue_tb);
    pnl_breachupsshighvalue_tb = tbl_extractedinfo_b.pnlrel_b(idx_breachupsshighvalue_tb);
    [winp_breachupsshighvalue_tb,R_breachupsshighvalue_tb,kelly_breachupsshighvalue_tb] = calcrunningkelly(pnl_breachupsshighvalue_tb);
    figure(8)
    subplot(311);plot(winp_breachupsshighvalue_tb,'r');title('breachup-sshighvalue-tb');ylabel('win prob');grid on;
    subplot(312);plot(R_breachupsshighvalue_tb,'b');ylabel('win/loss');grid on;
    subplot(313);plot(kelly_breachupsshighvalue_tb,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
    fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d\n','breachup-sshighvalue-tb',winp_breachupsshighvalue_tb(end)*100,R_breachupsshighvalue_tb(end),kelly_breachupsshighvalue_tb(end)*100,size(kelly_breachupsshighvalue_tb,1));
    %
    idx_breachdnbshighvalue_tb = zeros(ns,1);
    for i = 1:ns
        if strcmpi(tbl_extractedinfo_s.opensignal_s{i,1},'breachdn-bshighvalue') && tbl_extractedinfo_s.trendflag_s(i) == 0
            idx_breachdnbshighvalue_tb(i) = 1;
        end
    end
    idx_breachdnbshighvalue_tb = logical(idx_breachdnbshighvalue_tb);
    pnl_breachdnbshighvalue_tb = tbl_extractedinfo_s.pnlrel_s(idx_breachdnbshighvalue_tb);
    [winp_breachdnbshighvalue_tb,R_breachdnbshighvalue_tb,kelly_breachdnbshighvalue_tb] = calcrunningkelly(pnl_breachdnbshighvalue_tb);
    figure(9)
    subplot(311);plot(winp_breachdnbshighvalue_tb,'r');title('breachdn-bshighvalue-tb');ylabel('win prob');grid on;
    subplot(312);plot(R_breachdnbshighvalue_tb,'b');ylabel('win/loss');grid on;
    subplot(313);plot(kelly_breachdnbshighvalue_tb,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
    fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d\n','breachdn-bshighvalue-tb',winp_breachdnbshighvalue_tb(end)*100,R_breachdnbshighvalue_tb(end),kelly_breachdnbshighvalue_tb(end)*100,size(kelly_breachdnbshighvalue_tb,1));
    fprintf('\n');
    %
    %7.group by each asset in breachuplvlup-tb,breachdn-lvldn-tb,breachup-sshighvalue-tb and breachdn-bshighvalue-tb
    reportbyasset_tb = cell(4,1);
    for i = 1:4
        if i == 1
            pnl2check = pnl_breachuplvlup_tb;
            asset2check = tbl_extractedinfo_b.assetname_b(idx_breachuplvlup_tb);
            reportbyasset_tb{i}.name = 'breachup-lvlup-tb';
            reportbyasset_tb{i}.direction = 'b';
        elseif i == 2
            pnl2check = pnl_breachdnlvldn_tb;
            asset2check = tbl_extractedinfo_s.assetname_s(idx_breachdnlvldn_tb);
            reportbyasset_tb{i}.name = 'breachdn-lvldn-tb';
            reportbyasset_tb{i}.direction = 's';
        elseif i == 3
            pnl2check = pnl_breachupsshighvalue_tb;
            asset2check = tbl_extractedinfo_b.assetname_b(idx_breachupsshighvalue_tb);
            reportbyasset_tb{i}.name = 'breachup-sshighvalue-tb';
            reportbyasset_tb{i}.direction = 'b';
        elseif i == 4
            pnl2check = pnl_breachdnbshighvalue_tb;
            asset2check = tbl_extractedinfo_s.assetname_s(idx_breachdnbshighvalue_tb);
            reportbyasset_tb{i}.name = 'breachdn-bshighvalue-tb';
            reportbyasset_tb{i}.direction = 's';
        end
        asset = unique(asset2check);
        nasset = size(asset,1);
        N = zeros(nasset,1);
        W = zeros(nasset,1);
        R = zeros(nasset,1);
        K = zeros(nasset,1);
        runningw = cell(nasset,1);
        ruuningr = cell(nasset,1);
        runningk = cell(nasset,1);
        for j = 1:nasset
            idx_j = strcmpi(asset2check,asset{j});
            pnl_j = pnl2check(idx_j);
            [w_j,r_j,k_j] = calcrunningkelly(pnl_j);
            N(j) = size(w_j,1);
            W(j) = w_j(end);
            R(j) = r_j(end);
            K(j) = k_j(end);
            runningw{j} = w_j;
            ruuningr{j} = r_j;
            runningk{j} = k_j;
        end
        tblreport = table(asset,N,W,R,K);
        tblreport = sortrows(tblreport,'K','descend');
        reportbyasset_tb{i}.table = tblreport;
        reportbyasset_tb{i}.runningw = runningw;
        reportbyasset_tb{i}.runningr = ruuningr;
        reportbyasset_tb{i}.runningk = runningk;
    end
    %
    %USED SIGNAL MODES WITH CONFIRMED TREND:
    % volblowup,breachup-lvlup,breachup-sshighvalue,breachup-highsc13,strongbreach-trendconfirmed,mediumbreach-trendconfirmed,volblowup2
    %USED SIGNAL MODES WITH UN-CONFIRMED TREND:
    % breachup-lvlup,breachup-sshighvalue,breachdn-lvldn,breachdn-bshighvalue
    %OTHER SIGNAL MODES
    %other signal modes with un-confirmed trend but
    %1.winning probabilty being higher than 40%
    %2.R being higher than 1.5
    %3.kelly criterion being greater than 0
end

