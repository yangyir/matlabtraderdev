function output = charlotte_strat_compare(varargin)
p = inputParser;
p.CaseSensitive = false;
p.KeepUnmatched = true;
p.addParameter('existing',{},@isstruct);
p.addParameter('updated',{},@isstruct);
p.addParameter('assetname','',@ischar);
p.parse(varargin{:});
strat1 = p.Results.existing;
strat2 = p.Results.updated;
assetname = p.Results.assetname;
%

%
%the following compares special signal
% ----------------------------LONG-----------------------------------
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
%
% --------------------------------SHORT-----------------------------------
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