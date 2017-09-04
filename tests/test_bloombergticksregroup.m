%test of function 'bloombergticksregroup'
%%
%1.initialize variables used for this test
fprintf('\nrunning test_bloombergticksregroup...\n');
c = bbgconnect;
contract = cContract('AssetName','gold','Tenor','1612');
fromDateTime = '2016-10-11 11:00:00';
toDateTime = '2016-10-11 11:30:00';
%%
%2.download data and call 'bloombergticksregroup' function
fields = 'trade';
fprintf('downloading trade tick data from Bloomberg...\n');
ticks = timeseries(c,contract.BloombergCode,{fromDateTime,toDateTime},[],fields);
data = bloombergticksregroup(ticks);
%sanity check
if size(data,1) ~= size(ticks,1)
    error('test_bloombergticksgroup:unknown error')
end
%
fields = {'bid','ask','trade'};
fprintf('downloading trade,bid and ask tick data from Bloomberg...\n');
ticks = timeseries(c,contract.BloombergCode,{fromDateTime,toDateTime},[],fields);
data = bloombergticksregroup(ticks);
%sanity check
if size(data,1) ~= sum(strcmpi('BID',ticks(:,1)))
    error('test_bloombergticksgroup:unknown error')
end
%
fields = {'bid','trade'};
fprintf('downloading bid and trade tick data from Bloomberg...\n');
ticks = timeseries(c,contract.BloombergCode,{fromDateTime,toDateTime},[],fields);
data = bloombergticksregroup(ticks);
%sanity check
if size(data,1) ~= sum(strcmpi('BID',ticks(:,1)))
    error('test_bloombergticksgroup:unknown error')
end
%
fields = {'ask','trade'};
fprintf('downloading ask and trade tick data from Bloomberg...\n');
ticks = timeseries(c,contract.BloombergCode,{fromDateTime,toDateTime},[],fields);
data = bloombergticksregroup(ticks);
%sanity check
if size(data,1) ~= sum(strcmpi('ask',ticks(:,1)))
    error('test_bloombergticksgroup:unknown error')
end
%
fields = {'bid','ask'};
fprintf('downloading bid and ask tick data from Bloomberg...\n');
ticks = timeseries(c,contract.BloombergCode,{fromDateTime,toDateTime},[],fields);
data = bloombergticksregroup(ticks);
%sanity check
if size(data,1) ~= sum(strcmpi('bid',ticks(:,1)))
    error('test_bloombergticksgroup:unknown error')
end




%%
%3.close connection
close(c);
fprintf('test bloombergticksregoup done!!!\n');
