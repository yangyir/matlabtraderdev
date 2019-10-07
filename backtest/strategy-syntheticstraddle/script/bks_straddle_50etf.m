sec = '510050 CH Equity';
conn = bbgconnect;
%% historical data
hd = conn.history(sec,'px_last','2016-07-07','2019-10-07');
%% 3m ewma vol
nperiod = 63;
ewmavol = historicalvol(hd,nperiod,'ewma');
subplot(211);plot(hd(:,2));title('price');grid on;
subplot(212);plot(ewmavol(:,2),'r');title('ewmavol');grid on;
%% strategy
% synthetic long straddle:
rate = 0;
time = 0.25;
pv = hd;
for i = 1:size(pv,1)
    if isnan(ewmavol(i,2))
        pv(i,2) = NaN;
    else
        %options in relative terms
        pv(i,2) = 2*blkprice(1,1,rate,time-1/252,sqrt(252)*ewmavol(i,2));
    end
end
%% straddle value evolution
pvevolution = zeros(size(pv,1),nperiod);
for i = 1:size(pv,1)
    pvevolution(i,1) = pv(i,2);
    if isnan(pvevolution(i,1))
        pvevolution(i,2:nperiod) = NaN;
    else
        strike = hd(i,2);
        for j = 2:nperiod
            if i+j-1 > size(hd,1), continue;end
            [c,p] = blkprice(hd(i+j-1,2),strike,rate,time-j/252,sqrt(252)*ewmavol(i+j-1,2));
            pvevolution(i,j) = (c+p)/strike;
        end
    end
end
%%
pvholding = zeros(size(pvevolution));
netpv = zeros(size(pvevolution,1),1);
limit = 0.6;
stoploss = 0.5;
nholding = netpv;
for i = 1:size(pvevolution)
    if isnan(pvevolution(i,1))
        pvholding(i,:) = 0;
    else
        pvholding(i,1) = pvevolution(i,1);
        for j = 2:nperiod
            if pvevolution(i,j)/pvholding(i,1)-1 >= limit || ...
                    pvevolution(i,j)/pvholding(i,1)-1 <= -stoploss
                pvholding(i,j) = pvevolution(i,j);
                pvholding(i,j+1:end) = 0;
                nholding(i) = j;
                break
            else
                pvholding(i,j) = pvevolution(i,j);
                nholding(i) = j;
            end
        end
    end
end
%
notional = 1;
for i = 1:size(pvholding,1)
    if i <= nperiod
        netpv(i) = 0;
    else
        pv_i = 0;
        for j = nperiod:i-1
            if i-j+1>nperiod,continue;end
            pv_i = pv_i + pvholding(j,i-j+1);
        end
        netpv(i) = pv_i;
    end
    
end
plot(netpv);
%%
ret = netpv;
for i = 1:size(pvevolution)
    if isnan(pvevolution(i,1))
        ret(i) = 0;
    else
        ret(i) = pvevolution(i,nholding(i))/pvevolution(i,1);
    end
end
%%
i = 100;
subplot(211);plot(pvevolution(i,:));
subplot(212);plot(hd(i:i+nperiod-1,2));