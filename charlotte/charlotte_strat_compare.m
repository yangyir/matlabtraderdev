function output = charlotte_strat_compare(varargin)
p = inputParser;
p.CaseSensitive = false;
p.KeepUnmatched = true;
p.addParameter('strat1',{},@isstruct);
p.addParameter('strat2',{},@isstruct);
p.addParameter('assetname','',@ischar);
p.parse(varargin{:});
strat1 = p.Results.strat1;
strat2 = p.Results.strat2;
assetname = p.Results.assetname;
%
%LONG
ns1 = length(strat1.signal_l);
ns2 = length(strat2.signal_l);
%report signal(s) which is(are) removed in the latest strat table
for i = 1:ns1
    if ~sum(strcmpi(strat1.signal_l{i},strat2.signal_l))
        j1 = strcmpi(strat1.kelly_table_l.opensignal_unique_l,strat1.signal_l{i});
        n1 = strat1.kelly_table_l.ntrades_unique_l(j1);
        w1 = strat1.kelly_table_l.winp_unique_l_sample(j1);
        r1 = strat1.kelly_table_l.r_unique_l_sample(j1);
        k1 = strat1.kelly_table_l.kelly_unique_l_sample(j1);
        j2 = strcmpi(strat2.kelly_table_l.opensignal_unique_l,strat1.signal_l{i});
        n2 = strat2.kelly_table_l.ntrades_unique_l(j2);
        w2 = strat2.kelly_table_l.winp_unique_l_sample(j2);
        r2 = strat2.kelly_table_l.r_unique_l_sample(j2);
        k2 = strat2.kelly_table_l.kelly_unique_l_sample(j2);
        
        fprintf('%22s:\t%35s\n','long signal removed',strat1.signal_l{i});
        fprintf('\tn:%7s\t%7s\n',num2str(n1),num2str(n2));
        fprintf('\tw:%6.1f%%\t%6.1f%%\n',100*w1,100*w2);
        fprintf('\tr:%6.1f\t%6.1f\n',r1,r2);
        charlotte_print_kelly(k1,k2);
    end
end
%report signal(s) which is(are) added in the latest strat table
for i = 1:ns2
    if ~sum(strcmpi(strat2.signal_l{i},strat1.signal_l))
        j1 = strcmpi(strat1.kelly_table_l.opensignal_unique_l,strat2.signal_l{i});
        n1 = strat1.kelly_table_l.ntrades_unique_l(j1);
        w1 = strat1.kelly_table_l.winp_unique_l_sample(j1);
        r1 = strat1.kelly_table_l.r_unique_l_sample(j1);
        k1 = strat1.kelly_table_l.kelly_unique_l_sample(j1);
        j2 = strcmpi(strat2.kelly_table_l.opensignal_unique_l,strat2.signal_l{i});
        n2 = strat2.kelly_table_l.ntrades_unique_l(j2);
        w2 = strat2.kelly_table_l.winp_unique_l_sample(j2);
        r2 = strat2.kelly_table_l.r_unique_l_sample(j2);
        k2 = strat2.kelly_table_l.kelly_unique_l_sample(j2);
        
        fprintf('%22s:\t%35s\n','long signal added',strat2.signal_l{i});
        fprintf('\tn:%7s\t%7s\n',num2str(n1),num2str(n2));
        fprintf('\tw:%6.1f%%\t%6.1f%%\n',100*w1,100*w2);
        fprintf('\tr:%6.1f\t%6.1f\n',r1,r2);
        charlotte_print_kelly(k1,k2);
    end
    
end
%report signal(s) which is(are) listed in both strat table
colidx1 = strcmpi(strat1.asset_list,assetname);
colidx2 = strcmpi(strat2.asset_list,assetname);
for i = 1:ns2
    rowidx1 = strcmpi(strat2.signal_l{i},strat1.signal_l);
    if ~sum(rowidx1)
        continue;
    end
    k1 = strat1.kelly_matrix_l(rowidx1,colidx1);
    k2 = strat2.kelly_matrix_l(i,colidx2);
    fprintf('%22s:\t%35s\t:','long signal existing',strat2.signal_l{i});
    charlotte_print_kelly(k1,k2);
