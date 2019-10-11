sec = '510050 CH Equity';
%% historical data from  bloomberg
% conn = bbgconnect;
% hd = conn.history(sec,'px_last','2016-07-07','2019-10-11');
% cDataFileIO.saveDataToTxtFile([getenv('DATAPATH'),'50etf_daily.txt'],hd,{'date';'close'},'w',false);
%% load historical data if bbg is not installed
path = getenv('DATAPATH');
fn = [path,'50etf_daily.txt'];
hd = cDataFileIO.loadDataFromTxtFile(fn);
%% 3m ewma vol
nperiod = 63;
classicalvol = historicalvol(hd,nperiod,'classical');classicalvol = [classicalvol(:,1),sqrt(252)*classicalvol(:,2)];
ewmavol = historicalvol(hd,nperiod,'ewma');ewmavol = [ewmavol(:,1),sqrt(252)*ewmavol(:,2)];
subplot(311);plot(hd(:,2));title('price');grid on;
subplot(312);plot(classicalvol(:,2),'r');title('classicvol');grid on;
subplot(313);plot(ewmavol(:,2),'r');title('ewmavol');grid on;
%% create straddles
N = size(hd,1);
straddles = bkcVanillaArray;
count = 1;
for i = nperiod:N
    id = count;
    strike = hd(i,2);
    opendt = hd(i,1);
    try
        expirydt = hd(i+nperiod-1,1);
    catch
        expirydt = dateadd(opendt,[num2str(nperiod),'b']);
    end
    straddle_i = bkcStraddle('id',id,'code',sec,...
        'strike',strike,'opendt',opendt,'expirydt',expirydt);
    straddle_i.valuation('Spots',hd,'Vols',ewmavol,'VolMethod','dynamic');
    straddles.push(straddle_i);
    count = count + 1;
end
%% stats and plots without leverage
limit = 1.5;
stop = 0.9;
dayscut = 30;
criterial = 'delta';
finalrets = straddles.unwindinfo('limit',limit,'stop',stop,'dayscut',dayscut,'criterial',criterial);

%%
n = straddles.latest_;
rate = 0.03;
nbdaysperyear = 252;
dailyfiret = rate/nbdaysperyear*ones(n,1);
dailyoptret = dailyfiret.*finalrets(:,1);
daysvec = 1:1:n;daysvec = daysvec';
figure(2);
subplot(221);plot(cumsum(dailyfiret),'b');hold on;
plot(cumsum(dailyoptret),'r');hold off;legend('fixed income','straddle','location','northwest');
title('cumulative payoff over business days');
subplot(222);
plot(cumsum(dailyfiret)./daysvec*nbdaysperyear,'b');hold on;
plot(cumsum(dailyoptret)./daysvec*nbdaysperyear,'r');hold off;legend('fixed income','straddle','location','northeast');
title('cumulative return over business days')
%
cutoffperiodret = zeros(n-dayscut+1,2);
for i = 1:n-dayscut+1
    cutoffperiodret(i,1) = sum(dailyfiret(i:i+dayscut-1))*nbdaysperyear/dayscut;
    cutoffperiodret(i,2) = sum(dailyoptret(i:i+dayscut-1))*nbdaysperyear/dayscut;
end

subplot(223);plot(cutoffperiodret(:,1),'b');hold on;
plot(cutoffperiodret(:,2),'r');hold off;legend('fixed income','straddle','location','northwest');
title('cutoff period return over business days')
%
annualret = zeros(n-nbdaysperyear+1,2);
for i = 1:n-nbdaysperyear+1
    annualret(i,1) = sum(dailyfiret(i:i+nbdaysperyear-1));
    annualret(i,2) = sum(dailyoptret(i:i+nbdaysperyear-1));
