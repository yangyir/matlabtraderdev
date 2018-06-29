%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = false;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end

%%
%base metals
% bm_codes_ctp = {'cu1709';'cu1710';'cu1711';'cu1712';'cu1801';'cu1802';'cu1803';...
%     'al1709';'al1710';'al1711';'al1712';'al1801';'al1802';'al1803';...
%     'zn1709';'zn1710';'zn1711';'zn1712';'zn1801';'zn1802';'zn1803';...
%     'pb1709';'pb1710';'pb1711';'pb1712';'pb1801';'pb1802';'pb1803';...
%     'ni1709';'ni1801';'ni1805'};

bm_codes_ctp = {'cu1801';'cu1802';'cu1803';'cu1804';'cu1805';'cu1806';'cu1807';'cu1808';'cu1809';'cu1810';'cu1811';'cu1812'};

for i = 1:size(bm_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,bm_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for base metal futures......\n');

%%
% govtbond futures
% govtbond_codes_ctp = {'TF1703';'TF1706';'TF1709';'TF1712';'TF1803';...
%     'T1703';'T1706';'T1709';'T1712';'T1803'};
govtbond_codes_ctp = {'TF1712';'TF1803';'TF1806';'TF1809';...
    'T1712';'T1803';'T1806';'T1809'};

for i = 1:size(govtbond_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,govtbond_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for govt bond futures......\n');

%%
%precious metals
pm_codes_ctp = {'au1712';'au1806';'ag1712';'ag1806'};

for i = 1:size(pm_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,pm_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for precious metal futures\n');

%%
%rebal
rb_codes_ctp = {'rb1810'};

for i = 1:size(rb_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,rb_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for rb futures\n');
%%
%clear variables
clear i
clear override conn bm_codes_ctp govtbond_codes_ctp pm_codes_ctp

