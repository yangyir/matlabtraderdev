function [tblout,kellyout,tblout_notused,strat_] = charlotte_kellycheck(varargin)
%
p = inputParser;
p.KeepUnmatched = true;p.CaseSensitive = false;
p.addParameter('assetname','',@ischar);
p.addParameter('datefrom','',@ischar);
p.addParameter('dateto','',@ischar);
p.addParameter('frequency','30m',@ischar);
p.addParameter('reportunused',false,@islogical);
p.parse(varargin{:});
%
assetname = p.Results.assetname;
dtfrom = p.Results.datefrom;
dtto = p.Results.dateto;
freq = p.Results.frequency;
if ~(strcmpi(freq,'30m') || strcmpi(freq,'1440m') || strcmpi(freq,'5m') || strcmpi(freq,'15m') || strcmpi(freq,'daily')) 
    error('charlotte_kellycheck:invalid frequency input, either be 5m,15m,30m or daily')
end
reportunused = p.Results.reportunused;

if strcmpi(assetname,'govtbond_10y') || strcmpi(assetname,'govtbond_30y') || strcmpi(assetname,'govtbond_05y')
    if strcmpi(freq,'5m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_5m.mat']);
        strat_ = data.strat_govtbondfut_5m;
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\tblreport_govtbondfut_5m.mat']);
        tbl_report_ = data.tblreport_govtbondfut_5m;
    elseif strcmpi(freq,'15m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_15m.mat']);
        strat_ = data.strat_govtbondfut_15m;
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\tblreport_govtbondfut_15m.mat']);
        tbl_report_ = data.tblreport_govtbondfut_15m;
    elseif strcmpi(freq,'30m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_30m.mat']);
        strat_ = data.strat_govtbondfut_30m;
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\tblreport_govtbondfut_30m.mat']);
        tbl_report_ = data.tblreport_govtbondfut_30m;
    end
elseif strcmpi(assetname,'eqindex_300') || strcmpi(assetname,'eqindex_50') || ...
        strcmpi(assetname,'eqindex_500') || strcmpi(assetname,'eqindex_1000')
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\strat_eqindexfut.mat']);
    strat_ = data.strat_eqindexfut;
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\tblreport_eqindexfut.mat']);
    tbl_report_ = data.tblreport_eqindexfut;
else
    if strcmpi(freq,'30m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\strat_comdty_i.mat']);
        strat_ = data.strat_comdty_i;
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\tbl_report_comdty_i.mat']);
        tbl_report_ = data.tbl_report_comdty_i;
    elseif strcmpi(freq,'1440m') || strcmpi(freq,'daily')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\strat_comdty_daily.mat']);
        strat_ = data.strat_comdty_daily;
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\tbl_report_comdty_daily.mat']);
        tbl_report_ = data.tbl_report_comdty_daily;
    end
end

