%%
clc;
close all
clear
%trading backtest for asset
%%
asset = 'cotton';
period = '-3y';
calibPeriod = '1y';
assetRollResults = rollfutures(asset,period','CalcDailyReturn',true);
%plot daily returns
timeseries_plot(assetRollResults.DailyReturn,'dateformat','mmm-yy',...
    'title',['daily return of the continuous ',asset,' futures']);
%
%plot the sample autocorrelation and partial autocorrelation function for
%return series
figure
subplot(2,1,1)
autocorr(assetRollResults.DailyReturn(:,2));
subplot(2,1,2)
parcorr(assetRollResults.DailyReturn(:,2));
%
%plot the ACF and PACF of the squared return series
figure
subplot(2,1,1)
autocorr(assetRollResults.DailyReturn(:,2).^2);
subplot(2,1,2)
parcorr(assetRollResults.DailyReturn(:,2).^2);
%
%conduct an Engle's ARCH test, which tests the null hypothesis of no
%conditional heteroscedasticity against the alternative hypothesis of an
%ARCH model with two lags(which is locally equivalent to a GARCH(1,1)model
%the null hypothesis is rejected in favor of the alternative
%hypothesis(h=1)
[h,p] = archtest(assetRollResults.DailyReturn(:,2)-mean(assetRollResults.DailyReturn(:,2)),...
    'lags',2);
%
%specify an AR(1) model for the conditional mean of the returns and
%GARCH(1,1) model for the conditional variance, this is a model of the form
%r_t = c + AR{1}*r_{t-1}+ebsilon_t
%where ebsilon_t = sigma_t*z_t
%and
%sigma_t^2 = k+GARCH{1}*sigma_{t-1}^2+ARCH{1}*ebsilon_{t-1}^2
%and z_t is an i.i.d standardized Gaussian process
model = arima('ARLags',1,'Variance',garch(1,1));
modelCalib = estimate(model,assetRollResults.DailyReturn(:,2));
%
%inter and plot the conditional variances and standard residuals. Also
%output loglikelihood objective function value
[res,v,logL] = infer(modelCalib,assetRollResults.DailyReturn(:,2));
figure
subplot(2,1,1)
plot(v)
xlim([0,size(assetRollResults.DailyReturn,1)])
title('Conditional Variance');

subplot(2,1,2)
plot(res./sqrt(v))
xlim([0,size(assetRollResults.DailyReturn,1)])
title('Standardized Residuals');
%
%the standardized residuals have more large values than expected under
%normal distribution. This suggests a Student's t distribution might be
%more appropriate for the innovation distribution
modelT = model;
modelT.Distribution = 't';
modelTCalib = estimate(modelT,assetRollResults.DailyReturn(:,2));
%
[resT,vT,logLT] = infer(modelTCalib,assetRollResults.DailyReturn(:,2));
%
%the second model has six parameters compared to five in the first model
%(because of the t distribution degress of freedom).Despite this, both
%information criteria favor the model with the Student's t distribution.
%The AIC and BIC values are smaller for the t innovation distribution
[aic,bic] = aicbic([logL,logLT],[5,6],size(assetRollResults.DailyReturn,1));


%do a first GARCH model calibration using all 3y observation
% model = garch(1,1);
% modelCalib = estimate(model,goldRollResults.DailyReturn(2:end-1,2),...
%             'E0',goldRollResults.DailyReturn(1,2));
% longTermDailyVol = sqrt(modelCalib.Constant/(1-modelCalib.GARCH{1}-modelCalib.ARCH{1}));
% fprintf('\tthe long term daily (avererage) volatility of %s is %.2f%%\n',...
%     asset,100*longTermDailyVol);

%%
%use the specified observation period for garch model calibration
calibPeriodStartDate = assetRollResults.ContinousFutures(1,1);
calibPeriodEndDate = dateadd(calibPeriodStartDate,calibPeriod);
lastTradeDate = assetRollResults.ContinousFutures(end,1);
%the code would return with no results in case the sample data period is
%shorter than the required model calibration period
if calibPeriodEndDate >= lastTradeDate
    return
end

%long a straddle on each trade date from the next trade date after the 
%model caliration period end date
%count how many straddles to be trade
idx = find(assetRollResults.ContinousFutures(:,1) == calibPeriodEndDate);
%
%note:there could be something wrong in the data source that some daily px
%info is issing
if isempty(idx)
    idx = find(assetRollResults.ContinousFutures(:,1) <= calibPeriodEndDate);
    idx = idx(end);
%     calibPeriodEndDate = goldRollResults.ContinousFutures(idx,1);
end
i=1;
tradeDate = assetRollResults.ContinousFutures(idx+1,1);
nStraddle = 0;
nTradeDays = size(assetRollResults.ContinousFutures,1);
while tradeDate <= lastTradeDate
    nStraddle = nStraddle+1;
    i=i+1;
    if idx+i <= nTradeDays
        tradeDate = assetRollResults.ContinousFutures(idx+i,1);
    else
        break
    end
end

%%
%construct synthetic straddle portfolio
%straddle maturity is chosen to be '3m' from the first trading date
%straddle will be closed out with satisfying conditions
straddleFixedTenor = '3m';
straddles = cell(nStraddle,1);
tradeDate = assetRollResults.ContinousFutures(idx+1,1);
i=1;
while tradeDate <= lastTradeDate
    f = assetRollResults.ContinousFutures(idx+i,2);
    trade.Strike = f;
    trade.StartDate = assetRollResults.ContinousFutures(idx+i,1);
    trade.EndDate = dateadd(trade.StartDate,straddleFixedTenor);
    straddles{i} = trade;
    i=i+1;
    if idx+i <= nTradeDays
        tradeDate = assetRollResults.ContinousFutures(idx+i,1);
    else
        break
    end
end

%%
dailyReturnCalib = timeseries_window(assetRollResults.DailyReturn,...
    'FromDate',calibPeriodStartDate,'ToDate',tradeDate);





straddleInfo = cell(nStraddle,1);
i=1;
calibPeriodEndDate = dateadd(calibPeriodStartDate,calibPeriod);

garchModel = garch(1,1);
while calibPeriodEndDate < lastTradeDate
%     obsStartDate = goldRollResults.ContinousFutures(i,1);
    calibPeriodEndDate = assetRollResults.ContinousFutures(idx+i-1,1);
    dailyReturnCalib = timeseries_window(assetRollResults.DailyReturn,...
        'FromDate',calibPeriodStartDate,'ToDate',calibPeriodEndDate);
    try
        %use the previous daily returns to calibrate the GARCH model and
        %forecast the daily variance
        garchModelCalib = estimate(garchModel,dailyReturnCalib(2:end-1,2),...
            'E0',dailyReturnCalib(1,2),'print',false);
        varForecast = forecast(garchModelCalib,1,'Y0',dailyReturnCalib(:,2));
        fprintf('GARCH model parameters are: %4.4f and %4.4f.Forecast vol is: %4.4f\n',...
            garchModelCalib.GARCH{1},garchModelCalib.ARCH{1},sqrt(varForecast));
        
        %long a synthetic straddle with the strike as the close price on
        %the obsEndDate
        f = assetRollResults.ContinousFutures(idx+i-1,2);
        straddleExpiry = dateadd(calibPeriodEndDate,'3m');
        tau = (straddleExpiry - calibPeriodEndDate)/365;
        straddle = faststraddle(f,f,tau,sqrt(varForecast*252));
        delta = straddle.delta;
        trade.Strike = f;
        trade.StartDate = calibPeriodEndDate;
        trade.ExpiryDate = straddleExpiry;
        trade.Size = delta;
        trade.CarryPrice = f;
        trade.BottomLine = straddle.price;
        trade.pnl = 0;
        straddleInfo{i} = trade;
        
        %calc pnl for exiting synthetic straddles
        for j = 1:i-1
            trade_j = straddleInfo{j};
            size = trade_j.Size;
            price = trade_j.CarryPrice;
            expiry = trade_j.ExpiryDate;
            tau = (expiry - calibPeriodEndDate)/365;
            k = trade_j.Strike;
            if tau > 0
                straddle_j = faststraddle(f,k,tau,sqrt(varForecast*252));
                delta_j = straddle_j.delta;
                if size > 0
                    %carry long position from the previous trading date
                    if delta_j > 0 && delta_j > size
                        pnl = (f - price)*size;
                        price = ((delta_j-size)*f+price*size)/delta_j;
                        size = delta_j;
                        
                        
                    elseif delta_j > 0 && delta_j <= size
                    elseif delta_j <= 0
                    end
                elseif size <= 0
                    %carry long position from the previous trading date
                    if delta_j > 0
                    elseif delta_j <= 0 && delta_j < size
                    elseif delta_j <= 0 && delta_j > size
                    end
                    
                end
                
                
            end
        end
        
        
    catch
        fprintf('stop!\n');
    end
    
    i=i+1;
    
    
end




