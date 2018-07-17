%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = false;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end

%%
%base metals
bm_codes_ctp = {'cu1808';'cu1809';'cu1810';'cu1811';'cu1812';...
    'al1808';'al1809';'al1810';'al1811';'al1812';...
    'zn1808';'zn1809';'zn1810';'zn1811';'zn1812';...
    'pb1808';'pb1809';'pb1810';'pb1811';'pb1812';...
    'ni1809';'ni1811';'ni1901'};

for i = 1:size(bm_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,bm_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for base metal futures......\n');

%%
% govtbond futures
govtbond_codes_ctp = {'TF1809';'TF1812';...
    'T1809';'T1812'};

for i = 1:size(govtbond_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,govtbond_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for govt bond futures......\n');

%%
%precious metals
pm_codes_ctp = {'au1812';'ag1812'};

for i = 1:size(pm_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,pm_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for precious metal futures\n');

%%
%rebal
rb_codes_ctp = {'rb1810';'rb1901'};

for i = 1:size(rb_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,rb_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for rb futures\n');

%%
%iron ore
ironore_codes_ctp = {'i1809';'i1901'};

for i = 1:size(ironore_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,ironore_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for iron ore futures\n');

%%
%clear variables
clear i
clear override conn bm_codes_ctp govtbond_codes_ctp pm_codes_ctp