fprintf('%s:\n',assetname);
idx = strcmpi(strat_.tblbyasset_l.assetlist,assetname);
kelly_ = strat_.tblbyasset_l.K_L(idx);
N_ = strat_.tblbyasset_l.N_L(idx);
fprintf('\t%22s:%5.1f%%\t%5d\n','long position',kelly_*100,N_);
kellyout.long_all = kelly_;
kellyout.long_all_count = N_;
%
idx = strcmpi(strat_.breachuplvlup_tc.asset,assetname);
kelly_ = strat_.breachuplvlup_tc.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachuplvlup_tc',kelly_*100);
kellyout.breachuplvlup_tc = kelly_;
%
idx = strcmpi(strat_.breachuplvlup_tc_all.asset,assetname);
kelly_ = strat_.breachuplvlup_tc_all.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachuplvlup_tc_all',kelly_*100);
kellyout.breachuplvlup_tc_all = kelly_;
%
idx = strcmpi(strat_.breachuplvlup_tb.asset,assetname);
kelly_ = strat_.breachuplvlup_tb.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachuplvlup_tb',kelly_*100);
kellyout.breachuplvlup_tb = kelly_;
%
idx = strcmpi(strat_.breachupsshighvalue_tc.asset,assetname);
kelly_ = strat_.breachupsshighvalue_tc.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachupsshighvalue_tc',kelly_*100);
kellyout.breachupsshighvalue_tc = kelly_;
%
idx = strcmpi(strat_.breachupsshighvalue_tb.asset,assetname);
kelly_ = strat_.breachupsshighvalue_tb.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachupsshighvalue_tb',kelly_*100);
kellyout.breachupsshighvalue_tb = kelly_;
%
idx = strcmpi(strat_.breachuphighsc13.asset,assetname);
kelly_ = strat_.breachuphighsc13.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachuphighsc13',kelly_*100);
kellyout.breachuphighsc13 = kelly_;
%
idx = strcmpi(strat_.bmtc.asset,assetname);
kelly_ = strat_.bmtc.K(idx);
fprintf('\t%22s:%5.1f%%\n','bmtc',kelly_*100);
kellyout.bmtc = kelly_;
%
idx = strcmpi(strat_.bstc.asset,assetname);
kelly_ = strat_.bstc.K(idx);
fprintf('\t%22s:%5.1f%%\n','bstc',kelly_*100);
kellyout.bstc = kelly_;
%
idx = strcmpi(tbl_report_.assetname,assetname) & tbl_report_.direction == 1 & ...
    strcmpi(tbl_report_.opensignal,'mediumbreach-trendconfirmed');
pnl2check = tbl_report_.pnlrel(idx);
if isempty(pnl2check)
    kelly_ = [];
else
    [~,~,krunning] = calcrunningkelly(pnl2check);
    kelly_ = krunning(end);
end
fprintf('\t%22s:%5.1f%%\n','bmtc_only',kelly_*100);
kellyout.bmtc_only = kelly_;

idx = strcmpi(tbl_report_.assetname,assetname) & tbl_report_.direction == 1 & ...
    strcmpi(tbl_report_.opensignal,'strongbreach-trendconfirmed');
pnl2check = tbl_report_.pnlrel(idx);
if isempty(pnl2check)
    kelly_ = [];
else
    [~,~,krunning] = calcrunningkelly(pnl2check);
    kelly_ = krunning(end);
end
fprintf('\t%22s:%5.1f%%\n','bstc_only',kelly_*100);
kellyout.bstc_only = kelly_;
try
    kelly_ = kelly_k('volblowup',assetname,strat_.signal_l,strat_.asset_list,strat_.kelly_matrix_l);
catch
    kelly_ = -9.99;
end
fprintf('\t%22s:%5.1f%%\n','b_volblowup',kelly_*100);
kellyout.b_volblowup = kelly_;
fprintf('\n');
%
idx = strcmpi(strat_.tblbyasset_s.assetlist,assetname);
kelly_ = strat_.tblbyasset_s.K_S(idx);
N_ = strat_.tblbyasset_s.N_S(idx);
fprintf('\t%22s:%5.1f%%\t%5d\n','short position',kelly_*100,N_);
kellyout.short_all = kelly_;
kellyout.short_all_count = N_;
%
idx = strcmpi(strat_.breachdnlvldn_tc.asset,assetname);
kelly_ = strat_.breachdnlvldn_tc.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachdnlvldn_tc',kelly_*100);
kellyout.breachdnlvldn_tc = kelly_;
%
idx = strcmpi(strat_.breachdnlvldn_tc_all.asset,assetname);
kelly_ = strat_.breachdnlvldn_tc_all.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachdnlvldn_tc_all',kelly_*100);
kellyout.breachdnlvldn_tc_all = kelly_;
%
idx = strcmpi(strat_.breachdnlvldn_tb.asset,assetname);
kelly_ = strat_.breachdnlvldn_tb.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachdnlvldn_tb',kelly_*100);
kellyout.breachdnlvldn_tb = kelly_;
%
idx = strcmpi(strat_.breachdnbshighvalue_tc.asset,assetname);
kelly_ = strat_.breachdnbshighvalue_tc.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachdnbshighvalue_tc',kelly_*100);
kellyout.breachdnbshighvalue_tc = kelly_;
%
idx = strcmpi(strat_.breachdnbshighvalue_tb.asset,assetname);
kelly_ = strat_.breachdnbshighvalue_tb.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachdnbshighvalue_tb',kelly_*100);
kellyout.breachdnbshighvalue_tb = kelly_;
%
idx = strcmpi(strat_.breachdnlowbc13.asset,assetname);
kelly_ = strat_.breachdnlowbc13.K(idx);
fprintf('\t%22s:%5.1f%%\n','breachdnlowbc13',kelly_*100);
kellyout.breachdnlowbc13 = kelly_;
%
idx = strcmpi(strat_.smtc.asset,assetname);
kelly_ = strat_.smtc.K(idx);
fprintf('\t%22s:%5.1f%%\n','smtc',kelly_*100);
kellyout.smtc = kelly_;
%
idx = strcmpi(strat_.sstc.asset,assetname);
kelly_ = strat_.sstc.K(idx);
fprintf('\t%22s:%5.1f%%\n','sstc',kelly_*100);
kellyout.sstc = kelly_;
%
idx = strcmpi(tbl_report_.assetname,assetname) & tbl_report_.direction == -1 & ...
    strcmpi(tbl_report_.opensignal,'mediumbreach-trendconfirmed');
