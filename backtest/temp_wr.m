conn = bbgconnect;

%%
code = 'rb1801';
fut = cFutures(code);fut.loadinfo([code,'_info.txt']);

time_freq = 5;
start_dt = '2017-08-07';
end_dt = '2017-11-08';

%%
data = timeseries(conn,fut.code_bbg,{start_dt,end_dt},time_freq,'trade');
%%
data = timeseries_window(data(:,1:5),'tradinghours',fut.trading_hours,'tradingbreak',fut.trading_break);
%%
nperiods = 144;
wr_buy = -100;
wr_sell = -0;
high_p = data(:,3);
low_p = data(:,4);
close_p = data(:,5);

wr_matlab = willpctr(high_p,low_p,close_p,nperiods);

%%
indicators = NaN*wr_matlab;
for i = nperiods+1:size(wr_matlab)
    if wr_matlab(i) == wr_buy
        indicators(i) = 1;
    elseif wr_matlab(i) == wr_sell
        indicators(i) = -1;
    end
end

%%
%optimize the solution
%note:







