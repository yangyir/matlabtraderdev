function [futs] = saveactivefuturesfromths(ths,override)
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
    assetlist = {'IFZL1.CFE';'IHZL1.CFE';'ICZL1.CFE';'IMZL1.CFE';...
        'TFZL2.CFE';'TZL2.CFE';'TLZL2.CFE';...
        'AUZL1.SHF';'AGZL1.SHF';...
        'CUZL1.SHF';'ALZL1.SHF';'ZNZL1.SHF';'PBZL1.SHF';'NIZL1.SHF';'SNZL1.SHF';...
        'TAZL1.CZC';'LZL1.DCE';'PPZL1.DCE';'MAZL1.CZC';'ZCZL1.CZC';'SCZL1.SHF';'FUZL1.SHF';'PGZL1.DCE';'SAZL1.CZC';'URZL1.CZC';...
        'SRZL1.CZC';'CFZL1.CZC';'CZL1.DCE';'JDZL1.DCE';'AZL1.DCE';'MZL1.DCE';'LHZL1.DCE';...
        'YZL1.DCE';'PZL1.DCE';'OIZL1.CZC';'RMZL1.CZC';'APZL1.CZC';'RUZL1.SHF';...
        'JZL1.DCE';'JMZL1.DCE';'RBZL1.SHF';'IZL1.DCE';'HCZL1.SHF';'FGZL1.CZC';'VZL1.DCE'};
    data = THS_BD(assetlist,'ths_month_contract_code_future',datestr(dateend,'yyyy-mm-dd'),'format:table');
    futs = data.ths_month_contract_code_future;
    for i = 1:length(futs)
        if strcmpi(assetlist{i}(end-2:end),'CFE')
            futs{i} = upper(futs{i});
        elseif strcmpi(assetlist{i}(end-2:end),'CZC')
            futs{i} = upper(futs{i});
        elseif strcmpi(assetlist{i}(end-2:end),'SHF')
            futs{i} = lower(futs{i});
        elseif strcmpi(assetlist{i}(end-2:end),'DCE')
            futs{i} = lower(futs{i});
        end
    end
    %
    %%
    fid = fopen([activefuturesdir,filename],'w');
    for ifut = 1:length(futs)
        fprintf(fid,'%s\n',futs{ifut});
    end
    fclose(fid);
    fprintf('finish save active futures from ths...\n');
end

