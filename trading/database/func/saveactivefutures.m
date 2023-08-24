function [futlist] = saveactivefutures(w,ths,override)
%save active futures
%financial futures are saved with WIND
%commodity futures are saved with THS
%access for financial futures are denied in THS (payment required)

if ~isa(w,'cWind')
    error('saveactivefutures;invalid WIND instance input')
end 

if ~isa(ths,'cTHS')
    error('saveactivefutures;invalid THS instance input')
end

futlist = {};

if nargin < 3, override = false;end

activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
dateend = getlastbusinessdate;
filename = ['activefutures_',datestr(dateend,'yyyymmdd'),'.txt'];

if ~override
    try
        futlist = cDataFileIO.loadDataFromTxtFile([activefuturesdir,filename]);
        return
    catch
        futlist = {};
        fprintf('%s not found!!!\n',filename);
        return
    end
end

assetlist_wind = {'IF.CFE';'IH.CFE';'IC.CFE';'IM.CFE';...
    'TF.CFE';'T.CFE';...
    'AU.SHF';'AG.SHF';...
    'CU.SHF';'AL.SHF';'ZN.SHF';'PB.SHF';'NI.SHF';'SN.SHF';...
    'TA.CZC';'L.DCE';'PP.DCE';'MA.CZC';'ZC.CZC';'SC.INE';'FU.SHF';...
    'SR.CZC';'CF.CZC';'C.DCE';'JD.DCE';'A.DCE';'M.DCE';'LH.DCE';...
    'Y.DCE';'P.DCE';'OI.CZC';'RM.CZC';'AP.CZC';'RU.SHF';...
    'J.DCE';'JM.DCE';'RB.SHF';'I.DCE';'HC.SHF';'FG.CZC'};
%
assetlist_ths = {'IFZL.CFE';'IHZL.CFE';'ICZL.CFE';'IMZL.CFE';...
    'TFZL.CFE';'TZL.CFE';...
    'AUZL.SHF';'AGZL.SHF';...
    'CUZL.SHF';'ALZL.SHF';'ZNZL.SHF';'PBZL.SHF';'NIZL.SHF';'SNZL.SHF';...
    'TAZL.CZC';'LZL.DCE';'PPZL.DCE';'MAZL.CZC';'ZCZL.CZC';'SCZL.SHF';'FUZL.SHF';...
    'SRZL.CZC';'CFZL.CZC';'CZL.DCE';'JDZL.DCE';'AZL.DCE';'MZL.DCE';'LHZL.DCE';...
    'YZL.DCE';'PZL.DCE';'OIZL.CZC';'RMZL.CZC';'APZL.CZC';'RUZL.SHF';...
    'JZL.DCE';'JMZL.DCE';'RBZL.SHF';'IZL.DCE';'HCZL.SHF';'FGZL.CZC'};

%
wdata = w.ds_.wss(assetlist_wind,'lastdelivery_date');
futs1 = cell(6,1);
for iasset = 1:6
    asset_code = assetlist_wind{iasset};
    j = strfind(asset_code,'.');
    short_code = asset_code(1:j-1);
    futs1{iasset} = [short_code,datestr(wdata{iasset},'yymm')];     
end
%
data = THS_BD(assetlist_ths(7:end),'ths_month_contract_code_future',datestr(dateend,'yyyy-mm-dd'),'format:table');
futs2 = data.ths_month_contract_code_future;
futs2_ = futs2;
for i = 1:length(futs2)
    futs2_{i} = str2ctp(futs2{i});
end
futlist = [futs1;futs2_];
%%
fid = fopen([activefuturesdir,filename],'w');
for iasset = 1:length(futlist)
    fprintf(fid,'%s\n',futlist{iasset});
end
fclose(fid);
fprintf('finish save active futures...\n');


