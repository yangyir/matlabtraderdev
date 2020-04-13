%note:
%this script initiates the futures information from bloomberg connection
%and then save the info into the prespecified folder and text files
% override = false;
if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end

% fromdate = datestr(businessdate(getlastbusinessdate,-1),'yyyy-mm-dd');
fromdate = '2018-10-08';
todate = datestr(getlastbusinessdate,'yyyy-mm-dd');

%%
% base metals
list = {'copper';'aluminum';'zinc';'lead';'nickel'};
for i = 1:size(list,1)
    [codelist,firstrecorddt] = gettickdatainfo(conn,list{i});
    for j = 1:size(codelist,1)
        savetickfrombloomberg(conn,codelist{j},...
            'fromdate',datestr(firstrecorddt(j),'yyyy-mm-dd'),...
            'todate',todate);
    end
end
fprintf('done for saving tick data for base metal futures......\n\n');

%%
% govt bond
list = {'govtbond_5y';'govtbond_10y'};
for i = 1:size(list,1)
    [codelist,firstrecorddt] = gettickdatainfo(conn,list{i});
    for j = 1:size(codelist,1)
        savetickfrombloomberg(conn,codelist{j},...
            'fromdate',datestr(firstrecorddt(j),'yyyy-mm-dd'),...
            'todate',todate);
    end
end
fprintf('done for saving tick data for govt bond futures......\n\n');

%%
% equity index futures
list = {'eqindex_300';'eqindex_50';'eqindex_500'};
for i = 1:size(list,1)
    [codelist,firstrecorddt] = gettickdatainfo(conn,list{i});
    for j = 1:size(codelist,1)
        savetickfrombloomberg(conn,codelist{j},...
            'fromdate',datestr(firstrecorddt(j),'yyyy-mm-dd'),...
            'todate',todate);
    end
end
fprintf('done for saving tick data for eqindex futures......\n\n');

%%
% precious metals
list = {'gold';'silver'};
for i = 1:size(list,1)
    [codelist,firstrecorddt] = gettickdatainfo(conn,list{i});
    for j = 1:size(codelist,1)
        savetickfrombloomberg(conn,codelist{j},...
            'fromdate',datestr(firstrecorddt(j),'yyyy-mm-dd'),...
            'todate',todate);
    end
end
fprintf('done for saving tick data for precious metal futures\n\n');

%%
% energy
list = {'pta';'lldpe';'pp';'methanol';'thermal coal';'crude oil'};
for i = 1:size(list,1)
    [codelist,firstrecorddt] = gettickdatainfo(conn,list{i});
    for j = 1:size(codelist,1)
        savetickfrombloomberg(conn,codelist{j},...
            'fromdate',datestr(firstrecorddt(j),'yyyy-mm-dd'),...
            'todate',todate);
    end
end
fprintf('done for saving tick data for energy futures\n\n');

%%
% agriculture
list = {'sugar';'cotton';'corn';'egg';...
            'soybean';'soymeal';'soybean oil';'palm oil';...
            'rapeseed oil';'rapeseed meal';...
            'apple';...
            'rubber'};
for i = 1:size(list,1)
    try
        [codelist,firstrecorddt] = gettickdatainfo(conn,list{i});
        for j = 1:size(codelist,1)
            savetickfrombloomberg(conn,codelist{j},...
                'fromdate',datestr(firstrecorddt(j),'yyyy-mm-dd'),...
                'todate',todate);
        end
    catch
    end
end
fprintf('done for saving tick data for agriculture futures\n\n');

%%
% industry
list = {'coke';'coking coal';'deformed bar';'iron ore';'hotroiled coil';'glass'};
for i = 1:size(list,1)
    [codelist,firstrecorddt] = gettickdatainfo(conn,list{i});
    for j = 1:size(codelist,1)
        savetickfrombloomberg(conn,codelist{j},...
            'fromdate',datestr(firstrecorddt(j),'yyyy-mm-dd'),...
            'todate',todate);
    end
end
fprintf('done for saving tick data for industry futures\n\n');

%%
%clear variables
clear i j
clear override conn list codelist

