function [reportbyasset_tc,reportbyasset_tb,tbl_extractedinfo,kelly_table_l,kelly_table_s,tblbyasset_L,tblbyasset_S,strat_output] = kellydistributionsummary(inputstruct,varargin)
    p = inputParser;
    p.KeepUnmatched = true;p.CaseSensitive = false;
    p.addParameter('keepopenposition',false,@islogical);
    p.addParameter('useactiveonly',false,@islogical);
    p.parse(varargin{:});
    %
    keepopenposition = p.Results.keepopenposition;
    useactiveonly = p.Results.useactiveonly;
    
    %1.consolidate all tblb and tbls
    tblb_data_consolidated = inputstruct.tblb{1};
    openidxb = inputstruct.tblb{1}(:,1);
    openidxb = cell2mat(openidxb);
    hh = inputstruct.data{1}.hh(openidxb);
    hh = num2cell(hh);
    lvlup = inputstruct.data{1}.lvlup(openidxb);
    lvlup = num2cell(lvlup);
    tblb_data_consolidated = [tblb_data_consolidated,hh,lvlup];
    %
    tbls_data_consolidated = inputstruct.tbls{1};
    openidxs = inputstruct.tbls{1}(:,1);
    openidxs = cell2mat(openidxs);
    ll = inputstruct.data{1}.ll(openidxs);
    ll = num2cell(ll);
    lvldn = inputstruct.data{1}.lvldn(openidxs);
    lvldn = num2cell(lvldn);
    tbls_data_consolidated = [tbls_data_consolidated,ll,lvldn];
    %NOTE:the code above is hard-coded
    %********************************************************************
    for i = 2:size(inputstruct.tblb,1) 
        openidxb_i = inputstruct.tblb{i}(:,1);
        openidxb_i = cell2mat(openidxb_i);
        hh_i = inputstruct.data{i}.hh(openidxb_i);
        lvlup_i = inputstruct.data{i}.lvlup(openidxb_i);
        hh_i = num2cell(hh_i);
        lvlup_i = num2cell(lvlup_i);
        tempb_i = [inputstruct.tblb{i},hh_i,lvlup_i];
        if isempty(tblb_data_consolidated)
            tempnew = tempb_i;
        elseif isempty(tempb_i)
            tempnew = tblb_data_consolidated;
        else
            tempnew = [tblb_data_consolidated;tempb_i];
        end
        tblb_data_consolidated = tempnew;
        %
        %
        openidxs_i = inputstruct.tbls{i}(:,1);
        openidxs_i = cell2mat(openidxs_i);
        ll_i = inputstruct.data{i}.ll(openidxs_i);
        lvldn_i = inputstruct.data{i}.lvldn(openidxs_i);
        ll_i = num2cell(ll_i);
        lvldn_i = num2cell(lvldn_i);
        temps_i = [inputstruct.tbls{i},ll_i,lvldn_i];
        if isempty(tbls_data_consolidated)
            tempnew = temps_i;
        elseif isempty(temps_i)
            tempnew = tbls_data_consolidated;
        else
            tempnew = [tbls_data_consolidated;temps_i];
        end
        tbls_data_consolidated = tempnew;
    end
    %
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
        if ~keepopenposition
            if isempty(tblb_data_consolidated{i,colidx_closeid}),idxb(i) = 0;end
        end
    end
    for i = 1:ns
        %a.remove trades with unsatified open condition
        %b.remove trades with null pnl
        if ~isempty(tbls_data_consolidated{i,colidx_comment1}),idxs(i) = 0;end
        if isempty(tbls_data_consolidated{i,colidx_pnl}),idxs(i) = 0;end
        if isnan(tbls_data_consolidated{i,colidx_pnl}),idxs(i) = 0;end
        if ~keepopenposition
            if isempty(tbls_data_consolidated{i,colidx_closeid}),idxs(i) = 0;end
        end
    end
    idxb = logical(idxb);
    idxs = logical(idxs);
    tblb_data_consolidated = tblb_data_consolidated(idxb,:);
    tbls_data_consolidated = tbls_data_consolidated(idxs,:);
    fprintf('data consolidated...\n');
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
    closedatetime_b = zeros(nb,1);
    pnlrel_b = zeros(nb,1);
    trendflag_b = zeros(nb,1);
    idxb = ones(nb,1);
    hh = zeros(nb,1);
    lvlup = zeros(nb,1);
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
        if isempty(fut.asset_name)
            idxb(i) = 1;
        else
            try
                last_trade_month = month(fut.last_trade_date1);
                last_trade_year = year(fut.last_trade_date1);
                if year(opendatetime_b(i)) == last_trade_year && ...
                        month(opendatetime_b(i)) == last_trade_month
                    idxb(i) = 0;
                end
            catch
                idxb(i) = 1;
            end
        end
        openid_b(i) = tblb_data_consolidated{i,15};
        closestr_b{i} = tblb_data_consolidated{i,19};
        closedatetime_b(i) = tblb_data_consolidated{i,41};
        if strcmpi(fut.code_ctp,'gzhy') || strcmpi(fut.code_ctp,'gzhy_30y') || strcmpi(fut.code_ctp,'gkhy')
            pnlrel_b(i) = tblb_data_consolidated{i,18};
        else
            pnlrel_b(i) = tblb_data_consolidated{i,18}/opennotional_b(i);
        end
        trendflag_b(i) = tblb_data_consolidated{i,37};
        hh(i) = tblb_data_consolidated{i,42};
        lvlup(i) = tblb_data_consolidated{i,43};
    end
    idxb = logical(idxb);
    tbl_extractedinfo_b = table(code_b,assetname_b,opentype_b,opensignal_b,direction_b,openid_b,opendatetime_b,opendate_b,openprice_b,opennotional_b,pnlrel_b,closedatetime_b,closestr_b,trendflag_b,hh,lvlup);
    tbl_extractedinfo_b = tbl_extractedinfo_b(idxb,:);
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
    closedatetime_s = zeros(ns,1);
    pnlrel_s = zeros(ns,1);
    trendflag_s = zeros(ns,1);
    idxs = ones(ns,1);
    ll = zeros(ns,1);
    lvldn = zeros(ns,1);
    for i = 1:ns
        opentype_s(i) = tbls_data_consolidated{i,2};
        opensignal_s{i} = tbls_data_consolidated{i,11};
        code_s{i} = tbls_data_consolidated{i,14};
        try
            fut = code2instrument(code_s{i});
        catch
            fprintf('error in code2instrument of %s\n',code_s{i});
            return
        end
        assetname_s{i} = fut.asset_name;
        if isempty(fut.asset_name),assetname_s{i} = code_s{i};end
        direction_s(i) = tbls_data_consolidated{i,16};
        openprice_s(i) = tbls_data_consolidated{i,17};
        opennotional_s(i) = openprice_s(i)*fut.contract_size;
        opendatetime_s(i) = tbls_data_consolidated{i,13};
        opendate_s(i) = getlastbusinessdate(opendatetime_s(i));
        if isempty(fut.asset_name)
            idxs(i) = 1;
        else
            try
                last_trade_month = month(fut.last_trade_date1);
                last_trade_year = year(fut.last_trade_date1);
                if year(opendatetime_s(i)) == last_trade_year && ...
                        month(opendatetime_s(i)) == last_trade_month
                    idxb(i) = 0;
                end
            catch
                idxs(i) = 1;
            end
        end
        openid_s(i) = tbls_data_consolidated{i,15};
        closestr_s{i} = tbls_data_consolidated{i,19};
        closedatetime_s(i) = tbls_data_consolidated{i,41};
        if strcmpi(fut.code_ctp,'gzhy') || strcmpi(fut.code_ctp,'gzhy_30y') || strcmpi(fut.code_ctp,'gkhy')
            pnlrel_s(i) = tbls_data_consolidated{i,18};
        else
            pnlrel_s(i) = tbls_data_consolidated{i,18}/opennotional_s(i);
        end
        trendflag_s(i) = tbls_data_consolidated{i,37};
        ll(i) = tbls_data_consolidated{i,42};
        lvldn(i) = tbls_data_consolidated{i,42};
    end
    idxs = logical(idxs);
    tbl_extractedinfo_s = table(code_s,assetname_s,opentype_s,opensignal_s,direction_s,openid_s,opendatetime_s,opendate_s,openprice_s,opennotional_s,pnlrel_s,closestr_s,closedatetime_s,trendflag_s,ll,lvldn);
    tbl_extractedinfo_s = tbl_extractedinfo_s(idxs,:);
    %
    % merge long/short table for further analysis
    code = [tbl_extractedinfo_b.code_b;tbl_extractedinfo_s.code_s];
    assetname = [tbl_extractedinfo_b.assetname_b;tbl_extractedinfo_s.assetname_s];
    opentype = [tbl_extractedinfo_b.opentype_b;tbl_extractedinfo_s.opentype_s];
    opensignal = [tbl_extractedinfo_b.opensignal_b;tbl_extractedinfo_s.opensignal_s];
    direction = [tbl_extractedinfo_b.direction_b;tbl_extractedinfo_s.direction_s];
    openid = [tbl_extractedinfo_b.openid_b;tbl_extractedinfo_s.openid_s];
    opendatetime = [tbl_extractedinfo_b.opendatetime_b;tbl_extractedinfo_s.opendatetime_s];
    opendate = [tbl_extractedinfo_b.opendate_b;tbl_extractedinfo_s.opendate_s];
    openprice = [tbl_extractedinfo_b.openprice_b;tbl_extractedinfo_s.openprice_s];
    opennotional = [tbl_extractedinfo_b.opennotional_b;tbl_extractedinfo_s.opennotional_s];
    pnlrel = [tbl_extractedinfo_b.pnlrel_b;tbl_extractedinfo_s.pnlrel_s];
    closestr = [tbl_extractedinfo_b.closestr_b;tbl_extractedinfo_s.closestr_s];
    closedatetime = [tbl_extractedinfo_b.closedatetime_b;tbl_extractedinfo_s.closedatetime_s];
    trendflag = [tbl_extractedinfo_b.trendflag_b;tbl_extractedinfo_s.trendflag_s];
    barrierfractal = [tbl_extractedinfo_b.hh;tbl_extractedinfo_s.ll];
    barriertdsq = [tbl_extractedinfo_b.lvlup;tbl_extractedinfo_s.lvldn];
    tbl_extractedinfo = table(code,assetname,opentype,opensignal,direction,openid,opendatetime,opendate,openprice,opennotional,pnlrel,closestr,closedatetime,trendflag,barrierfractal,barriertdsq);
    tbl_extractedinfo = sortrows(tbl_extractedinfo,'opendatetime','ascend');
    if useactiveonly
        nrecords = size(tbl_extractedinfo,1);
        isactivefut = zeros(nrecords,1);
        activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
        bds = tbl_extractedinfo.opendate;
        fn = ['activefutures_',datestr(bds(1),'yyyymmdd'),'.txt'];
        futlist = cDataFileIO.loadDataFromTxtFile([activefuturesdir,fn]);
        isactivefut(1) = sum(strcmpi(futlist,tbl_extractedinfo.code(1)));
        for i = 2:nrecords
            if bds(i) ~= bds(i-1)
                fn = ['activefutures_',datestr(bds(i),'yyyymmdd'),'.txt'];
                futlist = cDataFileIO.loadDataFromTxtFile([activefuturesdir,fn]);  
            end
            isactivefut(i) = sum(strcmpi(futlist,tbl_extractedinfo.code(i)));
        end
        isactivefut = logical(isactivefut);
        tbl_extractedinfo = tbl_extractedinfo(isactivefut,:);
    end
    
    fprintf('data extracted...\n');
    %
    % 3. plot bmtc(buy-medium-trendconfirmed),bstc(buy-strong-trendconfirmed)
    % and smtc(sell-medium-trendconfirmed),sstc(sell-strong-trendconfirmed)