end
%
fprintf('\n');
%
%SHORT
ns1 = length(strat1.signal_s);
ns2 = length(strat2.signal_s);
%report signal(s) which is(are) removed in the latest strat table
for i = 1:ns1
    if ~sum(strcmpi(strat1.signal_s{i},strat2.signal_s))
        j1 = strcmpi(strat1.kelly_table_s.opensignal_unique_s,strat1.signal_s{i});
        n1 = strat1.kelly_table_s.ntrades_unique_s(j1);
        w1 = strat1.kelly_table_s.winp_unique_s_sample(j1);
        r1 = strat1.kelly_table_s.r_unique_s_sample(j1);
        k1 = strat1.kelly_table_s.kelly_unique_s_sample(j1);
        j2 = strcmpi(strat2.kelly_table_s.opensignal_unique_s,strat1.signal_s{i});
        n2 = strat2.kelly_table_s.ntrades_unique_s(j2);
        w2 = strat2.kelly_table_s.winp_unique_s_sample(j2);
        r2 = strat2.kelly_table_s.r_unique_s_sample(j2);
        k2 = strat2.kelly_table_s.kelly_unique_s_sample(j2);
        
        fprintf('%22s:\t%35s\n','short signal removed',strat1.signal_s{i});
        fprintf('\tn:%7s\t%7s\n',num2str(n1),num2str(n2));
        fprintf('\tw:%6.1f%%\t%6.1f%%\n',100*w1,100*w2);
        fprintf('\tr:%6.1f\t%6.1f\n',r1,r2);
        charlotte_print_kelly(k1,k2);
    end
end
%report signal(s) which is(are) added in the latest strat table
for i = 1:ns2
    if ~sum(strcmpi(strat2.signal_s{i},strat1.signal_s))
        j1 = strcmpi(strat1.kelly_table_s.opensignal_unique_s,strat2.signal_s{i});
        n1 = strat1.kelly_table_s.ntrades_unique_s(j1);
        w1 = strat1.kelly_table_s.winp_unique_s_sample(j1);
        r1 = strat1.kelly_table_s.r_unique_s_sample(j1);
        k1 = strat1.kelly_table_s.kelly_unique_s_sample(j1);
        j2 = strcmpi(strat2.kelly_table_s.opensignal_unique_s,strat2.signal_s{i});
        n2 = strat2.kelly_table_s.ntrades_unique_s(j2);
        w2 = strat2.kelly_table_s.winp_unique_s_sample(j2);
        r2 = strat2.kelly_table_s.r_unique_s_sample(j2);
        k2 = strat2.kelly_table_s.kelly_unique_s_sample(j2);
        
        fprintf('%22s:\t%35s\n','short signal added',strat2.signal_s{i});
        fprintf('\tn:%7s\t%7s\n',num2str(n1),num2str(n2));
        fprintf('\tw:%6.1f%%\t%6.1f%%\n',100*w1,100*w2);
        fprintf('\tr:%6.1f\t%6.1f\n',r1,r2);
        charlotte_print_kelly(k1,k2);
    end
end
%
%report signal(s) which is(are) listed in both strat table
colidx1 = strcmpi(strat1.asset_list,assetname);
colidx2 = strcmpi(strat2.asset_list,assetname);
for i = 1:ns2
    rowidx1 = strcmpi(strat2.signal_s{i},strat1.signal_s);
    if ~sum(rowidx1)
        continue;
    end
    k1 = strat1.kelly_matrix_s(rowidx1,colidx1);
    k2 = strat2.kelly_matrix_s(i,colidx2);
    fprintf('%22s:\t%35s\t:','short signal existing',strat2.signal_s{i});
    charlotte_print_kelly(k1,k2);
