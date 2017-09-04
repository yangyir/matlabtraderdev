%%
%daily analysis
%step1:check whether the yld spd change shows any AR or MA feature,which
%would be useful to speicfy a timeseries model for forecasting daily spd
%change
yldspdEODLvl = yldspdEOD.Data(:,6);
yldspdEODchg = yldspdEODLvl(2:end)-yldspdEODLvl(1:end-1);
[mdlEst,~,~,~,~] = genericarimaestimate(yldspdEODchg);
[E0,V0] = infer(mdlEst,yldspdEODchg);
[Y,YMSE,V] = forecast(mdlEst,1,'Y0',yldspdEODchg,'E0',E0,'V0',V0);
fprintf('forecast mean:%4.2f; upper:%4.2f; lower:%4.2f; volatility:%4.2f\n',...
    Y,Y+1.96*sqrt(YMSE),Y-1.96*sqrt(YMSE),sqrt(V));



%%
%plot whether the the ret/change itself show any trading signal
indicator = yldspdEODLvl(1:end-1);
%normalizing indicator
% indicator = (indicator-mean(indicator))./std(indicator);
perf = yldspdEODchg;
%
%
%2.make up a matrix as of indicator vs.performance and then sort the matrix
%via indicator, plot the indicator aginast the cumulative performance as of
%the sum of the sorted performance
matrix1 = [indicator,perf];
%sort the indicator 
matrix1 = sortrows(matrix1);
matrix1 = [matrix1(:,1),cumsum(matrix1(:,2))];
figure(2)
plot(matrix1(:,1),matrix1(:,2),'b');grid on;
%
%%
mdl = arima('Variance',garch(1,1));
[mdlEst,~,logL] = estimate(mdl,yldspdEODchg);
[E0,V0] = infer(mdlEst,yldspdEODchg);
figure(3)
subplot(2,1,1)
plot(yldspdEODchg,'b');hold on;
plot(E0,'*r');hold off;
subplot(2,1,2)
plot(V0);

[Y,YMSE,V] = forecast(mdlEst,1,'Y0',yldspdEODchg,'E0',E0,'V0',V0);
yUpper = Y+1.96*sqrt(YMSE);
yLower = Y-1.96*sqrt(YMSE);
fprintf('lower:%4.2f;upper:%4.2f;daily fv:%4.2f\n',yUpper,yLower,sqrt(V));
%
%
%%
%backtest with ARIMA model with the EOD yield spread data
%note:always use 250 observations as sample for model calibration
%note:long position once the forecast is positive and short once the
%forecast is negative
mdl = arima('Variance',garch(1,1));
for i = 1:size(yldspdEODchg,1)
    idxEnd = i+249;
    if idxEnd <= size(yldspdEODchg,1)
        sample = yldspdEODchg(i:idxEnd);
        mdlEst = estimate(mdl,sample);
        [E0,V0] = infer(mdlEst,sample);
        Y = forecast(mdlEst,1,'Y0',sample,'E0',E0,'VO',V0);
    end
end



%%
i = ndays-1;
%note:
%column order datetime,px5y,px10y,yld5y,yld10y,yldspd
dt = days(i);
fprintf('date:%s\n',datestr(dt));

idx = find(yldSpreadsEOD.Data(:,1) == dt);
yldspdYstClose = yldSpreadsEOD.Data(idx-1,6);
fprintf('yld curve slope(bp):%4.1f\n',yldspdYstClose);

%
d = dCell{i};
yldspd = d(:,6)-yldspdYstClose;
figure;
plot(yldspd,'b')
yldspdret = yldspd(2:end)-yldspd(1:end-1);
plot(yldspdret,'b')
autocorr(yldspdret)
parcorr(yldspdret)
%
mdl = arima('ARLags',1,'Variance',garch(1,1));
estimate(mdl,yldspdret)

