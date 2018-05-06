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
bm_codes_ctp = {'cu1801';'cu1802';'cu1803';'cu1804';'cu1805';'cu1806';'cu1807';'cu1808';'cu1809';'cu1810';'cu1811';'cu1812';...
    'al1801';'al1802';'al1803';'al1804';'al1805';'al1806';'al1807';'al1808';'al1809';'al1810';'al1811';'al1812';...
    'zn1801';'zn1802';'zn1803';'zn1804';'zn1805';'zn1806';'zn1807';'zn1808';'zn1809';'zn1810';'zn1811';'zn1812';...
    'pb1801';'pb1802';'pb1803';'pb1804';'pb1805';'pb1806';'pb1807';'pb1808';'pb1809';'pb1810';'pb1811';'pb1812';...
    'ni1801';'ni1805';'ni1807';'ni1809';'ni1811';'ni1901'};

for i = 1:size(bm_codes_ctp,1)
    f = cFutures(bm_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,bm_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for base metal futures......\n');

%%
% govtbond futures
govtbond_codes_ctp = {'TF1803';'TF1806';'TF1809';'TF1812';...
    'T1803';'T1806';'T1809';'T1812'};

for i = 1:size(govtbond_codes_ctp,1)
    f = cFutures(govtbond_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,govtbond_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for govt bond futures......\n');

%%
pm_codes_ctp = {'au1806';'au1812';'ag1806';'ag1812'};

for i = 1:size(pm_codes_ctp)
    f = cFutures(pm_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,pm_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for precious metal futures......\n');

%%
black_codes_ctp = {'rb1805';'rb1810';'i1805';'i1809';'j1805';'j1809';...
    'jm1805';'jm1809';'ZC805';'ZC809'};
for i = 1:size(black_codes_ctp)
    f = cFutures(black_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,black_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for black futures......\n');

%%
arg_codes_ctp = {'a1805';'a1809';'ru1805';'ru1809';'m1805';'m1809';'m1901';'SR805';'SR809';'SR901'};
for i = 1:size(arg_codes_ctp)
    f = cFutures(arg_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,arg_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for agriculture futures......\n');
