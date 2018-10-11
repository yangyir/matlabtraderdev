function [] = saveactivefuturesfrombloomberg(bbg)

if ~isa(bbg,'cBloomberg')
    error('saveactivefuturesfrombloomberg;invalid bloomberg instance input')
end

activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
datestart = datenum('2018-04-10');   % Bloomberg only record tick/intraday bucket data for 6 months

%%
% list the active contract names
assetlist = getassetmaptable;
nasset = size(assetlist,1);
dateend = getlastbusinessdate;
busdates = gendates('fromdate',datestart,'todate',dateend);
listing = dir(activefuturesdir);
nfile = length(listing);
ndates = length(busdates);
for idate = 1:ndates
    filename = ['activefutures_',datestr(busdates(idate),'yyyymmdd'),'.txt'];
    iflag = false;
    for ifile = 1:nfile
        if strcmpi(listing(ifile).name,filename)
            iflag = true;
            break
        end
    end
    
    if iflag, continue; end
    %
    futs = cell(nasset,1);
    for iasset = 1:nasset
        futs{iasset} = getactivefutures(bbg.ds_,assetlist{iasset},'date',busdates(idate));
    end
    %
    fid = fopen([activefuturesdir,filename],'w');
    for iasset = 1:nasset
        fprintf(fid,'%s\n',futs{iasset});
    end
    fclose(fid);
end

%
% % find the last record date of the tick data
% lastrecord = zeros(nasset,1);
% for i = 1:nasset
%     foldername = [tickdatadir,ctpcodelist{i,2},'\'];
%     try
%         cd(foldername);
%     catch
%         mkdir(foldername);
%     end
%     
%     listing = dir(foldername);
%     obs = zeros(size(listing,1),1);
%     for j = 1:size(listing,1)
%         idx = strfind(listing(j).name,ctpcodelist{i,2});
%         if isempty(idx)
%             obs(j) = -1;
%         else
%             obs(j) = datenum(listing(j).name(length(ctpcodelist{i,2})+2:length(ctpcodelist{i,2})+9),'yyyymmdd');
%         end
%     end
%     lastrecord(i) = max(obs);   
% end

fprintf('finish save active futures from bloomberg...\n');
end