%     nb = size(tbl_extractedinfo_b,1);
%     ns = size(tbl_extractedinfo_s,1);
    %
    fprintf('\n');
    fprintf('report of special trended trasactions:\n');
    fprintf('\t%25s\t%5s\t%3s%9s%9s%9s%9s\n','type','winp','R','kelly','#trades','use','kstest')
    %
    modeSpecial = {'breachup-lvlup-tc';...
        'breachup-lvlup-tc-all';
        'breachdn-lvldn-tc';...
        'breachdn-lvldn-tc-all';...
        'breachup-sshighvalue-tc';...
        'breachdn-bshighvalue-tc';...
        'breachup-highsc13';...
        'breachdn-lowbc13'};
    modeTrend = {'bmtc';...
        'bstc';...
        'smtc';...
        'sstc'};
    nSpecial = length(modeSpecial);
    reportbyasset_tc = cell(nSpecial+length(modeTrend),1);
    
    for iMode = 1:length(modeSpecial)
        if strcmpi(modeSpecial{iMode}(1:8),'breachup')
            resOut = kellytest(tbl_extractedinfo,modeSpecial{iMode},1);
        else
            resOut = kellytest(tbl_extractedinfo,modeSpecial{iMode},-1);
        end
        if isnan(resOut.wMu)
            fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d%9d%9s\n',modeSpecial{iMode},resOut.wSample*100,resOut.rSample,resOut.kSample*100,size(resOut.tblout,1),resOut.use,...
                [num2str(0),'-',num2str(0),'-',num2str(0)]);
        else
            fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d%9d%9s\n',modeSpecial{iMode},resOut.wMu*100,resOut.rMu,resOut.kMu*100,size(resOut.tblout,1),resOut.use,...
                [num2str(resOut.wH),'-',num2str(resOut.rH),'-',num2str(resOut.kH)]);
        end
        pnl2check = resOut.tblout.pnlrel;
        asset2check = resOut.tblout.assetname;
        reportbyasset_tc{iMode}.name = modeSpecial{iMode};
        if strfind(modeSpecial{iMode},'breachup')
            reportbyasset_tc{iMode}.direction = 'b';
        else
            reportbyasset_tc{iMode}.direction = 's';
        end
        reportbyasset_tc{iMode}.use = resOut.use;
        reportbyasset_tc{iMode}.kMu = resOut.kMu;
        reportbyasset_tc{iMode}.kstest = [num2str(resOut.wH),'-',num2str(resOut.rH),'-',num2str(resOut.kH)];
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
        reportbyasset_tc{iMode}.table = tblreport;
        reportbyasset_tc{iMode}.runningw = runningw;
        reportbyasset_tc{iMode}.runningr = ruuningr;
        reportbyasset_tc{iMode}.runningk = runningk;
    end
    fprintf('\n');
    %
    fprintf('report of normal trended trasactions:\n');
    fprintf('\t%25s\t%5s\t%3s%9s%9s%9s%9s\n','type','winp','R','kelly','#trades','use','kstest')
    
    for iMode = 1:length(modeTrend)
        if strcmpi(modeTrend{iMode}(1),'b')
            resOut = kellytest(tbl_extractedinfo,modeTrend{iMode},1);
        else
            resOut = kellytest(tbl_extractedinfo,modeTrend{iMode},-1);
        end
        if isnan(resOut.wMu)
            fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d%9d%9s\n',modeTrend{iMode},resOut.wSample*100,resOut.rSample,resOut.kSample*100,size(resOut.tblout,1),resOut.use,...
                [num2str(0),'-',num2str(0),'-',num2str(0)]);
        else
            fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d%9d%9s\n',modeTrend{iMode},resOut.wMu*100,resOut.rMu,resOut.kMu*100,size(resOut.tblout,1),resOut.use,...
                [num2str(resOut.wH),'-',num2str(resOut.rH),'-',num2str(resOut.kH)]);
        end
