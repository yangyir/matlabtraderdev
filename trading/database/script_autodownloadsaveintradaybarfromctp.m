if ~exist('md_ctp','var') || ~md_ctp.isconnect, md_ctp = ctpmdconnect;end
MDE = cMDEFut;
QMS = cQMS;QMS.setdatasource('ctp');
MDE.qms_ = QMS;

%%
%define futures of interests
bm_codes = {'cu1712';'cu1801';'cu1802';'cu1803';...
    'al1712';'al1801';'al1802';'al1803';...
    'zn1712';'zn1801';'zn1802';'zn1803';...
    'pb1712';'pb1801';'pb1802';'pb1803';'ni1801';'ni1805'};
bm_n = size(bm_codes,1);
bm_futs = cell(bm_n,1);
for i = 1:bm_n, bm_futs{i} = cFutures(bm_codes{i});bm_futs{i}.loadinfo([bm_codes{i},'_info.txt']);end

%
bk_codes = {'rb1801';'rb1805';'i1801';'i1805';'j1801';'j1805';...
    'jm1801';'jm1805';'ZC801';'ZC805'};
bk_n = size(bk_codes,1);
bk_futs = cell(bm_n,1);
for i = 1:bk_n, bk_futs{i} = cFutures(bk_codes{i});bk_futs{i}.loadinfo([bk_codes{i},'_info.txt']);end

%
ag_codes = {'m1801';'m1805';'SR801';'SR805'};
ag_n = size(ag_codes,1);
ag_futs = cell(ag_n,1);
for i = 1:ag_n, ag_futs{i} = cFutures(ag_codes{i});ag_futs{i}.loadinfo([ag_codes{i},'_info.txt']);end

%%
%register futures with market data engine
for i = 1:bm_n, MDE.registerinstrument(bm_futs{i});end
for i = 1:bk_n, MDE.registerinstrument(bk_futs{i});end
for i = 1:ag_n, MDE.registerinstrument(ag_futs{i});end

%%
MDE.initcandles;

%%
MDE.start;

%%
MDE.stop;