end
subplot(224);plot(annualret(:,1),'b');hold on;
plot(annualret(:,2),'r');hold off;legend('fixed income','straddle','location','northwest');
title('annual return over business days')
%% with leverage
leverage = 1.2;
dailyfiret2 = rate/nbdaysperyear*ones(n,1)*leverage;
dailyoptret_leveraged = dailyfiret2.*finalrets(:,1);
figure(3);
subplot(221);plot(cumsum(dailyfiret),'b');hold on;
plot(cumsum(dailyoptret_leveraged),'r');hold off;legend('fixed income','straddle-leveraged','location','northwest');
title('cumulative payoff over business days');
subplot(222);
plot(cumsum(dailyfiret)./daysvec*nbdaysperyear,'b');hold on;
plot(cumsum(dailyoptret_leveraged)./daysvec*nbdaysperyear,'r');hold off;legend('fixed income','straddle-leveraged','location','northeast');
title('cumulative return over business days')

cutoffperiodret_levraged = zeros(n-dayscut+1,2);
for i = 1:n-dayscut+1
    cutoffperiodret_levraged(i,1) = sum(dailyfiret(i:i+dayscut-1))*nbdaysperyear/dayscut;
    cutoffperiodret_levraged(i,2) = sum(dailyoptret_leveraged(i:i+dayscut-1))*nbdaysperyear/dayscut;
end

subplot(223);plot(cutoffperiodret_levraged(:,1),'b');hold on;
plot(cutoffperiodret_levraged(:,2),'r');hold off;legend('fixed income','straddle-leveraged','location','northwest');
title('cutoff period return over business days')
subplot(224)
annualret_leveraged = zeros(n-nbdaysperyear+1,1);
for i = 1:n-nbdaysperyear+1
    annualret_leveraged(i,1) = sum(dailyfiret(i:i+nbdaysperyear-1));
    annualret_leveraged(i,2) = sum(dailyoptret_leveraged(i:i+nbdaysperyear-1));
end
subplot(224);plot(annualret_leveraged(:,1),'b');hold on;
plot(annualret_leveraged(:,2),'r');hold off;legend('fixed income','straddle-leveraged');
title('annual return over business days')

%%
premiumused =zeros(n,1);
for i = 1:n
    premiumused(i) = straddles.premiumused(straddles.node_(i).opendt1_,'limit',limit,'stop',stop,'dayscut',dayscut);
end
%%
pvs = zeros(n,1);
for i = 1:n
    pvs(i) = straddles.node_(i).pvs_(1);
end
%% with make sense leverage and running step by step
fundavailable = 1-1/(1+rate);
pr = 1/6;
premium0 = fundavailable*pr/dayscut;
cash = zeros(n,1);
pvholding = zeros(n,1);
fundused = zeros(n,1);
proceeds = zeros(n,1);
nlive = zeros(n,1);
premium = zeros(n,1);
dts = zeros(n,1);
closedts = zeros(n,1);
for i = 1:n, dts(i) = straddles.node_(i).opendt1_;end
for i = 1:n, closedts(i) = straddles.node_(i).tradedts_(finalrets(i,2));end

for i = 1:n
    dt_i = dts(i);
    if i == 1
        premium(i) = premium0;
    else
        if proceeds(i-1) == 0
            premium(i) = premium0;
        else
            %update premium if we have option unwinded
            residual = fundavailable*pr - fundused(i-1) + proceeds(i-1);
            premium0 = max(residual/(dayscut-nlive(i-1)),0);
            premium(i) = premium0;
        end
    end
    for j = 1:i
        if dt_i >=  dts(j) && dt_i < closedts(j)
            %live
            fundused(i) = fundused(i) + premium(j);
            idx_j = find(straddles.node_(j).tradedts_ == dt_i,1,'first');
            pvholding(i) = pvholding(i) + premium(j)*straddles.node_(j).pvs_(idx_j)/straddles.node_(j).pvs_(1);
            nlive(i) = nlive(i)+1;
        elseif dt_i >= dts(j) && dt_i == closedts(j)
            %live or closed
            proceeds(i) = proceeds(i) + premium(j)*(finalrets(j,1)-1);
        end
    end
    cash(i) = fundavailable - fundused(i) + proceeds(i);
end

