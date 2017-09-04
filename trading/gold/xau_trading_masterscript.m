%%
%shanghai gold futures
rollinfoSHGold = rollfutures('gold');
syntheticIndex = rollinfoSHGold.ContinousFutures;
syntheticIndex(:,2) = 1;
for i = 2:size(syntheticIndex,1)
    syntheticIndex(i,2) = syntheticIndex(i-1,2)*exp(rollinfoSHGold.DailyReturn(i-1,2));
end
timeseries_plot(syntheticIndex,'dateformat','mmm-yy','title','SH Gold Synthetic Index');
indexLvl = syntheticIndex(end,2);





%%
%real-time market price update
sec = 'xau curncy';
rtdata = getdata(conn,sec,{'time','px_last'});
fprintf('gold last price %4.2f update on %s %s\n',...
    rtdata.px_last,datestr(today),...
    rtdata.time{1});

%%
%calibrate vol forecast model with different time window length
%forecast 3m volatility
nForecastPeriod = 63;
model = arima('ARLags',1,'Variance',garch(1,1));
% model = garch(1,1);
timewindow = {'-3m','-6m','-1y','-3y','-5y','-10y','-15y','-20y'};
fprintf('\n');
for i = 1:length(timewindow)
    data = history(conn,sec,'px_last',dateadd(today,timewindow{i}),today);
    if data(end,1) == today
        data = data(1:end-1,:);
    end
    ret = [data(2:end,1),log(data(2:end,2)./data(1:end-1,2))];
    modelEstimate = estimate(model,ret(:,2),'display','off');
    paramGarch = modelEstimate.Variance.GARCH{1};
    paramArch = modelEstimate.Variance.ARCH{1};
    uv = modelEstimate.Variance.UnconditionalVariance;
    lv = sqrt(uv*252);
    [E0,V0,~] = infer(modelEstimate,ret(:,2));
    [Y,YMSE,V] = forecast(modelEstimate,nForecastPeriod,'Y0',ret(:,2),'E0',E0,'V0',V0);
    fv = sqrt(sum(V)/nForecastPeriod*252);
    
    fprintf('%4s: GARCH:%4.2f; ARCH:%4.2f; LV:%4.1f%%; FV:%4.1f%%\n',...
        timewindow{i},paramGarch,paramArch,...
        100*lv,100*fv);
end

%%
%build option portfolio
%
%some user inputs
quantity = 1000;
tenor = '3m';
r = 0.03;
cpWeights = [1,1];
lambda = 0.91;
%

backtestStartIdx = nForecastPeriod;
%initial EWMA vol calculation
ewmav = abs(ret(backtestStartIdx-nForecastPeriod+1,2));
for i = 2:nForecastPeriod
    ewmav = ewmav^2*lambda+ret(backtestStartIdx-nForecastPeriod+i,2)^2*(1-lambda);
    ewmav = sqrt(ewmav);
end

%historical EWMA vol calculation
ewmavVec = zeros(size(data,1)-backtestStartIdx,2);
ewmavVec(1,1) = ret(nForecastPeriod,1);
ewmavVec(1,2) = ewmav;
for i = 2:size(ewmavVec,1)
    ewmavVec(i,1) = ret(nForecastPeriod+i-1,1);
    ewmavVec(i,2) = ewmavVec(i-1,2)^2*lambda+ret(nForecastPeriod+i-1,2)^2*(1-lambda);
    ewmavVec(i,2) = sqrt(ewmavVec(i,2));
end
%

optionPortfolio = cell(size(ewmavVec,1),1);
for i = 1:size(ewmavVec,1)
    startDate = ewmavVec(i,1);
    vol = ewmavVec(i,2);
    strike = data(data(:,1)==startDate,2);
    expiryDate = dateadd(startDate,tenor);
    tau = (expiryDate - startDate)/365;
    %do a valuation first
    [c,p] = blkprice(strike,strike,r,tau,vol*sqrt(252));
    premium = c*cpWeights(1)+p*cpWeights(2);
    premium = premium*quantity;
    optionPortfolio{i} = struct('StartDate',startDate,...
        'ExpiryDate',expiryDate,...
        'Strike',strike,...
        'Quantity',quantity,...
        'Premium',premium,...
        'Status','live');
end
%

%%
%start to run the backtest
for i = 1;size(ewmavVec,1)
    cobDate = ewmavVec(i,1);
    price = data(data(:,1)==cobDate,2);
    vol = ewmavVec(i,2);
    for j = 1:size(optionPortfolio,1)
        expiryDate_j = optionPortfolio{j}.ExpiryDate;
        startDate_j = optionPortfolio{j}.StartDate;
        status_j = optionPortfolio{j}.Status;
        if strcmpi(status_j,'live') && ...
                startDate_j <= cobDate && ...
                expiryDate_j <= cobDate
            strike = optionPortfolio{j}.Strike;
            tau = (expiryDate_j-cobDate)/365;
            [c,p] = blkprice(price,strike,r,tau,vol*sqrt(252));
            mtm = c*cpWeights(1)+p*cpWeights(2);
            mtm = mtm*quantity;
            pnl = mtm - optionPortfolio{j}.Premium;
            
        end
    end
end



