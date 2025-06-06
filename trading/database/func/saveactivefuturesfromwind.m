function [] = saveactivefuturesfromwind(w,override)
%save active futures from wind
if ~isa(w,'cWind')
    error('saveactivefuturesfromwind;invalid wind instance input')
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
assetlist = {'IF.CFE';'IH.CFE';'IC.CFE';'IM.CFE';...
    'TF.CFE';'T.CFE';'TL.CFE';...
    'AU.SHF';'AG.SHF';...
    'CU.SHF';'AL.SHF';'ZN.SHF';'PB.SHF';'NI.SHF';'SN.SHF';...
    'TA.CZC';'L.DCE';'PP.DCE';'MA.CZC';'ZC.CZC';'SC.INE';'FU.SHF';'PG.DCE';'SA.CZC';'UR.CZC';...
    'SR.CZC';'CF.CZC';'C.DCE';'JD.DCE';'A.DCE';'M.DCE';'LH.DCE';...
    'Y.DCE';'P.DCE';'OI.CZC';'RM.CZC';'AP.CZC';'RU.SHF';...
    'J.DCE';'JM.DCE';'RB.SHF';'I.DCE';'HC.SHF';'FG.CZC';'V.DCE'};
nasset = size(assetlist,1);
wdata = w.ds_.wss(assetlist,'lastdelivery_date');

for i = 1:size(wdata,1)
    try
        dnum_i = datenum(wdata{i,1},'dd/mm/yyyy');
        wdata{i,1} = datestr(dnum_i,'yyyy-mm-dd');
    catch
        wdata{i,1} = datestr(wdata{i,1},'yyyy-mm-dd');
    end
    
end

% list the active contract names
futs = cell(nasset,1);
for iasset = 1:nasset
    asset_code = assetlist{iasset};
    j = strfind(asset_code,'.');
    short_code = asset_code(1:j-1);
    exchange_code = asset_code(end-2:end);
    if strcmpi(exchange_code,'CFE')
        futs{iasset} = [short_code,datestr(wdata{iasset'},'yymm')];
    elseif strcmpi(exchange_code,'CZC')
        tenorstr = datestr(wdata{iasset'},'yymm');
        futs{iasset} = [short_code,tenorstr(2:end)];
    else
       futs{iasset} = [lower(short_code),datestr(wdata{iasset'},'yymm')]; 
    end
end

%%
fid = fopen([activefuturesdir,filename],'w');
for iasset = 1:nasset
    fprintf(fid,'%s\n',futs{iasset});
end
fclose(fid);
fprintf('finish save active futures from wind...\n');
end