dailyoptret_leveraged2 = premium.*finalrets(:,1);
figure(4);
subplot(221);plot(cumsum(dailyfiret),'b');hold on;
plot(cumsum(dailyoptret_leveraged2),'r');hold off;legend('fixed income','straddle-leveraged','location','northwest');
title('cumulative payoff over business days');
subplot(222);
plot(cumsum(dailyfiret)./daysvec*nbdaysperyear,'b');hold on;
plot(cumsum(dailyoptret_leveraged2)./daysvec*nbdaysperyear,'r');hold off;legend('fixed income','straddle-leveraged','location','northeast');
title('cumulative return over business days')

cutoffperiodret_levraged2 = zeros(n-dayscut+1,2);
for i = 1:n-dayscut+1
    cutoffperiodret_levraged2(i,1) = sum(dailyfiret(i:i+dayscut-1))*nbdaysperyear/dayscut;
    cutoffperiodret_levraged2(i,2) = sum(dailyoptret_leveraged2(i:i+dayscut-1))*nbdaysperyear/dayscut;
end

subplot(223);plot(cutoffperiodret_levraged2(:,1),'b');hold on;
plot(cutoffperiodret_levraged2(:,2),'r');hold off;legend('fixed income','straddle-leveraged','location','northwest');
title('cutoff period return over business days')
subplot(224)
annualret_leveraged2 = zeros(n-nbdaysperyear+1,1);
for i = 1:n-nbdaysperyear+1
    annualret_leveraged2(i,1) = sum(dailyfiret(i:i+nbdaysperyear-1));
    annualret_leveraged2(i,2) = sum(dailyoptret_leveraged2(i:i+nbdaysperyear-1));
end
subplot(224);plot(annualret_leveraged2(:,1),'b');hold on;
plot(annualret_leveraged2(:,2),'r');hold off;legend('fixed income','straddle-leveraged');
title('annual return over business days')

%% calculate running premium with a special start date
notional = 1;
rate = 0.03;
fundavailable = notional-notional/(1+rate);
pr = 1/3;
premium0 = fundavailable*pr/dayscut;
istart = 413;
iend = istart+252-1;
cash = zeros(252,1);
pvholding = zeros(252,1);
fundused = zeros(252,1);
proceeds = zeros(252,1);
nlive = zeros(252,1);
%premium paid for each straddle
premium = zeros(252,1);
for i = istart:iend
    dt_i = dts(i);
    if i == istart
        premium(i-istart+1) = premium0;
    else
        if proceeds(i-istart) == 0
            premium(i-istart+1) = premium0;
        else
            residual = fundavailable*pr - fundused(i-istart) + proceeds(i-istart);
            premium0 = max(residual/(dayscut-nlive(i-istart)),0);
            premium(i-istart+1) = premium0;
        end
    end
    for j = istart:i
        if dt_i >=  dts(j) && dt_i < closedts(j)
            %live
            fundused(i-istart+1) = fundused(i-istart+1) + premium(j-istart+1);
            idx_j = find(straddles.node_(j).tradedts_ == dt_i,1,'first');
            pvholding(i-istart+1) = pvholding(i-istart+1) + premium(j-istart+1)*straddles.node_(j).pvs_(idx_j)/straddles.node_(j).pvs_(1);
            nlive(i-istart+1) = nlive(i-istart+1)+1;
        elseif dt_i >= dts(j) && dt_i == closedts(j)
            %live or closed
            proceeds(i-istart+1) = proceeds(i-istart+1) + premium(j-istart+1)*(finalrets(j,1)-1);
        end
    end
    cash(i-istart+1) = fundavailable - fundused(i-istart+1) + proceeds(i-istart+1);
end

%%
ret = hd(2:end,2)./hd(1:end-1,2)-1;
variance = ret.^2;
sigmavar = sqrt(quantile(variance,0.95));
marginrate = 0.1;
initialmargin = dayscut*0.6*marginrate;
pr = 1-sigmavar/marginrate;

[marginaccountvalue,marginused,deltacarry] = straddles.runningpvsynthetic('InitialMargin',initialmargin,...
    'marginrate',marginrate,'participaterate',pr);

figure(3);
subplot(211);
plot(marginused,'r');grid on;title('margin over time');
hold on;plot(marginaccountvalue,'b');hold off;legend('marginused','pvholding');
subplot(212);plot(deltacarry);title('delta over time');grid on;












