function [assetRollResults,modelCalib,indicatorPerf] = markhistvol(varargin)
close all;
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('AssetName',{},@ischar);
p.addParameter('LengthOfPeriod',{},@ischar);
p.parse(varargin{:});
asset = p.Results.AssetName;
period = ['-',p.Results.LengthOfPeriod];

%
assetRollResults = rollfutures(asset,period','CalcDailyReturn',true);

lastBusDate = assetRollResults.ContinousFutures(end,1);
fprintf('the last trade date is %s.\n',datestr(lastBusDate));

%plot daily returns
dailyRet = assetRollResults.DailyReturn;
% timeseries_plot(dailyRet,...
%     'dateformat','mmm-yy',...
%     'title',['Daily Return of the Continuous ',asset,' Futures']);
%
%plot the ACF and PACF of the squared return series
% figure
% subplot(2,1,1)
% autocorr(dailyRet(:,2).^2);
% subplot(2,1,2)
% parcorr(dailyRet(:,2).^2);
%
%conduct an Engle's ARCH test, which tests the null hypothesis of no
%conditional heteroscedasticity against the alternative hypothesis of an
%ARCH model with two lags(which is locally equivalent to a GARCH(1,1)model
%the null hypothesis is rejected in favor of the alternative
%hypothesis(h=1)
% [h,p] = archtest(dailyRet(:,2)-mean(dailyRet(:,2)),'lags',2);

%
%specify an AR(1) model for the conditional mean of the returns and
%GARCH(1,1) model for the conditional variance, this is a model of the form
%r_t = c + AR{1}*r_{t-1}+ebsilon_t
%where ebsilon_t = sigma_t*z_t
%and
%sigma_t^2 = k+GARCH{1}*sigma_{t-1}^2+ARCH{1}*ebsilon_{t-1}^2
%and z_t is an i.i.d standardized Gaussian process
model = arima('ARLags',1,'Variance',garch(1,1));
modelCalib = estimate(model,dailyRet(:,2));
%
%inter and plot the conditional variances and standard residuals. Also
%output loglikelihood objective function value
[E0,V0,~] = infer(modelCalib,dailyRet(1:end,2));
figure
subplot(3,1,1)
% plot(v)
plotyy(0:1:size(dailyRet,1)-1,V0,0:1:size(dailyRet,1)-1,assetRollResults.ContinousFutures(2:end,2));
grid on;
% xlim([0,size(dailyRet,1)])
title('Conditional Variance vs. Daily Price');
subplot(3,1,2)
residual = E0./sqrt(V0);
plot(residual)
xlim([0,size(dailyRet,1)])
title('Standardized Residuals');
subplot(3,1,3)
qqplot(E0./sqrt(V0))
% flag = true;

%Use forecast to compure MMSE forecasts of returns and conditional
%variances for a 20-period future horizon. Use the observed returns and
%inferred residuals and conditional variances as presample data
NPeriod = 20;
[Y,YMSE,V] = forecast(modelCalib,NPeriod,'Y0',dailyRet(:,2),'E0',E0,'V0',V0);
upper = Y + 1.96*sqrt(YMSE);
lower = Y - 1.96*sqrt(YMSE);
N = length(dailyRet(:,2));

figure
subplot(2,1,1)
plot(dailyRet(:,2),'Color',[.75,.75,.75])
hold on
plot(N+1:N+NPeriod,Y,'r','LineWidth',2)
plot(N+1:N+NPeriod,[upper,lower],'k--','LineWidth',1.5)
xlim([0,N+NPeriod])
title('Forecasted Returns')
hold off
subplot(2,1,2)
plot(V0,'Color',[.75,.75,.75])
hold on
plot(N+1:N+NPeriod,V,'r','LineWidth',2);
xlim([0,N+NPeriod])
title('Forecasted Conditional Variances')
hold off

%signal test(demo)
t = assetRollResults.ContinousFutures(:,1);
indicator = [t(2:end-1),residual(1:end-1)];
%performance realized on the next business day after the indicator date
perf = [t(3:end),dailyRet(2:end,2)];
indicatorPerf = [perf(:,1),indicator(:,2),perf(:,2)];
matrix = sortrows(indicatorPerf(:,2:end));
matrix = [matrix(:,1),cumsum(matrix(:,2))];

figure    
plot(matrix(:,1),matrix(:,2));    
title('Indicator vs.Cumulative Performance');
xlabel('indicator(residual)');
ylabel('cumulative performance');



end