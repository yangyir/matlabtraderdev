%%
%script to test cContract object and functions associated to it
%
clc;
close all;
fprintf('\nrunning test_cContract.m......\n');
%%
%1.create a contract object
%contract is 'au1612' which is the gold futures expiring in Dec16 and
%traded in shanghai futures exchange
au1612 = cContract('AssetName','gold','Tenor','1612');
fprintf('now display properties of the contract...\n');
fprintf(['contract underlying: ',au1612.AssetName,'\n']);
fprintf(['contract expiry: ',datestr(x2mdate(au1612.Expiry)),'\n']);
fprintf(['contract size: ',num2str(au1612.ContractSize),'\n']);
fprintf(['contract tick size: ',num2str(au1612.TickSize),'\n']);
fprintf(['contract trading hours: ',au1612.TradingHours,'\n']);
fprintf(['contract bloomberg code: ',au1612.BloombergCode,'\n']);
fprintf(['contract wind code: ',au1612.WindCode,'\n']);
%%
%2.init timeseries to the contract object
%the timeseries object is first created via downloading data from the
%server and then data is dumped onto the local drive for loading purposes
%this guarantees the loading process much quicker
fprintf('now initiate contract with its timeseries......\n');
tsobjs = au1612.initTimeSeries('DataSource','internet','UpdateLocalFile','no');
n = size(tsobjs,1)*size(tsobjs,2);
if n ~= 6
    error('internal error');
end
fprintf(['the last business date is ',datestr(businessdate(today,-1)),'\n']);
for j = 1:size(tsobjs,2)
    if j == 1
        fprintf('Bloomberg source:\n');
    else
        fprintf('Wind source:\n');
    end
    for i = 1:size(tsobjs,1)
        fprintf(['\tthe last date entry is ',tsobjs{i,j}.getLastDateEntry,'\n']);
    end
end

%NOTE:the default value of UpdateLocalFile is yes
fprintf('now initiate timeseries again respectively...\n');
fprintf('and save timeseries object to locally...\n');
fprintf('Bloomberg source:\n');
tsobjs = au1612.initTimeSeries('Frequency','1d','DataSource','internet','Connection','Bloomberg');
fprintf(['\tthe last date entry is ',tsobjs{1}.getLastDateEntry,'\n']);
tsobjs = au1612.initTimeSeries('Frequency','1m','DataSource','internet','Connection','Bloomberg');
fprintf(['\tthe last date entry is ',tsobjs{1}.getLastDateEntry,'\n']);
tsobjs = au1612.initTimeSeries('Frequency','tick','DataSource','internet','Connection','Bloomberg');
fprintf(['\tthe last date entry is ',tsobjs{1}.getLastDateEntry,'\n']);
tsdatabbg = tsobjs{1}.getTimeSeries;
timeseries_plot(tsdatabbg(:,1:2),'DateFormat','HH:MM','title','tick data from Bloomberg');
fprintf('Wind source:\n');
tsobjs = au1612.initTimeSeries('Frequency','1d','DataSource','internet','Connection','Wind');
fprintf(['\tthe last date entry is ',tsobjs{1}.getLastDateEntry,'\n']);
tsobjs = au1612.initTimeSeries('Frequency','1m','DataSource','internet','Connection','Wind');                            
fprintf(['\tthe last date entry is ',tsobjs{1}.getLastDateEntry,'\n']);
tsobjs = au1612.initTimeSeries('Frequency','tick','DataSource','internet','Connection','Wind');
fprintf(['\tthe last date entry is ',tsobjs{1}.getLastDateEntry,'\n']);
tsdatawind = tsobjs{1}.getTimeSeries;
timeseries_plot(tsdatawind(:,1:2),'DateFormat','HH:MM','title','tick data from Wind');
%
%call initTimeSeries function with 2 specified freqs
tsobjs = au1612.initTimeSeries('Frequency',{'1d','1m'});
n = size(tsobjs,1)*size(tsobjs,2);
if n ~= 4
    error('interval error');
end
%

%%
%3.code to test all updateTimeSeries function with input parameters
%check with info locally
fprintf('\nnow check updateTimeSeries function...\n');
fprintf('before update:\n');
tsobjsOld = au1612.listTimeSeriesObjs;
for j = 1:size(tsobjsOld,2)
    if j == 1
        fprintf('Bloomberg source:\n');
    else
        fprintf('Wind source:\n');
    end
    for i = 1:size(tsobjsOld,1)
        fprintf(['\tperiod is between ',tsobjsOld{i,j}.getFirstDateEntry,'and ',...
            tsobjsOld{i,j}.getLastDateEntry,'\n']);
    end
end

fprintf('\nnow update timeseries of ag1612 contract...\n');
fprintf('\first update all timeseries...\n');
tsobjsNew = au1612.updateTimeSeries('UpdateLocalFile','No');
fprintf('\tupdate Bloomberg daily...\n');
tsobjBBGDailyNew = au1612.updateTimeSeries('UpdateLocalFile','No','Connection','Bloomberg','Frequency','1d');
fprintf('\tupdate Bloomberg intraday...\n');
tsobjBBGIntradayNew = au1612.updateTimeSeries('UpdateLocalFile','No','Connection','Bloomberg','Frequency','1m');
fprintf('\tupdate Bloomberg tick...\n');
tsobjBBGTickNew = au1612.updateTimeSeries('UpdateLocalFile','No','Connection','Bloomberg','Frequency','tick');
%
fprintf('\tupdate Wind daily...\n');
tsobjWindDailyNew = au1612.updateTimeSeries('UpdateLocalFile','No','Connection','Wind','Frequency','1d');
fprintf('\tupdate Wind intraday...\n');
tsobjWindIntradayNew = au1612.updateTimeSeries('UpdateLocalFile','No','Connection','Wind','Frequency','1m');
fprintf('\tupdate Wind tick...\n');
tsobjWindTickNew = au1612.updateTimeSeries('UpdateLocalFile','No','Connection','Wind','Frequency','tick');
fprintf('after update:\n');
for j = 1:size(tsobjsNew,2)
    if j == 1
        fprintf('Bloomberg source:\n');
    else
        fprintf('Wind source:\n');
    end
    for i = 1:size(tsobjsNew,1)
        fprintf(['\tperiod is between ',tsobjsNew{i,j}.getFirstDateEntry,'and ',...
            tsobjsNew{i,j}.getLastDateEntry,'\n']);
    end
end


%
fprintf('test done!\n');