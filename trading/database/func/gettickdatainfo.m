function [codelist,firstrecorddt] = gettickdatainfo(conn,assetname)
%%
if ~isa(conn,'cBloomberg')
    error('gettickdatainfo:invalid bloomberg connection input')
end

%%
lastbd = getlastbusinessdate;
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
tickdatadir = [getenv('DATAPATH'),'ticks\'];
filename = ['activefutures_',datestr(lastbd,'yyyymmdd'),'.txt'];
try
    activefutures = cDataFileIO.loadDataFromTxtFile([activefuturesdir,filename]);
catch
    saveactivefuturesfrombloomberg(conn);
    activefutures = cDataFileIO.loadDataFromTxtFile([activefuturesdir,filename]);
end;
assetlist = getassetmaptable;
nasset = length(assetlist);

%%
% assetname = 'nickel';

ifound = false;
for iasset = 1:nasset
    if strcmpi(assetname,assetlist(iasset))
        ifound = true;
        break
    end
end
if ~ifound
    fprintf('active contract for %s not found...\n',assetname);
    codelist = {};
    firstrecorddt = [];
else
    fut = activefutures{iasset};            
    futlist = listcontracts(assetname,'connection','bloomberg');
    check = getdata(conn.ds_,futlist,'last_tradeable_dt');
    ltd = check.last_tradeable_dt;
    livefutlist = futlist(ltd >= lastbd);
    livefutlistctp = cell(length(livefutlist),1);
    for j = 1:length(livefutlist)
        livefutlistctp{j} = bbg2ctp(livefutlist{j});
        if strcmpi(livefutlistctp{j},fut)
            iactivefut = j;
        end
    end
    %
    foldername = [tickdatadir,fut,'\'];
    try
        cd(foldername);
        folderexist = true;
    catch
        folderexist = false;
    end
    
    if ~folderexist 
        %in case tick data folder for the active futures still not exist
        if iactivefut ~= 1
            %first to check whether the active futures is the first live futures
            %if not, we take the previous futures last record date as the
            %active futures first record date
            foldernameb4 = [tickdatadir,livefutlistctp{iactivefut-1},'\'];
            listing = dir(foldernameb4);
            nfile = length(listing);
            recorddt = zeros(nfile,1);
        
            for ifile = 1:nfile
                if ~isempty(strfind(listing(ifile).name,livefutlistctp{iactivefut-1}))
                    recorddt(ifile) = datenum(listing(ifile).name(length(livefutlistctp{iactivefut-1})+2:length(livefutlistctp{iactivefut-1})+9),'yyyymmdd');
                else
                    recorddt(ifile) = -1;
                end
            end
            
            if isempty(recorddt)
                %if the previous active futures not exist
                %by default, we take 2 business date from last business date
                codelist = {fut};
                firstrecorddt = businessdate(lastbd,-1);
            else
                %in such a case we need to download tick data of the active
                %futures and the previous active futures
                lastrecorddtb4 = max(recorddt);
                codelist = {livefutlistctp{iactivefut-1};fut};
                firstrecorddt = [lastrecorddtb4;lastrecorddtb4];
            end
        else
            %if the active futures is the first futures on the live futures
            %by default, we take 2 business date from last business date
            codelist = {fut};
            firstrecorddt = businessdate(lastbd,-1);
        end
    else
        %in case tick data folder for the active futures exist
        foldername = [tickdatadir,fut,'\'];
        listing = dir(foldername);
        nfile = length(listing);
        recorddt = zeros(nfile,1);
        for ifile = 1:nfile
            if ~isempty(strfind(listing(ifile).name,fut))
                recorddt(ifile) = datenum(listing(ifile).name(length(fut)+2:length(fut)+9),'yyyymmdd');
            else
                recorddt(ifile) = -1;
            end
        end
        firstrecorddt = max(recorddt);
        codelist = {fut};
    end
    
end
