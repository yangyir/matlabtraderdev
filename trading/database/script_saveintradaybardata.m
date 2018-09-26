%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = false;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end

%%
%base metals
bm_codes_ctp = {'cu1810';'cu1811';'cu1812';'cu1901';'cu1902';'cu1903';...
    'al1810';'al1811';'al1812';'al1901';'al1902';'al1903';...
    'zn1810';'zn1811';'zn1812';'zn1901';'zn1902';'zn1903';...
    'pb1810';'pb1811';'pb1812';'pb1901';'pb1902';'pb1903';...
    'ni1811';'ni1901'};

for i = 1:size(bm_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,bm_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for base metal futures......\n');

%%
% govtbond futures
govtbond_codes_ctp = {'TF1812';'TF1903';...
    'T1812';'T1903'};

for i = 1:size(govtbond_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,govtbond_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for govt bond futures......\n');

%%
% equity index futures
eqindex_codes_ctp = {'IF1809';'IF1810';'IF1811';'IF1812';...
    'IH1809';'IH1810';'IH1811';'IH1812';...
    'IC1809';'IC1810';'IC1811';'IC1812'};

for i = 1:size(eqindex_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,eqindex_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for equity index futures......\n');

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
ironore_codes_ctp = {'i1809';'i1901';'i1905'};

for i = 1:size(ironore_codes_ctp,1)
    saveintradaybarfrombloomberg(conn,ironore_codes_ctp{i},override);
end
fprintf('done for saving intraday bar data for iron ore futures\n');

%%
%clear variables
clear i
clear override conn bm_codes_ctp govtbond_codes_ctp pm_codes_ctp

