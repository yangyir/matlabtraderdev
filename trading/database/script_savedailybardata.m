%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = true;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end

%%
%base metals
bm_codes_ctp = {'cu1709';'cu1710';'cu1711';'cu1712';'cu1801';'cu1802';'cu1803';...
    'al1709';'al1710';'al1711';'al1712';'al1801';'al1802';'al1803';...
    'zn1709';'zn1710';'zn1711';'zn1712';'zn1801';'zn1802';'zn1803';...
    'pb1709';'pb1710';'pb1711';'pb1712';'pb1801';'pb1802';'pb1803';...
    'ni1709';'ni1801';'ni1805'};

for i = 1:size(bm_codes_ctp,1)
    savedailybarfrombloomberg(conn,bm_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for base metal futures......\n');

%%
% govtbond futures
govtbond_codes_ctp = {'TF1703';'TF1706';'TF1709';'TF1712';'TF1803';...
    'T1703';'T1706';'T1709';'T1712';'T1803'};

for i = 1:size(govtbond_codes_ctp,1)
    savedailybarfrombloomberg(conn,govtbond_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for govt bond futures......\n');

%%
% precious metals
pm_codes_ctp = {'au1712';'au1806';'ag1712';'ag1806'};

for i = 1:size(pm_codes_ctp,1)
    savedailybarfrombloomberg(conn,pm_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for precious metal futures\n');

%%
% agriculture for options
ag_codes_ctp = {'m1801';'m1805';'SR801';'SR805'};
for i = 1:size(ag_codes_ctp,1)
    savedailybarfrombloomberg(conn,ag_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for agriculture futures\n');

%%
% options
opt_codes_ctp = {'m1801-C-2600';'m1801-P-2600';...
    'm1801-C-2650';'m1801-P-2650';...
    'm1801-C-2700';'m1801-P-2700';...
    'm1801-C-2750';'m1801-P-2750';...
    'm1801-C-2800';'m1801-P-2800'};
for i = 1:size(opt_codes_ctp,1)
    savedailybarfrombloomberg(conn,opt_codes_ctp{i},override);
end
fprintf('done for saving daily bar data for listed commodity options\n');




