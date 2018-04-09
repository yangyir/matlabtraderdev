%%
%set up bloomberg connection
conn = bbgconnect;
fprintf('set up bloomberg connection...\n');
%%
%name contracts, which are used for downloading time-series data
codes = {'ni1801';'ni1805'};
n = size(codes,1);
%list of futures contracts
futs = cell(n,1);
%list of open interest
oi = cell(n,1);
%the roll date is determined as the date on which the open interests of the
%second futures contract exceed the one of the first futures
rolldts = zeros(n-1,1);
for i = 1:n
    futs{i} = cFutures(codes{i});futs{i}.loadinfo([codes{i},'_info.txt']);
    oi{i,1} = conn.history(futs{i}.code_bbg,'open_int',futs{i}.first_trade_date1,futs{i}.last_trade_date1);
    if i > 1
        [t,idx1,idx2] = intersect(oi{i-1}(:,1),oi{i}(:,1));
        oi_diff = [t,oi{i-1}(idx1,2)-oi{i}(idx2,2)];
        temp = t((oi_diff(:,2)<0));
        rolldts(i-1) = temp(1);
    end
end
fprintf('find out rolling date...\n');
%%
%1m candle data
%we take next calendar day data before the roll date of the 2nd contract
candle_1m = cell(n,1);
for i = 1:n
    if i == 1
        startdt = [futs{i}.first_trade_date2,' 09:00:00'];
        enddt = [datestr(rolldts(i),'yyyy-mm-dd'),' 15:00:00'];
    else
        startdt = [datestr(rolldts(i-1)+1,'yyyy-mm-dd'),' 09:00:00'];
        if i == n
            enddt = [datestr(getlastbusinessdate,'yyyy-mm-dd'),' 15:00:00'];
        else
            endtdt = [datestr(rolldts(i),'yyyy-mm-dd'),' 15:00:00'];
        end
    end
    candle_1m{i} = conn.timeseries(futs{i}.code_bbg,{startdt,enddt},1,'trade');
    %clean up the data with its tradinghours and tradingbreaks 
    candle_1m{i} = timeseries_window(candle_1m{i},'tradinghours',futs{i}.trading_hours,...
        'tradingbreak',futs{i}.trading_break);
end
fprintf('1m candle data has been downloaded...\n');

%%
%compress the data into 5m and 15m interval
candle_5m = cell(n,1);
candle_15m = cell(n,1);
for i = 1:n
    candle_5m{i} = timeseries_compress([candle_1m{i}(:,1),candle_1m{i}(:,5)],'frequency','5m');
    candle_15m{i} = timeseries_compress([candle_1m{i}(:,1),candle_1m{i}(:,5)],'frequency','15m');
end
fprintf('1m candle data has been compressed into 5m and 15m interval...\n');

%%
res = cell(n,1);
nperiod = 144;
%test1 logic:
%moving calibration window = 144 of selected period of data
selectperiod = 15;
if selectperiod == 5
    data = candle_5m;
elseif selectperiod == 15 
    data = candle_15m;
else
    error('invalid frequency');
end
%
signals = cell(n,1);
pnl = cell(n,1);
%note:
for i = 1:n
    t = data{i}(:,1);
    hp = data{i}(:,3);
    lp = data{i}(:,4);
    cp = data{i}(:,5);
    m = size(t,1);
    signal = zeros(m,1);
    for j = nperiod+1:m
        upper = max(hp(j-nperiod:j-1));
        lower = min(hp(j-nperiod:j-1));
        if cp(j)>=upper
            signal(j) = -1;
        elseif cp(j) <= lower
            signal(j) = 1;
        else
            signal(j) = 0;
        end
    end
    signals{i} = signal;
end


% plot(hp(end-300:end),'r');hold on;
% plot(lp(end-300:end),'g');plot(cp(end-300:end),'b');hold off;