%         if iMode == 1
%             close all;
%             set(0,'defaultfigurewindowstyle','docked');
%         end
%         [winp_running,R_running,kelly_running] = calcrunningkelly(resOut.tblout.pnlrel);
%         figure(iMode+1);
%         subplot(311);plot(winp_running,'r');title(modeTrend{iMode});ylabel('winning rates');grid on;
%         subplot(312);plot(R_running,'b');ylabel('odds rates');grid on;
%         subplot(313);plot(kelly_running,'g');xlabel('number of trades');ylabel('kelly criteria');grid on;
        pnl2check = resOut.tblout.pnlrel;
        asset2check = resOut.tblout.assetname;
        reportbyasset_tc{iMode+nSpecial}.name = modeTrend{iMode};
        reportbyasset_tc{iMode+nSpecial}.direction = modeTrend{iMode}(1);
        reportbyasset_tc{iMode+nSpecial}.use = resOut.use;
        reportbyasset_tc{iMode+nSpecial}.kMu = resOut.kMu;
        reportbyasset_tc{iMode+nSpecial}.kstest = [num2str(resOut.wH),'-',num2str(resOut.rH),'-',num2str(resOut.kH)];
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
        reportbyasset_tc{iMode+nSpecial}.table = tblreport;
        reportbyasset_tc{iMode+nSpecial}.runningw = runningw;
        reportbyasset_tc{iMode+nSpecial}.runningr = ruuningr;
        reportbyasset_tc{iMode+nSpecial}.runningk = runningk;
    end
    fprintf('\n');
    %
    fprintf('report of special untrended trasactions:\n');
    fprintf('\t%25s\t%5s\t%3s%9s%9s%9s%9s\n','type','winp','R','kelly','#trades','use','kstest')
    modeSpecialUntrend = {'breachup-lvlup-tb';...
        'breachdn-lvldn-tb';...
        'breachup-sshighvalue-tb';...
        'breachdn-bshighvalue-tb'};
    reportbyasset_tb = cell(length(modeSpecialUntrend),1);
    for iMode = 1:length(modeSpecialUntrend)
        if strcmpi(modeSpecialUntrend{iMode}(1:8),'breachup')
            resOut = kellytest(tbl_extractedinfo,modeSpecialUntrend{iMode},1);
        else
            resOut = kellytest(tbl_extractedinfo,modeSpecialUntrend{iMode},-1);
        end
        if isnan(resOut.wMu)
            fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d%9d%9s\n',modeSpecialUntrend{iMode},resOut.wSample*100,resOut.rSample,resOut.kSample*100,size(resOut.tblout,1),resOut.use,...
                [num2str(0),'-',num2str(0),'-',num2str(0)]);
        else
            fprintf('\t%25s\t%2.1f%%\t%1.1f%8.1f%%%9d%9d%9s\n',modeSpecialUntrend{iMode},resOut.wMu*100,resOut.rMu,resOut.kMu*100,size(resOut.tblout,1),resOut.use,...
                [num2str(resOut.wH),'-',num2str(resOut.rH),'-',num2str(resOut.kH)]);
        end
        pnl2check = resOut.tblout.pnlrel;
        asset2check = resOut.tblout.assetname;
        reportbyasset_tb{iMode}.name = modeSpecialUntrend{iMode};
        if strfind(modeSpecial{iMode},'breachup')
            reportbyasset_tb{iMode}.direction = 'b';
        else
            reportbyasset_tb{iMode}.direction = 's';
        end
        reportbyasset_tb{iMode}.use = resOut.use;
        reportbyasset_tb{iMode}.kMu = resOut.kMu;
        reportbyasset_tb{iMode}.kstest = [num2str(resOut.wH),'-',num2str(resOut.rH),'-',num2str(resOut.kH)];
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
        reportbyasset_tb{iMode}.table = tblreport;
        reportbyasset_tb{iMode}.runningw = runningw;
        reportbyasset_tb{iMode}.runningr = ruuningr;
        reportbyasset_tb{iMode}.runningk = runningk;
    end
    fprintf('\n');
    %
    %USED SIGNAL MODES WITH CONFIRMED TREND:
    % volblowup,breachup-lvlup,breachup-sshighvalue,breachup-highsc13,strongbreach-trendconfirmed,mediumbreach-trendconfirmed,volblowup2
    %USED SIGNAL MODES WITH UN-CONFIRMED TREND:
    % breachup-lvlup,breachup-sshighvalue,breachdn-lvldn,breachdn-bshighvalue
    %OTHER SIGNAL MODES
    %other signal modes with un-confirmed trend but
    %1.winning probabilty being higher than 40%
    %2.R being higher than 3 (annualized)
    %3.kelly criterion being greater than 1.15
    idx_l = tbl_extractedinfo.direction == 1;
    signal_l = tbl_extractedinfo.opensignal(idx_l);
    opensignal_unique_l = unique(signal_l);
    nsignal_l = length(opensignal_unique_l);
    ntrades_unique_l = zeros(nsignal_l,1);
    use_unique_l = zeros(nsignal_l,1);
    winp_unique_l = use_unique_l;winp_unique_l_sample = winp_unique_l;
    r_unique_l = use_unique_l;r_unique_l_sample = r_unique_l;
    kelly_unique_l = use_unique_l;kelly_unique_l_sample = kelly_unique_l;
    kstest_unique_l = cell(nsignal_l,1);
    

    for iSignal = 1:nsignal_l
        signal_l_i = opensignal_unique_l{iSignal};
        resSignal_l_i = kellytest(tbl_extractedinfo,signal_l_i,1);
        ntrades_unique_l(iSignal) = size(resSignal_l_i.tblout,1);
        use_unique_l(iSignal) = resSignal_l_i.use;
        if strcmpi(signal_l_i,'volblowup2') || strcmpi(signal_l_i,'volblowup')
            use_unique_l(iSignal) = 1;
        end
        winp_unique_l(iSignal) = resSignal_l_i.wMu;
        r_unique_l(iSignal) = resSignal_l_i.rMu;
        kelly_unique_l(iSignal) = resSignal_l_i.kMu;
        kstest_unique_l{iSignal} = [num2str(resSignal_l_i.wH),'-',num2str(resSignal_l_i.rH),'-',num2str(resSignal_l_i.kH)];
        winp_unique_l_sample(iSignal) = resSignal_l_i.wSample;
        r_unique_l_sample(iSignal) = resSignal_l_i.rSample;
        kelly_unique_l_sample(iSignal) = resSignal_l_i.kSample;
    end
     
    kelly_table_l = table(opensignal_unique_l,ntrades_unique_l,winp_unique_l,r_unique_l,kelly_unique_l,use_unique_l,kstest_unique_l,winp_unique_l_sample,r_unique_l_sample,kelly_unique_l_sample);
    %
    idx_s = tbl_extractedinfo.direction == -1;
    signal_s = tbl_extractedinfo.opensignal(idx_s);
    opensignal_unique_s = unique(signal_s);
    nsignal_s = length(opensignal_unique_s);
    ntrades_unique_s = zeros(nsignal_s,1);
    use_unique_s = zeros(nsignal_s,1);
    winp_unique_s = use_unique_s;winp_unique_s_sample = winp_unique_s;
    r_unique_s = use_unique_s;r_unique_s_sample = r_unique_s;
    kelly_unique_s = use_unique_s;kelly_unique_s_sample = kelly_unique_s;
    kstest_unique_s = cell(nsignal_s,1);

    for iSignal = 1:nsignal_s
        signal_s_i = opensignal_unique_s{iSignal};
        resSignal_s_i = kellytest(tbl_extractedinfo,signal_s_i,-1);
        ntrades_unique_s(iSignal) = size(resSignal_s_i.tblout,1);
        use_unique_s(iSignal) = resSignal_s_i.use;
        if strcmpi(signal_s_i,'volblowup2') || strcmpi(signal_s_i,'volblowup')
            use_unique_l(iSignal) = 1;
        end
        winp_unique_s(iSignal) = resSignal_s_i.wMu;
        r_unique_s(iSignal) = resSignal_s_i.rMu;
        kelly_unique_s(iSignal) = resSignal_s_i.kMu;
        kstest_unique_s{iSignal} = [num2str(resSignal_s_i.wH),'-',num2str(resSignal_s_i.rH),'-',num2str(resSignal_s_i.kH)];
        winp_unique_s_sample(iSignal) = resSignal_s_i.wSample;
        r_unique_s_sample(iSignal) = resSignal_s_i.rSample;
        kelly_unique_s_sample(iSignal) = resSignal_s_i.kSample;
    end
    kelly_table_s = table(opensignal_unique_s,ntrades_unique_s,winp_unique_s,r_unique_s,kelly_unique_s,use_unique_s,kstest_unique_s,winp_unique_s_sample,r_unique_s_sample,kelly_unique_s_sample);
    %
    %
    %
    signal_l_valid = kelly_table_l.opensignal_unique_l(logical(kelly_table_l.use_unique_l));
    idx_signal_l_valid = strcmpi(tbl_extractedinfo.opensignal,signal_l_valid{1}) & tbl_extractedinfo.direction == 1;
    for iSignal = 2:length(signal_l_valid)
        idx_i = strcmpi(tbl_extractedinfo.opensignal,signal_l_valid{iSignal}) & tbl_extractedinfo.direction == 1;
        idx_signal_l_valid = idx_signal_l_valid | idx_i;
    end
    pnl_l_valid = tbl_extractedinfo.pnlrel(idx_signal_l_valid);
    [w_l_valid,r_l_valid,k_l_valid] = calcrunningkelly(pnl_l_valid);
    W_L_ALL = w_l_valid(end);
    R_L_ALL = r_l_valid(end);
    K_L_ALL = k_l_valid(end);
    %
    signal_s_valid = kelly_table_s.opensignal_unique_s(logical(kelly_table_s.use_unique_s));
    idx_signal_s_valid = strcmpi(tbl_extractedinfo.opensignal,signal_s_valid{1}) & tbl_extractedinfo.direction == -1;
    for iSignal = 2:length(signal_s_valid)
        idx_i = strcmpi(tbl_extractedinfo.opensignal,signal_s_valid{iSignal}) & tbl_extractedinfo.direction == -1;
        idx_signal_s_valid = idx_signal_s_valid | idx_i;
    end
    pnl_s_valid = tbl_extractedinfo.pnlrel(idx_signal_s_valid);
    [w_s_valid,r_s_valid,k_s_valid] = calcrunningkelly(pnl_s_valid);
    W_S_ALL = w_s_valid(end);
    R_S_ALL = r_s_valid(end);
    K_S_ALL = k_s_valid(end);
    %
    idx_signal_valid = idx_signal_l_valid | idx_signal_s_valid;
    pnl_valid = tbl_extractedinfo.pnlrel(idx_signal_valid);
    [w_valid,r_valid,k_valid] = calcrunningkelly(pnl_valid);
    W_BS_ALL = w_valid(end);
    R_BS_ALL = r_valid(end);
    K_BS_ALL = k_valid(end);
    %
    %
    tbl_l_valid = tbl_extractedinfo(idx_signal_l_valid,:);
    assetcolumn = tbl_l_valid.assetname;
    assetlist = unique(assetcolumn);
    nasset = length(assetlist);
    N_L = zeros(nasset+1,1);
    W_L = zeros(nasset+1,1);
    R_L = zeros(nasset+1,1);
    K_L = zeros(nasset+1,1);
    for i = 1:nasset
        assetidx = strcmpi(assetcolumn,assetlist{i});
        tbl_i = tbl_l_valid(assetidx,:);
        pnl_i = tbl_l_valid.pnlrel(assetidx);
        N_L(i) = size(tbl_i,1);
        [w_,r_,k_] = calcrunningkelly(pnl_i);
        W_L(i) = w_(end);
        R_L(i) = r_(end);
        K_L(i) = k_(end);
    end
    assetlist{nasset+1,1} = 'all';
    W_L(nasset+1,1) = W_L_ALL;
    R_L(nasset+1,1) = R_L_ALL;
    K_L(nasset+1,1) = K_L_ALL;
    N_L(nasset+1,1) = sum(N_L(1:end-1));
    tblbyasset_L = table(assetlist,N_L,W_L,R_L,K_L);
    tblbyasset_L = sortrows(tblbyasset_L,'K_L','descend');
    %
    tbl_s_valid = tbl_extractedinfo(idx_signal_s_valid,:);
    assetcolumn = tbl_s_valid.assetname;
    assetlist = unique(assetcolumn);
    nasset = length(assetlist);
    N_S = zeros(nasset+1,1);
    W_S = zeros(nasset+1,1);
    R_S = zeros(nasset+1,1);
    K_S = zeros(nasset+1,1);
    for i = 1:nasset
        assetidx = strcmpi(assetcolumn,assetlist{i});
        tbl_i = tbl_s_valid(assetidx,:);
        pnl_i = tbl_s_valid.pnlrel(assetidx);
        N_S(i) = size(tbl_i,1);
        [w_,r_,k_] = calcrunningkelly(pnl_i);
        W_S(i) = w_(end);
        R_S(i) = r_(end);
        K_S(i) = k_(end);
    end
    assetlist{nasset+1,1} = 'all';
    W_S(nasset+1,1) = W_S_ALL;
    R_S(nasset+1,1) = R_S_ALL;
    K_S(nasset+1,1) = K_S_ALL;
    N_S(nasset+1,1) = sum(N_S(1:end-1));
    tblbyasset_S = table(assetlist,N_S,W_S,R_S,K_S);
    tblbyasset_S = sortrows(tblbyasset_S,'K_S','descend');
    %
    tbl_valid = tbl_extractedinfo(idx_signal_valid,:);
    assetcolumn = tbl_valid.assetname;
    assetlist = unique(assetcolumn);
    nasset = length(assetlist);
    N_BS = zeros(nasset+1,1);
    W_BS = zeros(nasset+1,1);
    R_BS = zeros(nasset+1,1);
    K_BS = zeros(nasset+1,1);
    for i = 1:nasset
        assetidx = strcmpi(assetcolumn,assetlist{i});
        tbl_i = tbl_valid(assetidx,:);
        pnl_i = tbl_valid.pnlrel(assetidx);
        N_BS(i) = size(tbl_i,1);
        [w_,r_,k_] = calcrunningkelly(pnl_i);
        W_BS(i) = w_(end);
        R_BS(i) = r_(end);
        K_BS(i) = k_(end);
    end
    assetlist{nasset+1,1} = 'all';
    W_BS(nasset+1,1) = W_BS_ALL;
    R_BS(nasset+1,1) = R_BS_ALL;
    K_BS(nasset+1,1) = K_BS_ALL;
    N_BS(nasset+1,1) = sum(N_BS(1:end-1));
    tblbyasset_BS = table(assetlist,N_BS,W_BS,R_BS,K_BS);
    tblbyasset_BS = sortrows(tblbyasset_BS,'K_BS','descend');
    
    %
    % calculate kelly and winp matrix
    signal_l_ = kelly_table_l.opensignal_unique_l(logical(kelly_table_l.use_unique_l));
    signal_s_ = kelly_table_s.opensignal_unique_s(logical(kelly_table_s.use_unique_s));
    assetlist_ = unique([tblbyasset_L.assetlist;tblbyasset_S.assetlist]);
    nasset = size(assetlist_,1);
    %
    WMat_L_ = zeros(length(signal_l_),nasset);
    RMat_L_ = WMat_L_;
    KMat_L_ = WMat_L_;
    for i = 1:length(signal_l_)
        for j = 1:nasset
            ret = kellyempirical2('table',tbl_extractedinfo,'assetname',assetlist_{j},'direction','l','signalname',signal_l_{i});
            WMat_L_(i,j) = ret.W;
            RMat_L_(i,j) = ret.R;
            KMat_L_(i,j) = ret.K;
        end
    end
    %
    WMat_S_ = zeros(length(signal_s_),nasset);
    RMat_S_ = WMat_S_;
    KMat_S_ = WMat_S_;
    for i = 1:length(signal_s_)
        for j = 1:nasset
            ret = kellyempirical2('table',tbl_extractedinfo,'assetname',assetlist_{j},'direction','s','signalname',signal_s_{i});
            WMat_S_(i,j) = ret.W;
            RMat_S_(i,j) = ret.R;
            KMat_S_(i,j) = ret.K;
        end
    end
    fprintf('kelly and winprob matrix calculated....\n');
    %
    strat_output = struct('tblbyasset_l',tblbyasset_L,...
        'tblbyasset_s',tblbyasset_S,...
        'tblbyasset_bs',tblbyasset_BS,...
        'kelly_table_l',kelly_table_l,...
        'kelly_table_s',kelly_table_s,...
        reportbyasset_tc{nSpecial+1}.name,reportbyasset_tc{nSpecial+1}.table,...
        reportbyasset_tc{nSpecial+2}.name,reportbyasset_tc{nSpecial+2}.table,...
        reportbyasset_tc{nSpecial+3}.name,reportbyasset_tc{nSpecial+3}.table,...
        reportbyasset_tc{nSpecial+4}.name,reportbyasset_tc{nSpecial+4}.table,...
        'breachuplvlup_tb',reportbyasset_tb{1}.table,...
        'breachdnlvldn_tb',reportbyasset_tb{2}.table,...
        'breachupsshighvalue_tb',reportbyasset_tb{3}.table,...
        'breachdnbshighvalue_tb',reportbyasset_tb{4}.table,...
        'breachuplvlup_tc',reportbyasset_tc{1}.table,...
        'breachuplvlup_tc_all',reportbyasset_tc{2}.table,...
        'breachdnlvldn_tc',reportbyasset_tc{3}.table,...
        'breachdnlvldn_tc_all',reportbyasset_tc{4}.table,...
        'breachupsshighvalue_tc',reportbyasset_tc{5}.table,...
        'breachdnbshighvalue_tc',reportbyasset_tc{6}.table,...
        'breachuphighsc13',reportbyasset_tc{7}.table,...
        'breachdnlowbc13',reportbyasset_tc{8}.table,...
        'kelly_matrix_l',KMat_L_,...
        'kelly_matrix_s',KMat_S_,...
        'winprob_matrix_l',WMat_L_,...
        'winprob_matrix_s',WMat_S_,...
        'signal_l',{signal_l_},...
        'signal_s',{signal_s_},...
        'asset_list',{assetlist_'});
    
end