pnl2check = tbl_report_.pnlrel(idx);
if isempty(pnl2check)
    kelly_ = [];
else
    [~,~,krunning] = calcrunningkelly(pnl2check);
    kelly_ = krunning(end);
end
fprintf('\t%22s:%5.1f%%\n','smtc_only',kelly_*100);
kellyout.smtc_only = kelly_;
%
idx = strcmpi(tbl_report_.assetname,assetname) & tbl_report_.direction == -1 & ...
    strcmpi(tbl_report_.opensignal,'strongbreach-trendconfirmed');
pnl2check = tbl_report_.pnlrel(idx);
if isempty(pnl2check)
    kelly_ = [];
else
    [~,~,krunning] = calcrunningkelly(pnl2check);
    kelly_ = krunning(end);
end
fprintf('\t%22s:%5.1f%%\n','sstc_only',kelly_*100);
kellyout.sstc_only = kelly_;
try
    kelly_ = kelly_k('volblowup',assetname,strat_.signal_s,strat_.asset_list,strat_.kelly_matrix_s);
catch
    kelly_ = -9.99;
end
fprintf('\t%22s:%5.1f%%\n','s_volblowup',kelly_*100);
kellyout.s_volblowup = kelly_;

fprintf('\n');

if isempty(dtfrom) && isempty(dtto)
    idx = strcmpi(tbl_report_.assetname,assetname);
elseif isempty(dtfrom) && ~isempty(dtto)
    dttonum = datenum(dtto);
    idx = strcmpi(tbl_report_.assetname,assetname) & tbl_report_.opendatetime <= dttonum; 
elseif ~isempty(dtfrom) && isempty(dtto)
    dtfromnum = datenum(dtfrom);
    idx = strcmpi(tbl_report_.assetname,assetname) & tbl_report_.opendatetime >= dtfromnum;
elseif ~isempty(dtfrom) && ~isempty(dtto)
    dtfromnum = datenum(dtfrom);
    dttonum = datenum(dtto);
    idx = strcmpi(tbl_report_.assetname,assetname) & tbl_report_.opendatetime >= dtfromnum & tbl_report_.opendatetime <= dttonum;
end

if reportunused
    idxunused = idx & tbl_report_.use2 == 0;
    tblout_notused = tbl_report_(idxunused,:);
    tblout_notused.opendatetime = datestr(tblout_notused.opendatetime,'yyyy-mm-dd HH:MM');
    tblout_notused.closedatetime = datestr(tblout_notused.closedatetime,'yyyy-mm-dd HH:MM');
else
    tblout_notused = [];
end

idx = idx & tbl_report_.use2 == 1;

tblout = tbl_report_(idx,:);
tblout.opendatetime = datestr(tblout.opendatetime,'yyyy-mm-dd HH:MM');
tblout.closedatetime = datestr(tblout.closedatetime,'yyyy-mm-dd HH:MM');

end

