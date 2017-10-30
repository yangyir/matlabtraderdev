database = cBloomberg;
%%
code = 'ni1801';

leg1 = cFutures(code);
leg1.loadinfo([code,'_info.txt']);

%%
freq_ = 3;

if freq_ == 1 || freq_ == 3
    days_ = 15;
elseif freq_ == 5
    days_ = 30;
elseif freq_ == 15
    days_ = 30;
end

dend = getlastbusinessdate;
count = 0;
dstart = dend;
while count < days_
    count = count+1;
    dstart = businessdate(dstart,-1);
end

dstartstr = [datestr(dstart,'yyyy-mm-dd'),' 09:00:00'];
dendstr = [datestr(dend,'yyyy-mm-dd'),' 15:15:00'];

data = database.intradaybar(leg1,dstartstr,dendstr,freq_,'trade');

%%
openp = data(:,2);
highp = data(:,3);
lowp = data(:,4);
closep = data(:,5);
nperiods = 144;
wr = willpctr(highp,lowp,closep,nperiods);

%%
% % close all;
% mat = [wr(nperiods:end-1),closep(nperiods+1:end)-closep(nperiods:end-1)];
% matsorted = sortrows(mat);
% figure(1)
% subplot(211),candle(highp(nperiods:end),lowp(nperiods:end),closep(nperiods:end),openp(nperiods:end));grid on;
% subplot(212),plot(mat(:,1));grid on;

%%
% backtest
baseunit = 1;
maxunit = 64;
minunit = -64;
multiplier = leg1.contract_size;
marginratio = 0.1;
profitstop_rel = 0.1;
lossstop_rel = 0.1;

profitstop_abs = 1e5;
lossstop_abs = -2e5;


px = closep(nperiods:end);
indicators = wr(nperiods:end-1);
n = size(indicators,1);
holdings = zeros(n,1);
for i = 1:n
    if i == 1
        if indicators(i) == -100
            holdings(i) = baseunit;
            cost = px(i);
            margin = cost*marginratio;
        elseif indicators(i) == 0
            holdings(i) = -baseunit;
            cost = px(i);
            margin = cost*marginratio;
        end
    else
         if holdings(i-1) > 0
             pnl = holdings(i-1)*(px(i)-cost)*multiplier;
             if pnl > profitstop_rel * margin || pnl < -lossstop_rel * margin || pnl > profitstop_abs || pnl < lossstop_abs
                 holdings(i) = 0;
             else
                 if indicators(i) == -100
                    holdings(i) = min(2*holdings(i-1),maxunit);
                    if holdings(i) ~= holdings(i-1)
                        delta = holdings(i)-holdings(i-1);
                        cost = (holdings(i-1)*cost+delta*px(i))/holdings(i);
                        margin = cost*abs(holdings(i))*marginratio;
                    end
                 else
                     holdings(i) = holdings(i-1);
                 end
             end
         elseif holdings(i-1) < 0
             pnl = holdings(i-1)*(px(i)-cost)*multiplier;
             if pnl > profitstop_rel * margin || pnl < -lossstop_rel * margin || pnl > profitstop_abs || pnl < lossstop_abs
                 holdings(i) = 0;
             else
                 if indicators(i) == 0
                     holdings(i) = max(2*holdings(i-1),minunit);
                     if holdings(i) ~= holdings(i-1)
                         delta = holdings(i)-holdings(i-1);
                         cost = (holdings(i-1)*cost+delta*px(i))/holdings(i);
                         margin = cost*abs(holdings(i))*marginratio;
                     end
                 else
                    holdings(i) = holdings(i-1);
                 end
             end
         else
             if indicators(i) == -100
                 holdings(i) = baseunit;
                 cost = px(i);
                 margin = cost*marginratio;
             elseif indicators(i) == 0
                 holdings(i) = -baseunit;
                 cost = px(i);
                 margin = cost*marginratio;
             end
         end
    end
end

pnl = holdings.*(closep(nperiods+1:end)-closep(nperiods:end-1));
sum(pnl)
figure(3)
subplot(411),plot(closep(nperiods:end));title(['time series price (',num2str(freq_),'m)']);grid on;
subplot(412),plot(indicators);title('indicator');grid on;
subplot(413),stairs(holdings);title('holdings');grid on;
subplot(414),plot(cumsum(pnl));title('cumulative pnl');grid on;

        
