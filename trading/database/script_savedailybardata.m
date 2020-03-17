%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
override = true;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end
lastbd = getlastbusinessdate;

%%
% base metals
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
list = {'coke';'coking coal';'deformed bar';'iron ore';'hotroiled coil';'glass'};
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
% corn option
futlist_i = listcontracts('corn','connection','bloomberg');
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
bucketsize = 20;
nopt = 20;
strikes1_corn = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;
strikes2_corn = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;

for j = 1:length(strikes1_corn)
    c_code_ = [futcode1,'-C-',num2str(strikes1_corn(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'-P-',num2str(strikes1_corn(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end

for j = 1:length(strikes2_corn)
    c_code_ = [futcode2,'-C-',num2str(strikes2_corn(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode2,'-P-',num2str(strikes2_corn(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
fprintf('done for corn options......\n\n');
%%
% iron ore option
futlist_i = listcontracts('iron ore','connection','bloomberg');
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
bucketsize = 10;
nopt = 20;
strikes1_ironore = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;


for j = 1:length(strikes1_ironore)
    c_code_ = [futcode1,'-C-',num2str(strikes1_ironore(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'-P-',num2str(strikes1_ironore(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end

if ~strcmpi(futcode2,'i2001')
    strikes2_ironore = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;
    for j = 1:length(strikes2_ironore)
        c_code_ = [futcode2,'-C-',num2str(strikes2_ironore(j))];
        savedailybarfrombloomberg(conn,c_code_,override);
        %
        p_code_ = [futcode2,'-P-',num2str(strikes2_ironore(j))];
        savedailybarfrombloomberg(conn,p_code_,override);
    end
    fprintf('done for iron-ore options......\n\n');
end
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
strikes1_sugar = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;
strikes2_sugar = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;

for j = 1:length(strikes1_sugar)
    c_code_ = [futcode1,'C',num2str(strikes1_sugar(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'P',num2str(strikes1_sugar(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end

for j = 1:length(strikes2_sugar)
    c_code_ = [futcode2,'C',num2str(strikes2_sugar(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode2,'P',num2str(strikes2_sugar(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
fprintf('done for white sugar options......\n\n');
%%
% cotton
futlist_i = listcontracts('cotton','connection','bloomberg');
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
bucketsize = 200;
nopt = 30;
strikes1_cotton = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;
strikes2_cotton = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;

for j = 1:length(strikes1_cotton)
    c_code_ = [futcode1,'C',num2str(strikes1_cotton(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'P',num2str(strikes1_cotton(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end

for j = 1:length(strikes2_cotton)
    c_code_ = [futcode2,'C',num2str(strikes2_cotton(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode2,'P',num2str(strikes2_cotton(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
fprintf('done for white cotton options......\n\n');
%%
% PTA
futlist_i = listcontracts('pta','connection','bloomberg');
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
nopt = 30;
strikes1_pta = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;
strikes2_pta = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;

for j = 1:length(strikes1_pta)
    c_code_ = [futcode1,'C',num2str(strikes1_pta(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'P',num2str(strikes1_pta(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
if ~strcmpi(futcode2,'TA001')
    for j = 1:length(strikes2_pta)
        c_code_ = [futcode2,'C',num2str(strikes2_pta(j))];
        savedailybarfrombloomberg(conn,c_code_,override);
        %
        p_code_ = [futcode2,'P',num2str(strikes2_pta(j))];
        savedailybarfrombloomberg(conn,p_code_,override);
    end
end
fprintf('done for white PTA options......\n\n');
%%
% Methanol
futlist_i = listcontracts('methanol','connection','bloomberg');
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
bucketsize = 25;
nopt = 30;
strikes1_ma = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;
strikes2_ma = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;

for j = 1:length(strikes1_ma)
    c_code_ = [futcode1,'C',num2str(strikes1_ma(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'P',num2str(strikes1_ma(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
if ~strcmpi(futcode2,'MA001')
    for j = 1:length(strikes2_ma)
        c_code_ = [futcode2,'C',num2str(strikes2_ma(j))];
        savedailybarfrombloomberg(conn,c_code_,override);
        %
        p_code_ = [futcode2,'P',num2str(strikes2_ma(j))];
        savedailybarfrombloomberg(conn,p_code_,override);
    end
end
fprintf('done for methanol options......\n\n');
%%
% copper
futlist_i = listcontracts('copper','connection','bloomberg');
check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
ltd = check_i.last_tradeable_dt;
idx = ltd >= lastbd;
livefutlist_i = futlist_i(idx);
check_i = getdata(conn.ds_,livefutlist_i,'open_int');
open_int = check_i.open_int;
open_int_sorted = sort(open_int,'descend');

idx1 = find(open_int == open_int_sorted(1));
idx2 = idx1+1;

check_i = history(conn.ds_,livefutlist_i{idx1},'px_last',lastbd,lastbd);
px1 = check_i(2);
futcode1 = bbg2ctp(livefutlist_i{idx1});
%
check_i = history(conn.ds_,livefutlist_i{idx2},'px_last',lastbd,lastbd);
px2 = check_i(2);
futcode2 = bbg2ctp(livefutlist_i{idx2});
if px1 <= 40000
    bucketsize = 500;
elseif px1 > 40000 && px1 <= 80000
    bucketsize = 1000;
else
    bucketsize = 2000;
end
nopt = 10;
strikes1_copper = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;
strikes2_copper = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;

for j = 1:length(strikes1_copper)
    c_code_ = [futcode1,'C',num2str(strikes1_copper(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'P',num2str(strikes1_copper(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end

for j = 1:length(strikes2_copper)
    c_code_ = [futcode2,'C',num2str(strikes2_copper(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode2,'P',num2str(strikes2_copper(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
fprintf('done for copper options......\n\n');
%%
% ruber option
futlist_i = listcontracts('rubber','connection','bloomberg');
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
bucketsize = 250;
nopt = 10;
strikes1_rubber = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;
strikes2_rubber = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;
%
for j = 1:length(strikes1_rubber)
    c_code_ = [futcode1,'C',num2str(strikes1_rubber(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'P',num2str(strikes1_rubber(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end

for j = 1:length(strikes2_rubber)
    c_code_ = [futcode2,'C',num2str(strikes2_rubber(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode2,'P',num2str(strikes2_rubber(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
fprintf('done for rubber options......\n\n');
%%
% gold
futlist_i = listcontracts('gold','connection','bloomberg');
check_i = getdata(conn.ds_,futlist_i,'last_tradeable_dt');
ltd = check_i.last_tradeable_dt;
idx = ltd >= lastbd;
livefutlist_i = futlist_i(idx);
check_i = getdata(conn.ds_,livefutlist_i,'open_int');
open_int = check_i.open_int;
open_int_sorted = sort(open_int,'descend');

idx1 = find(open_int == open_int_sorted(1));
idx2 = idx1+1;

check_i = history(conn.ds_,livefutlist_i{idx1},'px_last',lastbd,lastbd);
px1 = check_i(2);
futcode1 = bbg2ctp(livefutlist_i{idx1});
%
check_i = history(conn.ds_,livefutlist_i{idx2},'px_last',lastbd,lastbd);
px2 = check_i(2);
futcode2 = bbg2ctp(livefutlist_i{idx2});
bucketsize = 4;
nopt = 10;
strikes1_gold = floor(px1/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px1/bucketsize)*bucketsize+(nopt)/2*bucketsize;
strikes2_gold = floor(px2/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px2/bucketsize)*bucketsize+(nopt)/2*bucketsize;

for j = 1:length(strikes1_gold)
    c_code_ = [futcode1,'C',num2str(strikes1_gold(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode1,'P',num2str(strikes1_gold(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end

for j = 1:length(strikes2_gold)
    c_code_ = [futcode2,'C',num2str(strikes2_gold(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [futcode2,'P',num2str(strikes2_gold(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
fprintf('done for gold options......\n\n');
%% equity index
eqindex = 'SHSN300 Index';
px = history(conn.ds_,eqindex,'px_last',lastbd,lastbd);px = px(2);
bucketsize = 50;
nopt = 10;
strikes_eqindex = floor(px/bucketsize)*bucketsize-(nopt)/2*bucketsize:bucketsize:ceil(px/bucketsize)*bucketsize+(nopt)/2*bucketsize;
code1 = 'IO2002';
code2 = 'IO2003';
for j = 1:length(strikes_eqindex)
    c_code_ = [code1,'-C-',num2str(strikes_eqindex(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [code1,'-P-',num2str(strikes_eqindex(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end

for j = 1:length(strikes_eqindex)
    c_code_ = [code2,'-C-',num2str(strikes_eqindex(j))];
    savedailybarfrombloomberg(conn,c_code_,override);
    %
    p_code_ = [code2,'-P-',num2str(strikes_eqindex(j))];
    savedailybarfrombloomberg(conn,p_code_,override);
end
fprintf('done for equity index options......\n\n');