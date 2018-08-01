%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
conn = cBloomberg;
%%
dir_ = [getenv('DATAPATH'),'info_futures\'];
try
    cd(dir_);
catch
    mkdir(dir_);
end

%%
%base metals
bm_codes_ctp = {'cu1808';'cu1809';'cu1810';'cu1811';'cu1812';'cu1901';...
    'al1808';'al1809';'al1810';'al1811';'al1812';'al1901';...
    'zn1808';'zn1809';'zn1810';'zn1811';'zn1812';'zn1901';...
    'pb1808';'pb1809';'pb1810';'pb1811';'pb1812';'pb1901';...
    'ni1809';'ni1811';'ni1901'};

for i = 1:size(bm_codes_ctp,1)
    f = cFutures(bm_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,bm_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for base metal futures......\n');

%%
% govtbond futures
govtbond_codes_ctp = {'TF1809';'TF1812';'TF1903';...
    'T1809';'T1812';'T1903'};

for i = 1:size(govtbond_codes_ctp,1)
    f = cFutures(govtbond_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,govtbond_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for govt bond futures......\n');

%%
% equity index
eqindex_codes_ctp = {'IF1808';'IF1809';'IF1812';...
    'IH1808';'IH1809';'IH1812';...
    'IC1808';'IC1809';'IC1812'};
for i = 1:size(eqindex_codes_ctp,1)
    f = cFutures(eqindex_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,eqindex_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for equity index futures......\n');

%%
% precious metals
pm_codes_ctp = {'au1806';'au1812';'ag1806';'ag1812'};

for i = 1:size(pm_codes_ctp)
    f = cFutures(pm_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,pm_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for precious metal futures......\n');

%%
% black metals
black_codes_ctp = {'rb1810';'rb1901';'i1809';'i1901';'j1809';'j1901';...
    'jm1809';'jm1901';'ZC809';'ZC901'};
for i = 1:size(black_codes_ctp)
    f = cFutures(black_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,black_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for black futures......\n');

%%
% argriculture
arg_codes_ctp = {'a1805';'a1809';'a1901';...
    'ru1805';'ru1809';'ru1901';...
    'm1805';'m1809';'m1901';...
    'SR805';'SR809';'SR901';...
    'y1805';'y1809';'y1901';...
    'p1805';'p1809';'p1901'};
for i = 1:size(arg_codes_ctp)
    f = cFutures(arg_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,arg_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for agriculture futures......\n');
%%
% crude oil
crudeoil_codes_ctp = {'sc1809';'sc1810';'sc1811';'sc1812';...
    'sc1901';'sc1902';'sc1903';'sc1904';'sc1905';'sc1906'};
for i = 1:size(crudeoil_codes_ctp)
    f = cFutures(crudeoil_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,crudeoil_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for crude oil futures......\n');

%%
% chemical
chemical_codes_ctp = {'pp1809';'pp1901';'l1809';'l1901'};
for i = 1:size(chemical_codes_ctp)
    f = cFutures(chemical_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,chemical_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for chemical futures......\n');
