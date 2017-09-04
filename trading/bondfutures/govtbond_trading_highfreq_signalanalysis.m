activeContract = rollinfo10y.Contracts{end};
tenor = activeContract.Tenor;

flag = false;
for i = 1:size(yldspdIntraday)
    if isempty(yldspdIntraday{i})
        continue
    end
    
    if strcmpi(tenor,yldspdIntraday{i}.Tenor)
        flag = true;
        break
    end
end

if ~flag
    return
end

dMat = yldspdIntraday{i}.Data;
days = unique(floor(dMat(:,1)));
ndays = size(days,1);
dCell = cell(ndays,1);
for i = 1:ndays
    dCell{i} = timeseries_window(dMat,...
        'FromDate',[datestr(days(i)),' 09:15:00'],...
        'ToDate',[datestr(days(i)),' 15:15:00']);
end
%%
close all;
i = ndays;
%note:
%column order datetime,px5y,px10y,yld5y,yld10y,yldspd
dt = days(i);
idx = find(yldspdEOD.Data(:,1) == dt);
yldspdYstClose = yldspdEOD.Data(idx-1,6);
d = dCell{i};
%try to sample with different frequency
freq = '15m';


%
yldspdchg = d(:,6)-yldspdYstClose;
mat = [yldspdchg(1:end-1),yldspdchg(2:end)-yldspdchg(1:end-1)];
matsorted = sortrows(mat);
subplot(2,2,1)
plot(matsorted(:,1),cumsum(matsorted(:,2)),'b');grid on;
xlabel('indicator','fontsize',8);ylabel('cumulative performance in bps','fontsize',8);
title(datestr(dt),'fontsize',8);
%
%

%%
%
%USER INPUTS:
signalLower = -0.2;
signalUpper = -0.4;
subplot(2,2,2)
plot(yldspdchg,'b');grid on;
ylabel('yld slope','fontsize',8);xlabel('time point intraday','fontsize',8);
title(datestr(dt),'fontsize',8);
hold on;
plot(0:1:300,signalLower*ones(301,1),'r')
plot(0:1:300,signalUpper*ones(301,1),'r')
hold off;
%
%
dirFlag = zeros(size(d,1)-1,1);
for j = 1:size(yldspdchg,1);
    if d(j,6)-yldspdYstClose<=signalLower
        dirFlag(j)=1;
    elseif d(j,6)-yldspdYstClose>=signalUpper
        dirFlag(j)=-1;
    else
        dirFlag(j)=0;
    end
end
pnl = dirFlag(1:end-1).*(d(2:end,6)-d(1:end-1,6));
subplot(2,2,3)
plot(cumsum(pnl),'b');grid on;
xlabel('time point intraday','fontsize',8);ylabel('cumulative pnl in bps','fontsize',8);
title(datestr(dt),'fontsize',8);
%
%
trades = [abs(dirFlag(1));dirFlag(2:end,1)-dirFlag(1:end-1,1)];
subplot(2,2,4)
plot(trades,'b');
xlabel('time point intraday','fontsize',8);ylabel('trades','fontsize',8);
title(datestr(dt),'fontsize',8);

    


