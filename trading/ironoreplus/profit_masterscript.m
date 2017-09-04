%
weights = [1;-1.6;-0.41];
assets = {'deformed bar';'iron ore';'coke'};
nAssets = 3;
rollinfo = cell(nAssets,1);
for i = 1:nAssets;
    rollinfo{i,1} = rollfutures(assets{i},'ForecastPeriod',500);
end
%
%create a matrix with the same t vector
%price matrix
[t,idx1,idx2] = intersect(rollinfo{1}.ContinousFutures(:,1),rollinfo{2}.ContinousFutures(:,1));
pxMatrix = [t,rollinfo{1}.ContinousFutures(idx1,2),rollinfo{2}.ContinousFutures(idx2,2)];
[t,idx1,idx2] = intersect(pxMatrix(:,1),rollinfo{3}.ContinousFutures(:,1));
pxMatrix = [t,pxMatrix(idx1,2:end),rollinfo{3}.ContinousFutures(idx2,2)];
%
%return matrix
[t,idx1,idx2] = intersect(rollinfo{1}.DailyReturn(:,1),rollinfo{2}.DailyReturn(:,1));
retMatrix = [t,rollinfo{1}.DailyReturn(idx1,2),rollinfo{2}.DailyReturn(idx2,2)];
[t,idx1,idx2] = intersect(retMatrix(:,1),rollinfo{3}.DailyReturn(:,1));
retMatrix = [t,retMatrix(idx1,2:end),rollinfo{3}.DailyReturn(idx2,2)];
%
%pop up the profit index
tStart = pxMatrix(1,1);
profitIndex = pxMatrix(:,1:2);profitIndex(:,end)=1;
a1 = pxMatrix(1,2);
a2 = pxMatrix(1,3);
a3 = pxMatrix(1,4);
profitIndex(1,2) = weights(1)*a1+weights(2)*a2+weights(3)*a3;
for i = 2:size(profitIndex,1)
    profitIndex(i,2) = profitIndex(i-1,2)+weights(1)*(a1*exp(retMatrix(i-1,2))-a1)+...
        weights(2)*(a2*exp(retMatrix(i-1,3))-a2)+...
        weights(3)*(a3*exp(retMatrix(i-1,3))-a3);
    a1 = pxMatrix(i,2);
    a2 = pxMatrix(i,3);
    a3 = pxMatrix(i,4);
end
profitIndex(:,2) = profitIndex(:,2)./profitIndex(1,2);
%
%
%%
%time series model calibration and vol forecasting
profitIndexRet = profitIndex(2:end,2)./profitIndex(1:end-1,2)-1;
subplot(2,2,1);autocorr(profitIndexRet,63);
subplot(2,2,2);parcorr(profitIndexRet,63);
subplot(2,2,3);autocorr(profitIndexRet.^2,63);
subplot(2,2,4);autocorr(profitIndexRet.^2,63);

%%
mdl = arima('ARLags',1,'MALags',1,'SARLags',1,'SMALags',1,'Variance',garch(1,1));
mdlEst = estimate(mdl,profitIndexRet);
% fitdistOutput = allfitdist(profitIndexRet,'pdf');
[E0,V0] = infer(mdlEst,profitIndexRet);
nForecastPeriod = 504;
[Y,YMSE,V] = forecast(mdlEst,nForecastPeriod,'Y0',profitIndexRet,'E0',E0,'V0',V0);
N = size(E0,1);
figure
subplot(2,1,1)
plot(E0,'Color',[.75,.75,.75])
hold on
upper = Y+1.96*sqrt(YMSE);
lower = Y-1.96*sqrt(YMSE);
plot(N+1:N+nForecastPeriod,Y,'r','LineWidth',2)
plot(N+1:N+nForecastPeriod,[upper,lower],'k--','LineWidth',1.5)
xlim([0,N+nForecastPeriod])
title('Forecasted Returns of steel factor profit index')
hold off
subplot(2,1,2)
plot(V0,'Color',[.75,.75,.75])
hold on
plot(N+1:N+nForecastPeriod,V,'r','LineWidth',2);
xlim([0,N+nForecastPeriod])
title('Forecasted Conditional of steel factor profit index')
hold off
%%
sqrt(sum(V(1:252)));
fv = zeros(12,1);
for i = 1:13
    fv(i) = sqrt(sum(V(1:252+(i-1)*21)));
end