end
%
%the following compares special signal
fprintf('\n');
%bmtc
idx1 = strcmpi(strat1.bmtc.asset,assetname);
idx2 = strcmpi(strat2.bmtc.asset,assetname);
k1 = strat1.bmtc.K(idx1);
k2 = strat2.bmtc.K(idx2);
fprintf('%22s:\t%35s\t:','long signal special','bmtc');
charlotte_print_kelly(k1,k2);
%bstc
idx1 = strcmpi(strat1.bstc.asset,assetname);
idx2 = strcmpi(strat2.bstc.asset,assetname);
k1 = strat1.bstc.K(idx1);
k2 = strat2.bstc.K(idx2);
fprintf('%22s:\t%35s\t:','long signal special','bstc');
charlotte_print_kelly(k1,k2);
%breachuplvlup_tb
idx1 = strcmpi(strat1.breachuplvlup_tb.asset,assetname);
idx2 = strcmpi(strat2.breachuplvlup_tb.asset,assetname);
k1 = strat1.breachuplvlup_tb.K(idx1);
k2 = strat2.breachuplvlup_tb.K(idx2);
fprintf('%22s:\t%35s\t:','long signal special','breachuplvlup_tb');
charlotte_print_kelly(k1,k2);
%breachupsshighvalue_tb
idx1 = strcmpi(strat1.breachupsshighvalue_tb.asset,assetname);
idx2 = strcmpi(strat2.breachupsshighvalue_tb.asset,assetname);
k1 = strat1.breachupsshighvalue_tb.K(idx1);
k2 = strat2.breachupsshighvalue_tb.K(idx2);
fprintf('%22s:\t%35s\t:','long signal special','breachupsshighvalue_tb');
charlotte_print_kelly(k1,k2);
%breachuplvlup_tc
idx1 = strcmpi(strat1.breachuplvlup_tc.asset,assetname);
idx2 = strcmpi(strat2.breachuplvlup_tc.asset,assetname);
k1 = strat1.breachuplvlup_tc.K(idx1);
k2 = strat2.breachuplvlup_tc.K(idx2);
fprintf('%22s:\t%35s\t:','long signal special','breachuplvlup_tc');
charlotte_print_kelly(k1,k2);
%breachupsshighvalue_tc
idx1 = strcmpi(strat1.breachupsshighvalue_tc.asset,assetname);
idx2 = strcmpi(strat2.breachupsshighvalue_tc.asset,assetname);
k1 = strat1.breachupsshighvalue_tc.K(idx1);
k2 = strat2.breachupsshighvalue_tc.K(idx2);
fprintf('%22s:\t%35s\t:','long signal special','breachupsshighvalue_tc');
charlotte_print_kelly(k1,k2);
%breachuphighsc13
idx1 = strcmpi(strat1.breachuphighsc13.asset,assetname);
idx2 = strcmpi(strat2.breachuphighsc13.asset,assetname);
k1 = strat1.breachuphighsc13.K(idx1);
k2 = strat2.breachuphighsc13.K(idx2);
fprintf('%22s:\t%35s\t:','long signal special','breachuphighsc13');
charlotte_print_kelly(k1,k2);
fprintf('\n');
%smtc
idx1 = strcmpi(strat1.smtc.asset,assetname);
idx2 = strcmpi(strat2.smtc.asset,assetname);
k1 = strat1.smtc.K(idx1);
k2 = strat2.smtc.K(idx2);
fprintf('%22s:\t%35s\t:','short signal special','smtc');
charlotte_print_kelly(k1,k2);
%sstc
idx1 = strcmpi(strat1.sstc.asset,assetname);
idx2 = strcmpi(strat2.sstc.asset,assetname);
k1 = strat1.sstc.K(idx1);
k2 = strat2.sstc.K(idx2);
fprintf('%22s:\t%35s\t:','short signal special','sstc');
charlotte_print_kelly(k1,k2);
%breachdnlvldn_tb
idx1 = strcmpi(strat1.breachdnlvldn_tb.asset,assetname);
idx2 = strcmpi(strat2.breachdnlvldn_tb.asset,assetname);
k1 = strat1.breachdnlvldn_tb.K(idx1);
k2 = strat2.breachdnlvldn_tb.K(idx2);
fprintf('%22s:\t%35s\t:','short signal special','breachdnlvldn_tb');
charlotte_print_kelly(k1,k2);
%breachdnbshighivalue_tb
idx1 = strcmpi(strat1.breachdnbshighvalue_tb.asset,assetname);
idx2 = strcmpi(strat2.breachdnbshighvalue_tb.asset,assetname);
k1 = strat1.breachdnbshighvalue_tb.K(idx1);
k2 = strat2.breachdnbshighvalue_tb.K(idx2);
fprintf('%22s:\t%35s\t:','short signal special','breachdnbshighvalue_tb');
charlotte_print_kelly(k1,k2);
%breachdnlvldn_tc
idx1 = strcmpi(strat1.breachdnlvldn_tc.asset,assetname);
idx2 = strcmpi(strat2.breachdnlvldn_tc.asset,assetname);
k1 = strat1.breachdnlvldn_tc.K(idx1);
k2 = strat2.breachdnlvldn_tc.K(idx2);
fprintf('%22s:\t%35s\t:','short signal special','breachdnlvldn_tc');
charlotte_print_kelly(k1,k2);
%breachdnbshighivalue_tb
idx1 = strcmpi(strat1.breachdnbshighvalue_tc.asset,assetname);
idx2 = strcmpi(strat2.breachdnbshighvalue_tc.asset,assetname);
k1 = strat1.breachdnbshighvalue_tc.K(idx1);
k2 = strat2.breachdnbshighvalue_tc.K(idx2);
fprintf('%22s:\t%35s\t:','short signal special','breachdnbshighvalue_tc');
charlotte_print_kelly(k1,k2);
%breachdnlowbc13
idx1 = strcmpi(strat1.breachdnlowbc13.asset,assetname);
idx2 = strcmpi(strat2.breachdnlowbc13.asset,assetname);
k1 = strat1.breachdnlowbc13.K(idx1);
k2 = strat2.breachdnlowbc13.K(idx2);
fprintf('%22s:\t%35s\t:','short signal special','breachdnlowbc13');
charlotte_print_kelly(k1,k2);
%
%
%





end