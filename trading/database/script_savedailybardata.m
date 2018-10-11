%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = true;
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
        savedailybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving daily bar data for base metal futures......\n\n');

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
        savedailybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving daily bar data for govtbond futures......\n\n');

%%
% equity index
list = {'eqindex_300';'eqindex_50';'eqindex_500'};
for i = 1:size(list,1)
    futlist_i = listcontracts(list{i},'connection','bloomberg');
    check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
    ltd = check_i.last_tradeable_dt;
    idx = ltd >= lastbd;
    livefutlist_i = futlist_i(idx);
    for j = 1:size(livefutlist_i,1)
        code_j = bbg2ctp(livefutlist_i{j});
        savedailybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving daily bar data for equity index futures......\n\n');

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
        savedailybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving daily bar data for precious metal futures\n\n');

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
        savedailybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving daily bar data for energy futures\n\n');

%%
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
        savedailybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving daily bar data for agriculture futures\n\n');

%%
list = {'coke';'coking coal';'deformed bar';'iron ore';'glass'};
for i = 1:size(list,1)
    futlist_i = listcontracts(list{i},'connection','bloomberg');
    check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
    ltd = check_i.last_tradeable_dt;
    idx = ltd >= lastbd;
    livefutlist_i = futlist_i(idx);
    for j = 1:size(livefutlist_i,1)
        code_j = bbg2ctp(livefutlist_i{j});
        savedailybarfrombloomberg(conn,code_j,override);
    end
end
fprintf('done for saving daily bar data for industry futures\n\n');

%%
% soymeal option
futlist_i = listcontracts('soymeal','connection','bloomberg');
check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
ltd = check_i.last_tradeable_dt;
idx = ltd >= lastbd;
livefutlist_i = futlist_i(idx);
check_i = getdata(conn.ds_,livefutlist_i,'open_int');
open_int = check_i.open_int;
open_int_sorted = sort(open_int,'descend');

idx1 = find(open_int == open_int_sorted(1));
idx2 = find(open_int == open_int_sorted(2));

check_i = history(conn.ds_,livefutlist_i{idx1},'px_last',lastbd,lastbd);
px1 = check_i(2);
futcode1 = bbg2ctp(livefutlist_i{idx1});
%
check_i = history(conn.ds_,livefutlist_i{idx2},'px_last',lastbd,lastbd);
px2 = check_i(2);
futcode2 = bbg2ctp(livefutlist_i{idx2});
%
bucketsize = 50;
nopt = 10;
strikes1_soymeal = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;
strikes2_soymeal = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;

for j = 1:length(strikes1_soymeal)
    c_code_ = [futcode1,'-C-',num2str(strikes1_soymeal(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'-P-',num2str(strikes1_soymeal(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end

for j = 1:length(strikes2_soymeal)
    c_code_ = [futcode2,'-C-',num2str(strikes2_soymeal(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode2,'-P-',num2str(strikes2_soymeal(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
fprintf('done for soymeal options......\n\n');

%%
% sugar
futlist_i = listcontracts('sugar','connection','bloomberg');
check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
ltd = check_i.last_tradeable_dt;
idx = ltd >= lastbd;
livefutlist_i = futlist_i(idx);
check_i = getdata(conn.ds_,livefutlist_i,'open_int');
open_int = check_i.open_int;
open_int_sorted = sort(open_int,'descend');

idx1 = find(open_int == open_int_sorted(1));
idx2 = find(open_int == open_int_sorted(2));

check_i = history(conn.ds_,livefutlist_i{idx1},'px_last',lastbd,lastbd);
px1 = check_i(2);
futcode1 = bbg2ctp(livefutlist_i{idx1});
%
check_i = history(conn.ds_,livefutlist_i{idx2},'px_last',lastbd,lastbd);
px2 = check_i(2);
futcode2 = bbg2ctp(livefutlist_i{idx2});
%
bucketsize = 100;
nopt = 10;
strikes1_soymeal = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;
strikes2_soymeal = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;

for j = 1:length(strikes1_soymeal)
    c_code_ = [futcode1,'C',num2str(strikes1_soymeal(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'P',num2str(strikes1_soymeal(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end

for j = 1:length(strikes2_soymeal)
    c_code_ = [futcode2,'C',num2str(strikes2_soymeal(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode2,'P',num2str(strikes2_soymeal(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
fprintf('done for white sugar options......\n\n');


