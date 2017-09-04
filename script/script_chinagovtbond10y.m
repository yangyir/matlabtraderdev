%%
%download market data from bloomberg server
t1509 = cContract('assetname','govtbond_10y','tenor','1509');
t1512 = cContract('assetname','govtbond_10y','tenor','1512');
t1603 = cContract('assetname','govtbond_10y','tenor','1603');
t1606 = cContract('assetname','govtbond_10y','tenor','1606');
t1609 = cContract('assetname','govtbond_10y','tenor','1609');
t1612 = cContract('assetname','govtbond_10y','tenor','1612');
t1703 = cContract('assetname','govtbond_10y','tenor','1703');
t1706 = cContract('assetname','govtbond_10y','tenor','1706');

futures = {t1509;t1512;t1603;t1606;t1609;t1612;t1703;t1706};
nFutures = size(futures,1);

for i = 1:nFutures
    timeseries_update(futures{i},'TickUpdateFlag',false);
end

tsdaily = cell(nFutures,2);
tsintraday = cell(nFutures,2);
for i = 1:nFutures
    tsdaily{i,1} = futures{i}.BloombergCode;
    tsdaily{i,2} = futures{i}.getTimeSeries('connection','bloomberg',...
        'frequency','1d');
    %
    tsintraday{i,1} = futures{i}.BloombergCode;
    tsintraday{i,2} = futures{i}.getTimeSeries('connection','bloomberg',...
        'frequency','1m'); 
end

%%
%check with bloomberg for the roll dates
dateStart = tsdaily{1,2}(1,1);
dateEnd = tsdaily{nFutures,2}(end,1);