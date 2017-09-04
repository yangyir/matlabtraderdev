
%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = false;
bbg = cBloomberg;

%%
%base metals

bm_codes_ctp = {'cu1709';'cu1710';'cu1711';'cu1712';'cu1801';'cu1802';'cu1803';...
    'al1709';'al1710';'al1711';'al1712';'al1801';'al1802';'al1803';...
    'zn1709';'zn1710';'zn1711';'zn1712';'zn1801';'zn1802';'zn1803';...
    'pb1709';'pb1710';'pb1711';'pb1712';'pb1801';'pb1802';'pb1803';...
    'ni1709';'ni1801';'ni1805'};

for i = 1:size(bm_codes_ctp,1)
    saveintradaybarfrombloomberg(bbg,bm_codes_ctp{i},override);
end

%%
% govtbond futures
govtbond_codes_ctp = {'TF1703';'TF1706';'TF1709';'TF1712';'TF1803';...
    'T1703';'T1706';'T1709';'T1712';'T1803'};

for i = 1:size(govtbond_codes_ctp,1)
    saveintradaybarfrombloomberg(bbg,govtbond_codes_ctp{i},override);
end


