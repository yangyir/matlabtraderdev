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
bm_codes_ctp = {'cu1709';'cu1710';'cu1711';'cu1712';'cu1801';'cu1802';'cu1803';...
    'al1709';'al1710';'al1711';'al1712';'al1801';'al1802';'al1803';...
    'zn1709';'zn1710';'zn1711';'zn1712';'zn1801';'zn1802';'zn1803';...
    'pb1709';'pb1710';'pb1711';'pb1712';'pb1801';'pb1802';'pb1803';...
    'ni1709';'ni1801';'ni1805'};

for i = 1:size(bm_codes_ctp,1)
    f = cFutures(bm_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,bm_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for base metal futures......\n');

%%
% govtbond futures
govtbond_codes_ctp = {'TF1703';'TF1706';'TF1709';'TF1712';'TF1803';...
    'T1703';'T1706';'T1709';'T1712';'T1803'};

for i = 1:size(govtbond_codes_ctp,1)
    f = cFutures(govtbond_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,govtbond_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for govt bond futures......\n');

%%
pm_codes_ctp = {'au1712';'au1806';'ag1712';'ag1806'};

for i = 1:size(pm_codes_ctp)
    f = cFutures(pm_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,pm_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for precious metal futures......\n');

%%
black_codes_ctp = {'rb1801';'rb1805';'i1801';'i1805';'j1801';'j1805';...
    'jm1801';'jm1805';'ZC801';'ZC805'};
for i = 1:size(black_codes_ctp)
    f = cFutures(black_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,black_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for black futures......\n');

%%
arg_codes_ctp = {'a1801';'a1805';'ru1801';'ru1805'};
for i = 1:size(arg_codes_ctp)
    f = cFutures(arg_codes_ctp{i});
    f.init(conn);
    f.saveinfo([dir_,arg_codes_ctp{i},...
        '_info.txt']);
end
fprintf('done for agriculture futures......\n');
