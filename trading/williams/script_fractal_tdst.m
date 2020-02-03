%%
nfractal = 2;
outputmat = tools_technicalplot1(p,nfractal);
HH = outputmat(:,7);LL = outputmat(:,8);
jaw = outputmat(:,9);teeth = outputmat(:,10);lips = outputmat(:,11);
bs = outputmat(:,12);ss = outputmat(:,13);
lvlup = outputmat(:,14);lvldn = outputmat(:,15);
bc = outputmat(:,16);sc = outputmat(:,17);
%%
N = length(p);
% DAILY price with 5-day fractal, i.e. nfractal = 2
% valid HH: the highest high is above alligator's teeth
validHH = HH > teeth;
% valid LL: the lowest low is below alligator's teeth
validLL = LL < teeth;
%
% buy signal:the previous close was below a valid HH and the current close
% is above a valid HH
isBuy1 = [0;validHH(1:end-1) & p(1:end-1,5)<HH(1:end-1) & p(2:end,5)>HH(1:end-1) & HH(1:end-1)==HH(2:end)];
% also sell countdown = 13 shall be excluded
isBuy1 = isBuy1 & sc ~= 13;
% also to exclude sell setup >= 9 with the highest high
for i = 1:length(isBuy1)
    if isBuy1(i) == 0, continue;end
    if ss(i) >= 9 && p(i,3) >= max(p(i-ss(i)+1:i,3)) && p(i,5) > p(i-1,5)
        isBuy1(i) = 0;
    end
end
idxBuy1 = find(isBuy1==1);
nBuy1 = length(idxBuy1);
idxBuy1Stop = idxBuy1;
%
for i = 1:nBuy1
    j = idxBuy1(i);
    upper = HH(j-1);
    lower = LL(j);
    stoploss = upper - 0.382*(upper-lower);
    maxpnl = 0;
    for k = j+1:N
        %1.stop the trade if price breach stoploss
        if p(k,5) < stoploss
            idxBuy1Stop(i)=k;
            break
        end
        pnl = p(k,5)-p(j,5);
        if pnl > maxpnl, maxpnl = pnl;end
        %2.stop the trade if the pnl drawdown is greater than 0.382 of the
        %range
        if (maxpnl-pnl) > 0.382*(upper-lower)
            idxBuy1Stop(i)=k;
            break
        end
        %3.stop the trade if the pnl is greater than the range
        if pnl > upper-lower
            idxBuy1Stop(i)=k;
            break
        end
        %4.stop the trade if sell setup reaches 9 or higher values
        if ss(k) >= 9 && p(k,3) >= max(p(k-ss(k)+1:k,3)) && p(k,5) > p(k-1,5)
            idxBuy1Stop(i)=k;
            break
        end
        %5.stop the trade if it fails to breach tdst-lvlup
        %i.e.
        if p(k-1,5)>lvlup(k-1) && p(k,5)<lvlup(k-1) && p(k,3)>lvlup(k-1)
            idxBuy1Stop(i)=k;
            break
        end
        %6.stop the trade if sell countdown reaches 13
        if sc(k) == 13
            idxBuy1Stop(i)=k;
            break
        end
    end
    if k == N
        idxBuy1Stop(i) = N;
    end
end
%% more aggressive approach to buy
% 1. add buy countdown = 13 to isBuy
isBuy2 = bc == 13;
% 2. add any point with buy setup >= 9 with the lowest low (close lower
% than open)
for i = 1:length(isBuy2)
    if isBuy2(i) == 1, continue;end
    if bs(i) >= 9 && p(i,4) <= min(p(i-bs(i)+1:i,4)) && p(i,5) < p(i-1,5)...
            && p(i,5) < p(i,2)
        isBuy2(i) = 1;
    end
end
idxBuy2 = find(isBuy2==1);
nBuy2 = length(idxBuy2);
idxBuy2Stop = idxBuy2;
%
for i = 1:nBuy2
    j = idxBuy2(i);
    if bc(j) == 13
        lastbs9 = find(bs(1:j)==9,1,'last');
        lower = 0;
        barsize = 0;
        for k = lastbs9:j
            if isnan(bc(k)),continue;end
            if p(k,4)<lower,lower = p(k,4);end
            if p(k,3)-p(k,4)>barsize,barsize = p(k,3)-p(k,4);end
        end
        upper = lower + barsize;
    else
        lower = p(j,4);
        upper = max(p(j-bs(j)+1:j,3)-p(j-bs(j)+1:j,4))+lower;
    end
    stoploss = lower - 0.382*(upper-lower);
    maxpnl = 0;
    for k = j+1:N
        %1.stop the trade if price breach stoploss
        if p(k,5) < stoploss
            idxBuy2Stop(i) = k;
            break
        end
        pnl = p(k,5)-p(j,5);
        if pnl > maxpnl, maxpnl = pnl;end
        %2.stop the trade if the pnl drawdown is greater than 0.382 of the
        %range
        if (maxpnl - pnl) > 0.382*(upper-lower)
            idxBuy2Stop(i) = k;
            break
        end
        %3.stop the trade if the pnl is greater than the range
        if pnl > 0.618*(upper-lower)
            idxBuy2Stop(i) = k;
            break
        end
        %4.stop the trade if sell setup reaches 9 or higher values
        if ss(k) >= 9 && p(k,3) >= max(p(k-ss(k)+1:k,3)) && p(k,5) > p(k-1,5)
            idxBuy2Stop(i)=k;
            break
        end
        %5.stop the trade if it fails to breach tdst-lvlup
        %i.e.
        if p(k-1,5)>lvlup(k-1) && p(k,5)<lvlup(k-1) && p(k,3)>lvlup(k-1)
            idxBuy2Stop(i)=k;
            break
        end
        %6.stop the trade if sell countdown reaches 13
        if sc(k) == 13
            idxBuy2Stop(i)=k;
            break
        end
    end
    if k == N
        idxBuy2Stop(i) = N;
    end
