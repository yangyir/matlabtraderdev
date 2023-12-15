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
        'AUZL2.SHF';'AGZL2.SHF';...
        'CUZL2.SHF';'ALZL2.SHF';'ZNZL2.SHF';'PBZL2.SHF';'NIZL2.SHF';'SNZL2.SHF';...
        'TAZL2.CZC';'LZL2.DCE';'PPZL2.DCE';'MAZL2.CZC';'ZCZL2.CZC';'SCZL2.SHF';'FUZL2.SHF';'PGZL2.DCE';'SAZL2.CZC';'URZL2.CZC';...
        'SRZL2.CZC';'CFZL2.CZC';'CZL2.DCE';'JDZL2.DCE';'AZL2.DCE';'MZL2.DCE';'LHZL2.DCE';...
        'YZL2.DCE';'PZL2.DCE';'OIZL2.CZC';'RMZL2.CZC';'APZL2.CZC';'RUZL2.SHF';...
        'JZL2.DCE';'JMZL2.DCE';'RBZL2.SHF';'IZL2.DCE';'HCZL2.SHF';'FGZL2.CZC';'VZL2.DCE'};
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

