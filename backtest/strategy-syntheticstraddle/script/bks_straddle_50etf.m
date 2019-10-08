sec = '510050 CH Equity';
conn = bbgconnect;
%% historical data
hd = conn.history(sec,'px_last','2016-07-07','2019-10-07');
%% 3m ewma vol
nperiod = 63;
classicalvol = historicalvol(hd,nperiod,'classical');classicalvol = [classicalvol(:,1),sqrt(252)*classicalvol(:,2)];
ewmavol = historicalvol(hd,nperiod,'ewma');ewmavol = [ewmavol(:,1),sqrt(252)*ewmavol(:,2)];
subplot(311);plot(hd(:,2));title('price');grid on;
subplot(312);plot(classicalvol(:,2),'r');title('classicvol');grid on;
subplot(313);plot(ewmavol(:,2),'r');title('ewmavol');grid on;
%% create straddles
N = size(hd,1);
straddles = cell(N-nperiod+1,1);
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
    straddles{count,1} = bkcStraddle('id',id,'code',sec,...
        'strike',strike,'opendt',opendt,'expirydt',expirydt);
    count = count + 1;
end
%% valuation
straddles{263}.valuation('Spots',hd,'Vols',classicalvol,'VolMethod','static');
straddles{263}.plot(hd);
%%
maxret = zeros(N-nperiod+1,1);
for i = 1:N-nperiod+1
%     straddles{i}.valuation('Spots',hd,'Vols',classicalvol,'VolMethod','static');
    output_i = straddles{i}.stats;
    maxret(i) = output_i.maxret;
end
%%
lower = -0.25;
upper = 0.5;
Ncut = 63-21;
finalret = zeros(N-nperiod+1,1);
for i = 1:N-nperiod+1
    pvs = straddles{i}.pvs_;
    rets = pvs/pvs(1)-1;
    idxlower = find(rets <= lower,1,'first');
    idxupper = find(rets >= upper,1,'first');
    if isempty(idxlower),idxlower = Ncut;end
    if isempty(idxupper),idxupper = Ncut;end
    idxstop = min(idxlower,idxupper);
    finalret(i) = rets(idxstop);
end