end

%%
% sell signal:the previous close was above a valid LL and the current close
% is below a valid LL
isSell1 = [0;validLL(1:end-1) & p(1:end-1,5)>LL(1:end-1) & p(2:end,5)<LL(1:end-1)&LL(1:end-1)==LL(2:end)];
% also buy countdown = 13 shall be excluded
isSell1 = isSell1 & bc ~= 13;
% also to exclude buy setup >= 9 with the lowest low
for i = 1:length(isSell1)
    if isSell1(i) == 0, continue;end
    if bs(i) >= 9 && p(i,4) <= min(p(i-bs(i)+1:i,4)) && p(i,5) < p(i-1,5)
        isSell1(i) = 0;
    end
end
idxSell1 = find(isSell1==1);
nSell1 = length(idxSell1);
idxSell1Stop = idxSell1;
%
for i = 1:nSell1
    j = idxSell1(i);
    upper = HH(j);
    lower = LL(j-1);
    stoploss = lower + 0.382*(upper-lower);
    maxpnl = 0;
    for k = j+1:N
        %1.stop the trade if price breach stoploss
        if p(k,5) > stoploss
            idxSell1Stop(i) = k;
            break
        end
        pnl = p(j,5)-p(k,5);
        if pnl > maxpnl, maxpnl = pnl;end
        %2.stop the trade if the pn; drawdown is greater than 0.382 of the
        %range
        if (maxpnl-pnl) > 0.382*(upper-lower)
            idxSell1Stop(i) = k;
            break
        end
        %3.stop the trade if the pnl is greater than the range
        if pnl > upper-lower
            idxSell1Stop(i) = k;
            break
        end
        %4.stop the trade if buy setup reaches 9 or higher values
        if bs(k) >= 9 && p(k,4) <= min(p(k-bs(k)+1:k,4)) && p(k,5) < p(k-1,5)
            idxSell1Stop(i) = k;
            break
        end
        %5.stop the trade if it fails to breach tdst-lvldn
        if p(k-1,5)<lvldn(k-1) && p(k,5)>lvldn(k-1) && p(k,4)<lvldn(k-1)
            idxSell1Stop(i) = k;
            break
        end
        %6.stop the trade if buy countdown reaches 13
        if bc(k) == 13
            idxSell1Stop(i) = k;
            break
        end
    end
    if k == N
        idxSell1Stop(i) = N;
    end
end
%
%%
% more aggressive approach to SELL
% 1. add sell countdown = 13 to isSell
isSell2 = sc == 13;
% 2. add any point with sell setup >= 9 with the highest high (close higher
% than open)
for i = 1:length(isSell2)
    if isSell2(i) == 1, continue;end
    if ss(i) >= 9 && p(i,3) >= max(p(i-ss(i)+1:i,3)) && p(i,5) > p(i-1,5)...
            && p(i,5) > p(i,2)
        isSell2(i) = 1;
    end
