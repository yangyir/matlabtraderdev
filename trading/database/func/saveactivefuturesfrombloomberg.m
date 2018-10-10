if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end
%%
% list the active contract names
assetlist = getassetmaptable;
nasset = size(assetlist,1);
ctpcodelist = cell(nasset,2);
for i = 1:nasset
    info_i = getassetinfo(assetlist{i});
    bbgseca = info_i.BloombergSecA;
    data = conn.ds_.getdata(bbgseca,'parsekyable_des');
    bbgsec = data.parsekyable_des{1};
    ctpcodelist{i,1} = assetlist{i};
    ctpcodelist{i,2} = bbg2ctp(bbgsec);
end

%%
% find the last record date of the tick data
tickdatadir = [getenv('DATAPATH'),'ticks\'];
lastrecord = zeros(nasset,1);
for i = 1:nasset
    foldername = [tickdatadir,ctpcodelist{i,2},'\'];
    try
        cd(foldername);
    catch
        mkdir(foldername);
    end
    
    listing = dir(foldername);
    obs = zeros(size(listing,1),1);
    for j = 1:size(listing,1)
        idx = strfind(listing(j).name,ctpcodelist{i,2});
        if isempty(idx)
            obs(j) = -1;
        else
            obs(j) = datenum(listing(j).name(length(ctpcodelist{i,2})+2:length(ctpcodelist{i,2})+9),'yyyymmdd');
        end
    end
    lastrecord(i) = max(obs);   
end
%%
% note:the script below is a one-off run
datestart = datenum('2018-04-10');   % Bloomberg only record tick/intraday bucket data for 6 months
dateend = getlastbusinessdate;
busdates = gendates('fromdate',datestart,'todate',dateend);
ndates = length(busdates);
activefutures = cell(ndates,1);
for idate = 1:ndates
    futs = cell(nasset,1);
    for iasset = 1:nasset
        futs{iasset} = getactivefutures(conn.ds_,assetlist{iasset},'date',busdates(idate));
    end
    activefutures{idate} = futs;
end
%%
for idate = 1:ndates
    filename = [getenv('DATAPATH'),'activefutures\activefutures_',datestr(busdates(idate),'yyyymmdd'),'.txt'];
    fid = fopen(filename,'w');
    for iasset = 1:nasset
        fprintf(fid,'%s\n',activefutures{idate}{iasset});
    end
    fclose(fid);
end
%%
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
for idate = 1:ndates
    filename = ['activefutures_',datestr(busdates(idate),'yyyymmdd'),'.txt'];
    if hasfileindirectory(activefuturesdir,filename), continue; end
    %
    futs = cell(nasset,1);
    for iasset = 1:nasset
        futs{iasset} = getactivefutures(conn.ds_,assetlist{iasset},'date',busdates(idate));
    end
    %
    fid = fopen([activefuturesdir,filename],'w');
    for iasset = 1:nasset
        fprintf(fid,'%s\n',futs{iasset});
    end
    fclose(fid);
    
end





