sec = '510050 CH Equity';
conn = bbgconnect;
%% historical data
hd = conn.history(sec,'px_last','2016-07-07','2019-10-08');
%% 3m ewma vol
nperiod = 63;
classicalvol = historicalvol(hd,nperiod,'classical');classicalvol = [classicalvol(:,1),sqrt(252)*classicalvol(:,2)];
ewmavol = historicalvol(hd,nperiod,'ewma');ewmavol = [ewmavol(:,1),sqrt(252)*ewmavol(:,2)];
subplot(311);plot(hd(:,2));title('price');grid on;
subplot(312);plot(classicalvol(:,2),'r');title('classicvol');grid on;
subplot(313);plot(ewmavol(:,2),'r');title('ewmavol');grid on;
%% create straddles
N = size(hd,1);
straddles = bkcStraddleArray;
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
    straddle_i.valuation('Spots',hd,'Vols',ewmavol,'VolMethod','static');
    straddles.push(straddle_i);
    count = count + 1;
end
%% stats and plots without leverage
n = straddles.latest_;
finalrets = zeros(n,2);
limit = 1.5;
stop = 0.9;
dayscut = 42;
criterial = 'delta';
for i = 1:n
    straddle_i = straddles.node_(i);
    unwindidx = straddle_i.unwindinfo('limit',limit,'stop',stop,'dayscut',dayscut,'criterial',criterial);
    if strcmpi(criterial,'pv')
        finalrets(i,1) = straddle_i.pvs_(unwindidx)/straddle_i.pvs_(1);
    else
        temp = cumsum(straddle_i.deltapnl_);
        finalrets(i,1) = 1+temp(unwindidx)/straddle_i.pvs_(1);
    end
    finalrets(i,2) = unwindidx;
end
%
rate = 0.03;
nbdaysperyear = 252;
dailyfiret = rate/nbdaysperyear*ones(n,1);
dailyoptret = dailyfiret.*finalrets(:,1);
daysvec = [1:1:n];daysvec = daysvec';
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
leverage = 2;
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


















