%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = false;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end
lastbd = getlastbusinessdate;

%%
% saveactivefuturesfrombloomberg(conn);
% activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
% filename = ['activefutures_',datestr(lastbd,'yyyymmdd'),'.txt'];
% activefutures = cDataFileIO.loadDataFromTxtFile([activefuturesdir,filename]);
% assetlist = getassetmaptable;
% nasset = length(assetlist);

%%
%base metals
list = {'copper';'aluminum';'zinc';'lead';'nickel'};
for i = 1:size(list,1)
    futlist_i = listcontracts(list{i},'connection','bloomberg');
    check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
    ltd = check_i.last_tradeable_dt;
    idx = ltd >= lastbd;
    livefutlist_i = futlist_i(idx);
    for j = 1:size(livefutlist_i,1)
        code_j = bbg2ctp(livefutlist_i{j});
        saveintradaybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving intraday bar data for base metal futures......\n\n');

%%
% govtbond futures
list = {'govtbond_5y';'govtbond_10y'};
for i = 1:size(list,1)
    futlist_i = listcontracts(list{i},'connection','bloomberg');
    check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
    ltd = check_i.last_tradeable_dt;
    idx = ltd >= lastbd;
    livefutlist_i = futlist_i(idx);
    for j = 1:size(livefutlist_i,1)
        code_j = bbg2ctp(livefutlist_i{j});
        try
            saveintradaybarfrombloomberg(conn,code_j,override);
        catch
        end
    end
end
fprintf('done for saving intraday bar data for govt bond futures......\n\n');

%%
% equity index futures
list = {'eqindex_300';'eqindex_50';'eqindex_500'};
for i = 1:size(list,1)
    futlist_i = listcontracts(list{i},'connection','bloomberg');
    check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
    ltd = check_i.last_tradeable_dt;
    idx = ltd >= lastbd;
    livefutlist_i = futlist_i(idx);
    for j = 1:size(livefutlist_i,1)
        code_j = bbg2ctp(livefutlist_i{j});
        saveintradaybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving intraday bar data for equity index futures......\n\n');

%%
% precious metals
list = {'gold';'silver'};
for i = 1:size(list,1)
    futlist_i = listcontracts(list{i},'connection','bloomberg');
    check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
    ltd = check_i.last_tradeable_dt;
    idx = ltd >= lastbd;
    livefutlist_i = futlist_i(idx);
    for j = 1:size(livefutlist_i,1)
        code_j = bbg2ctp(livefutlist_i{j});
        saveintradaybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving intraday bar data for precious metal futures\n\n');

%%
% energy
list = {'pta';'lldpe';'pp';'methanol';'thermal coal';'crude oil'};
for i = 1:size(list,1)
    futlist_i = listcontracts(list{i},'connection','bloomberg');
    check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
    ltd = check_i.last_tradeable_dt;
    idx = ltd >= lastbd;
    livefutlist_i = futlist_i(idx);
    for j = 1:size(livefutlist_i,1)
        code_j = bbg2ctp(livefutlist_i{j});
        saveintradaybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving intraday bar data for energy futures\n\n');

%%
% agriculture
list = {'sugar';'cotton';'corn';'egg';...
            'soybean';'soymeal';'soybean oil';'palm oil';...
            'rapeseed oil';'rapeseed meal';...
            'apple';...
            'rubber'};
for i = 1:size(list,1)
    futlist_i = listcontracts(list{i},'connection','bloomberg');
    check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
    ltd = check_i.last_tradeable_dt;
    idx = ltd >= lastbd;
    livefutlist_i = futlist_i(idx);
    for j = 1:size(livefutlist_i,1)
        code_j = bbg2ctp(livefutlist_i{j});
        saveintradaybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving intraday bar data for agriculture futures\n\n');

%%
% industry
list = {'coke';'coking coal';'deformed bar';'iron ore';'glass'};
for i = 1:size(list,1)
    futlist_i = listcontracts(list{i},'connection','bloomberg');
    check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
    ltd = check_i.last_tradeable_dt;
    idx = ltd >= lastbd;
    livefutlist_i = futlist_i(idx);
    for j = 1:size(livefutlist_i,1)
        code_j = bbg2ctp(livefutlist_i{j});
        saveintradaybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving intraday bar data for industry futures\n\n');

%%
%clear variables
clear i
clear override conn list futlist_i check_i ltd idx livefutlist_i