end
idxSell2 = find(isSell2==1);
nSell2 = length(idxSell2);
idxSell2Stop = idxSell2;
%
for i = 1:nSell2
    j = idxSell2(i);
    if sc(j) == 13
        lastss9 = find(ss(1:j)==9,1,'last');
        upper = 0;
        barsize = 0;
        for k = lastss9:j
            if isnan(sc(k)), continue;end
            if p(k,3)>upper, upper = p(k,3);end
            if p(k,3)-p(k,4)>barsize,barsize = p(k,3)-p(k,4);end
        end
        lower = upper-barsize;
    else
        upper = p(j,3);
        lower = upper - max(p(j-ss(j)+1:j,3)-p(j-ss(j)+1:j,4));
    end
    stoploss = upper + 0.382*(upper-lower);
    maxpnl = 0;
    for k = j+1:N
        %1.stop the trade if price breach stoploss
        if p(k,5) > stoploss
            idxSell2Stop(i) = k;
            break
        end
        pnl = p(j,5)-p(k,5);
        if pnl > maxpnl, maxpnl = pnl;end
        %2.stop the trade if the pn; drawdown is greater than 0.382 of the
        %range
        if (maxpnl-pnl) > 0.382*(upper-lower)
            idxSell2Stop(i) = k;
            break
        end
        %3.stop the trade if the pnl is greater than the range
        if pnl > 0.618*(upper-lower)
            idxSell2Stop(i) = k;
            break
        end
        %4.stop the trade if buy setup reaches 9 or higher values
        if bs(k) >= 9 && p(k,4) <= min(p(k-bs(k)+1:k,4)) && p(k,5) < p(k-1,5)
            idxSell2Stop(i) = k;
            break
        end
        %5.stop the trade if it fails to breach tdst-lvldn
        if p(k-1,5)<lvldn(k-1) && p(k,5)>lvldn(k-1) && p(k,4)<lvldn(k-1)
            idxSell2Stop(i) = k;
            break
        end
        %6.stop the trade if buy countdown reaches 13
        if bc(k) == 13
            idxSell2Stop(i) = k;
            break
        end
    end
    if k == N
        idxSell2Stop(i) = N;
    end
end

%% todo
isBuy3 = [0;validLL(1:end-1) & p(1:end-1,5)<LL(1:end-1) & p(2:end,5)>LL(1:end-1)];
%
isSell3 = [0;validHH(1:end-1) & p(1:end-1,5)>HH(1:end-1) & p(2:end,5)<HH(1:end-1)];

%%
totalpnl = sum(p(idxBuy1Stop,5)-p(idxBuy1,5))+...
    sum(p(idxBuy2Stop,5)-p(idxBuy2,5))+...
    sum(p(idxSell1,5)-p(idxSell1Stop,5))+...
    sum(p(idxSell2,5)-p(idxSell2Stop,5));
%%
signals = zeros(N,1);
for i = 1:nBuy1
    jstart = idxBuy1(i);
    jend = idxBuy1Stop(i);
    signals(jstart:jend-1) = 1 + signals(jstart:jend-1);
end
for i = 1:nBuy2
    jstart = idxBuy2(i);
    jend = idxBuy2Stop(i);
    signals(jstart:jend-1) = 1 + signals(jstart:jend-1);
end
for i = 1:nSell1
    jstart = idxSell1(i);
    jend = idxSell1Stop(i);
    signals(jstart:jend-1) = -1 + signals(jstart:jend-1);
end
for i = 1:nSell2
    jstart = idxSell2(i);
    jend = idxSell2Stop(i);
    signals(jstart:jend-1) = -1 + signals(jstart:jend-1);
end
runningpnl = [0;signals(1:end-1).*(p(2:end,5)-p(1:end-1,5))];
figure(2);
plot(cumsum(runningpnl));grid on;hold on;
plot(p(1:end,5)-p(1,5),'r');hold off;
%
nWinBuy1 = sum(p(idxBuy1Stop,5)-p(idxBuy1,5)>0);
pnlWinBuy1 = (p(idxBuy1Stop,5)-p(idxBuy1,5)>0).*(p(idxBuy1Stop,5)-p(idxBuy1,5));
nWinBuy2 = sum(p(idxBuy2Stop,5)-p(idxBuy2,5)>0);
pnlWinBuy2 = (p(idxBuy2Stop,5)-p(idxBuy2,5)>0).*(p(idxBuy2Stop,5)-p(idxBuy2,5));
nWinSell1 = sum(p(idxSell1,5)-p(idxSell1Stop,5)>0);
pnlWinSell1 = (p(idxSell1,5)-p(idxSell1Stop,5)>0).*(p(idxSell1,5)-p(idxSell1Stop,5));
nWinSell2 = sum(p(idxSell2,5)-p(idxSell2Stop,5)>0);
pnlWinSell2 = (p(idxSell2,5)-p(idxSell2Stop,5)>0).*(p(idxSell2,5)-p(idxSell2Stop,5));
W = (nWinBuy1+nWinBuy2+nWinSell1+nWinSell2)/(nBuy1+nBuy2+nSell1+nSell2);
wintotalpnl = sum(pnlWinBuy1)+sum(pnlWinBuy2)+sum(pnlWinSell1)+sum(pnlWinSell2);
losstotalpnl = totalpnl-wintotalpnl;
winavgpnl = wintotalpnl/(nWinBuy1+nWinBuy2+nWinSell1+nWinSell2);
lossavgpnl = losstotalpnl/(nBuy1+nBuy2+nSell1+nSell2-(nWinBuy1+nWinBuy2+nWinSell1+nWinSell2));
R = abs(winavgpnl/lossavgpnl);
if W == 1
    ratio = 1;
    lossavgpnl = NaN;
else
    ratio = W-(1-W)/R;
end
fprintf('kelly ratio:%2.2f\n',ratio);

