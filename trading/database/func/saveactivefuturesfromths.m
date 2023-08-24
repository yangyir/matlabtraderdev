function [] = saveactivefuturesfromths(ths,override)
%save active futures from ths
if ~isa(ths,'cTHS')
    error('saveactivefuturesfromths:invalid THS instance input')
end
if nargin < 2
    override = false;
end
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
dateend = getlastbusinessdate;
filename = ['activefutures_',datestr(dateend,'yyyymmdd'),'.txt'];
listing = dir(activefuturesdir);
nfile = length(listing);
iflag = false;
for ifile = 1:nfile
    if strcmpi(listing(ifile).name,filename)
        iflag = true;
        break
    end
end
if iflag && ~override, return; end
%%
%note;access for futures traded in CFE is denied in THS (need payment)
assetlist = {'IFZL.CFE';'IHZL.CFE';'ICZL.CFE';'IMZL.CFE';...
    'TFZL.CFE';'TZL.CFE';...
    'AUZL.SHF';'AGZL.SHF';...
    'CUZL.SHF';'ALZL.SHF';'ZNZL.SHF';'PBZL.SHF';'NIZL.SHF';'SNZL.SHF';...
    'TAZL.CZC';'LZL.DCE';'PPZL.DCE';'MAZL.CZC';'ZCZL.CZC';'SCZL.SHF';'FUZL.SHF';...
    'SRZL.CZC';'CFZL.CZC';'CZL.DCE';'JDZL.DCE';'AZL.DCE';'MZL.DCE';'LHZL.DCE';...
    'YZL.DCE';'PZL.DCE';'OIZL.CZC';'RMZL.CZC';'APZL.CZC';'RUZL.SHF';...
    'JZL.DCE';'JMZL.DCE';'RBZL.SHF';'IZL.DCE';'HCZL.SHF';'FGZL.CZC'};
data = THS_BD(assetlist(7:end),'ths_month_contract_code_future',datestr(dateend,'yyyy-mm-dd'),'format:table');
futs = data.ths_month_contract_code_future;

end

