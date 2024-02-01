function [tbl_report,stats_report] = kellydistributionreport(tbl_trades,struct_distributions)

% add
% columns:year,month,weeknum,kellygeneral,kellyspecial,use1,use2,kellyused
    yearinfo = year(tbl_trades.opendatetime);
    monthinfo = month(tbl_trades.opendatetime);
    weeknuminfo = weeknum(tbl_trades.opendatetime);
    if size(monthinfo,1) ~= size(weeknuminfo,1)
        weeknuminfo = weeknuminfo';
    end
    %
    n = size(tbl_trades,1);
    % calculate those columns to be added
    kellygeneral = zeros(n,1);
    kellyspecial = nan(n,1);
    kellyused = zeros(n,1);
    use1 = zeros(n,1);
    use2 = zeros(n,1);
    for i = 1:n
        if tbl_trades.direction(i) == 1
            idx = strcmpi(struct_distributions.kelly_table_l.opensignal_unique_l,tbl_trades.opensignal{i});
            kellygeneral(i) = struct_distributions.kelly_table_l.kelly_unique_l(idx);
            use1(i) = struct_distributions.kelly_table_l.use_unique_l(idx);
            %
            if strcmpi(tbl_trades.opensignal{i},'breachup-highsc13')
                idx2 = strcmpi(struct_distributions.breachuphighsc13.asset,tbl_trades.assetname{i});
                kellyspecial(i) = struct_distributions.breachuphighsc13.K(idx2);
            elseif strcmpi(tbl_trades.opensignal{i},'breachup-lvlup')
                if tbl_trades.trendflag(i) == 1
                    if tbl_trades.barrierfractal(i) >= tbl_trades.barriertdsq(i)
                        idx2 = strcmpi(struct_distributions.breachuplvlup_tc.asset,tbl_trades.assetname{i});
                        kellyspecial(i) = struct_distributions.breachuplvlup_tc.K(idx2);
                    else
                        if tbl_trades.opentype(i) == 2
                            idx2 = strcmpi(struct_distributions.bmtc.asset,tbl_trades.assetname{i});
                            kellyspecial(i) = struct_distributions.bmtc.K(idx2);
                        elseif tbl_trades.opentype(i) == 3
                            idx2 = strcmpi(struct_distributions.bstc.asset,tbl_trades.assetname{i});
                            kellyspecial(i) = struct_distributions.bstc.K(idx2);
                        end
                    end
                else
                    idx2 = strcmpi(struct_distributions.breachuplvlup_tb.asset,tbl_trades.assetname{i});
                    kellyspecial(i) = struct_distributions.breachuplvlup_tb.K(idx2);
                end
            elseif strcmpi(tbl_trades.opensignal{i},'breachup-sshighvalue')
                if tbl_trades.trendflag(i) == 1
                    idx2 = strcmpi(struct_distributions.breachupsshighvalue_tc.asset,tbl_trades.assetname{i});
                    kellyspecial(i) = struct_distributions.breachupsshighvalue_tc.K(idx2);
                else
                    idx2 = strcmpi(struct_distributions.breachupsshighvalue_tb.asset,tbl_trades.assetname{i});
                    kellyspecial(i) = struct_distributions.breachupsshighvalue_tb.K(idx2);
                end
            elseif strcmpi(tbl_trades.opensignal{i},'mediumbreach-trendconfirmed') || ...
                    strcmpi(tbl_trades.opensignal{i},'strongbreach-trendconfirmed') || ...
                    strcmpi(tbl_trades.opensignal{i},'volblowup') || ...
                    strcmpi(tbl_trades.opensignal{i},'volblowup2')
                if tbl_trades.opentype(i) == 2
                    idx2 = strcmpi(struct_distributions.bmtc.asset,tbl_trades.assetname{i});
                    kellyspecial(i) = struct_distributions.bmtc.K(idx2);
                elseif tbl_trades.opentype(i) == 3
                    idx2 = strcmpi(struct_distributions.bstc.asset,tbl_trades.assetname{i});
                    kellyspecial(i) = struct_distributions.bstc.K(idx2);
                end
            else
                idx_row = strcmpi(struct_distributions.signal_l,tbl_trades.opensignal{i});
                idx_col = strcmpi(struct_distributions.asset_list,tbl_trades.assetname{i});
                temp = struct_distributions.kelly_matrix_l(idx_row,idx_col);
                if ~isempty(temp)
                    kellyspecial(i) = temp;
                end
            end
        else
            idx = strcmpi(struct_distributions.kelly_table_s.opensignal_unique_s,tbl_trades.opensignal{i});
            kellygeneral(i) = struct_distributions.kelly_table_s.kelly_unique_s(idx);
            use1(i) = struct_distributions.kelly_table_s.use_unique_s(idx);
            %
            if strcmpi(tbl_trades.opensignal{i},'breachdn-lowbc13')
                idx2 = strcmpi(struct_distributions.breachdnlowbc13.asset,tbl_trades.assetname{i});
                kellyspecial(i) = struct_distributions.breachdnlowbc13.K(idx2);
            elseif strcmpi(tbl_trades.opensignal{i},'breachdn-lvldn')
                if tbl_trades.trendflag(i) == 1
                    if tbl_trades.barrierfractal(i) <= tbl_trades.barriertdsq(i)
                        idx2 = strcmpi(struct_distributions.breachdnlvldn_tc.asset,tbl_trades.assetname{i});
                        kellyspecial(i) = struct_distributions.breachdnlvldn_tc.K(idx2);
                    else
                        if tbl_trades.opentype(i) == 2
                            idx2 = strcmpi(struct_distributions.smtc.asset,tbl_trades.assetname{i});
                            kellyspecial(i) = struct_distributions.smtc.K(idx2);
                        elseif tbl_trades.opentype(i) == 3
                            idx2 = strcmpi(struct_distributions.sstc.asset,tbl_trades.assetname{i});
                            kellyspecial(i) = struct_distributions.sstc.K(idx2);
                        end
                    end
                else
                    idx2 = strcmpi(struct_distributions.breachdnlvldn_tb.asset,tbl_trades.assetname{i});
                    kellyspecial(i) = struct_distributions.breachdnlvldn_tb.K(idx2);
                end
            elseif strcmpi(tbl_trades.opensignal{i},'breachdn-bshighvalue')
                if tbl_trades.trendflag(i) == 1
                    idx2 = strcmpi(struct_distributions.breachdnbshighvalue_tc.asset,tbl_trades.assetname{i});
                    kellyspecial(i) = struct_distributions.breachdnbshighvalue_tc.K(idx2);
                else
                    idx2 = strcmpi(struct_distributions.breachdnbshighvalue_tb.asset,tbl_trades.assetname{i});
                    kellyspecial(i) = struct_distributions.breachdnbshighvalue_tb.K(idx2);
                end
            elseif strcmpi(tbl_trades.opensignal{i},'mediumbreach-trendconfirmed') || ...
                    strcmpi(tbl_trades.opensignal{i},'strongbreach-trendconfirmed') || ...
                    strcmpi(tbl_trades.opensignal{i},'volblowup') || ...
                    strcmpi(tbl_trades.opensignal{i},'volblowup2')
                if tbl_trades.opentype(i) == 2
                    idx2 = strcmpi(struct_distributions.smtc.asset,tbl_trades.assetname{i});
                    kellyspecial(i) = struct_distributions.smtc.K(idx2);
                elseif tbl_trades.opentype(i) == 3
                    idx2 = strcmpi(struct_distributions.sstc.asset,tbl_trades.assetname{i});
                    kellyspecial(i) = struct_distributions.sstc.K(idx2);
                end
            else
                idx_row = strcmpi(struct_distributions.signal_s,tbl_trades.opensignal{i});
                idx_col = strcmpi(struct_distributions.asset_list,tbl_trades.assetname{i});
                temp = struct_distributions.kelly_matrix_s(idx_row,idx_col);
                if ~isempty(temp)
                    kellyspecial(i) = temp;
                end
            end
        end
        if ~isnan(kellyspecial(i))
            if kellyspecial(i) == -inf, kellyspecial(i) = -9.99;end
            kellyused(i) = kellyspecial(i);
            if kellyspecial(i) >= 0.1
                use2(i) = 1;
            else
                use2(i) = 0;
            end
        else
            kellyused(i) = kellygeneral(i);
            use2(i) = use1(i);
        end
        %
    end
    %
    %
    code = tbl_trades.code;
    assetname = tbl_trades.assetname;
    opentype = tbl_trades.opentype;
    opensignal = tbl_trades.opensignal;
    direction = tbl_trades.direction;
    openid = tbl_trades.openid;
    opendatetime = tbl_trades.opendatetime;
    openprice = tbl_trades.openprice;
    opennotional = tbl_trades.opennotional;
    pnlrel = tbl_trades.pnlrel;
    closestr = tbl_trades.closestr;
    trendflag = tbl_trades.trendflag;
    barrierfractal = tbl_trades.barrierfractal;
    barriertdsq = tbl_trades.barriertdsq;
    tbl_report = table(code,assetname,opentype,opensignal,direction,openid,opendatetime,openprice,opennotional,pnlrel,closestr,trendflag,barrierfractal,barriertdsq,yearinfo,monthinfo,weeknuminfo,kellygeneral,use1,kellyspecial,kellyused,use2);
    %
    %
    A = unique(tbl_report.assetname);
    nasset = length(A);
    N_LS = zeros(nasset,1);N_L = zeros(nasset,1);N_S = zeros(nasset,1);
    W_LS = zeros(nasset,1);W_L = zeros(nasset,1);W_S = zeros(nasset,1);
    R_LS = zeros(nasset,1);R_L = zeros(nasset,1);R_S = zeros(nasset,1);
    K_LS = zeros(nasset,1);K_L = zeros(nasset,1);K_S = zeros(nasset,1);
    
    for iasset = 1:length(A)
        idx_iasset = strcmpi(tbl_report.assetname,A{iasset}) & tbl_report.use2 == 1;
        tbl_iasset = tbl_report(idx_iasset,:);
        [w_,r_,k_] = calcrunningkelly(tbl_iasset.pnlrel);
        N_LS(iasset) = size(w_,1);
        W_LS(iasset) = w_(end);
        R_LS(iasset) = r_(end);
        K_LS(iasset) = k_(end);
        idx_iasset_l = tbl_iasset.direction == 1;
        idx_iasset_s = tbl_iasset.direction == -1;
        [w_,r_,k_] = calcrunningkelly(tbl_iasset.pnlrel(idx_iasset_l));
        N_L(iasset) = size(w_,1);
        W_L(iasset) = w_(end);
        R_L(iasset) = r_(end);
        K_L(iasset) = k_(end);
        [w_,r_,k_] = calcrunningkelly(tbl_iasset.pnlrel(idx_iasset_s));
        N_S(iasset) = size(w_,1);
        W_S(iasset) = w_(end);
        R_S(iasset) = r_(end);
        K_S(iasset) = k_(end);
    end
    tbl_byasset = table(A,N_LS,W_LS,R_LS,K_LS,N_L,W_L,R_L,K_L,N_S,W_S,R_S,K_S);
    
    years = unique(yearinfo);
    nyears = length(years);
    jan = zeros(nyears,1);
    feb = zeros(nyears,1);
    mar = zeros(nyears,1);
    apr = zeros(nyears,1);
    may = zeros(nyears,1);
    jun = zeros(nyears,1);
    jul = zeros(nyears,1);
    aug = zeros(nyears,1);
    sep = zeros(nyears,1);
    oct = zeros(nyears,1);
    nov = zeros(nyears,1);
    dec = zeros(nyears,1);
    
    for k = 1:length(struct_distributions.asset_list)
        if strcmpi(struct_distributions.asset_list{k},'all')
            tbl2check = tbl_report;
        else
            idx_asset = strcmpi(assetname,struct_distributions.asset_list{k});
            tbl2check = tbl_report(idx_asset,:);
        end
        for i = 1:nyears
            idx_jan = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 1 & tbl2check.use2 == 1;
            idx_feb = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 2 & tbl2check.use2 == 1;
            idx_mar = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 3 & tbl2check.use2 == 1;
            idx_apr = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 4 & tbl2check.use2 == 1;
            idx_may = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 5 & tbl2check.use2 == 1;
            idx_jun = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 6 & tbl2check.use2 == 1;
            idx_jul = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 7 & tbl2check.use2 == 1;
            idx_aug = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 8 & tbl2check.use2 == 1;
            idx_sep = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 9 & tbl2check.use2 == 1;
            idx_oct = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 10 & tbl2check.use2 == 1;
            idx_nov = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 11 & tbl2check.use2 == 1;
            idx_dec = tbl2check.yearinfo == years(i) & tbl2check.monthinfo == 12 & tbl2check.use2 == 1;
            jan(i) = sum(tbl2check.pnlrel(idx_jan));
            feb(i) = sum(tbl2check.pnlrel(idx_feb));
            mar(i) = sum(tbl2check.pnlrel(idx_mar));
            apr(i) = sum(tbl2check.pnlrel(idx_apr));
            may(i) = sum(tbl2check.pnlrel(idx_may));
            jun(i) = sum(tbl2check.pnlrel(idx_jun));
            jul(i) = sum(tbl2check.pnlrel(idx_jul));
            aug(i) = sum(tbl2check.pnlrel(idx_aug));
            sep(i) = sum(tbl2check.pnlrel(idx_sep));
            oct(i) = sum(tbl2check.pnlrel(idx_oct));
            nov(i) = sum(tbl2check.pnlrel(idx_nov));
            dec(i) = sum(tbl2check.pnlrel(idx_dec));
        end
        name1 = struct_distributions.asset_list{k};
        name2 = name1(~isspace(name1));
        if strcmpi(name2,'上证50')
            name2 = 'sz50';
        elseif strcmpi(name2,'上证指数')
            name2 = 'shcomp';
        elseif strcmpi(name2,'中证1000')
            name2 = 'zz1000';
        elseif strcmpi(name2,'中证500')
            name2 = 'zz500';
        elseif strcmpi(name2,'创业板指')
            name2 = 'cybz';
        elseif strcmpi(name2,'沪深300')
            name2 = 'hs300';
        elseif strcmpi(name2,'科创50')
            name2 = 'kc50';
        elseif strcmpi(name2,'红利指数')
            name2 = 'hlzs';
        end
        stats_report.(name2) = table(jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec);
    end
end
