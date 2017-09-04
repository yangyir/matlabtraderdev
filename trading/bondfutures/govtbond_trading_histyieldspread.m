function output = govtbond_trading_histyieldspread(rollinfo10y,varargin)

if isempty(varargin)
    doPlot = false;
else
    doPlot = varargin{1};
end

rollInfoTbl = rollinfo10y.RollInfo;
firstbd = rollinfo10y.ContinousFutures(1,1);
lastbd = rollinfo10y.ContinousFutures(end,1);

tbl = cell(size(rollInfoTbl,1)+1,4);
tbl(1:end-1,1) = rollInfoTbl(1:end,4);
tbl(end,1) = rollInfoTbl(end,5);

%always take the same tenor 5y bond futures for the 5-10y yield curve
%calculation
for i = 1:size(tbl,1)
    tbl{i,2} = ['TF',tbl{i,1}(2:end)];
    if i == 1
        tbl{i,3} = firstbd;
        tbl{i,4} = rollInfoTbl{1,1};
    elseif i == size(tbl,1)
        tbl{i,3} = rollInfoTbl{i-1,1};
        tbl{i,4} = lastbd;
    else
        tbl{i,3} = rollInfoTbl{i-1,1};
        tbl{i,4} = rollInfoTbl{i,1};
    end
end

spreads = cell(size(tbl,1),1);
for i = 1:size(tbl,1)
    contract10y = windcode2contract(tbl{i,1}(1:length(tbl{i,1})-4));
    contract5y = windcode2contract(tbl{i,2}(1:length(tbl{i,2})-4));
    px10y = contract10y.getTimeSeries('Connection','bloomberg',...
            'Fields',{'close'},'FromDate',tbl{i,3},...
            'ToDate',tbl{i,4},'frequency','1d');
    px5y = contract5y.getTimeSeries('Connection','bloomberg',...
            'Fields',{'close'},'FromDate',tbl{i,3},...
            'ToDate',tbl{i,4},'frequency','1d');    
    if i == 1
        spreads{i} = [px5y(:,1),px5y(:,end),px10y(:,end)];
    else
        spreads{i} = [px5y(2:end,1),px5y(2:end,end),px10y(2:end,end)];
    end
end

spreads = cell2mat(spreads);
spreads = [spreads,zeros(size(spreads,1),5)];
%compute the implied yield from historical close prices
for i = 1:size(spreads,1)
    spreads(i,4) = bndyield(spreads(i,2),0.03,spreads(i,1),dateadd(spreads(i,1),'5y'));
    spreads(i,5) = bndyield(spreads(i,3),0.03,spreads(i,1),dateadd(spreads(i,1),'10y'));
    spreads(i,7) = bnddurp(spreads(i,2),0.03,spreads(i,1),dateadd(spreads(i,1),'5y'));
    spreads(i,8) = bnddurp(spreads(i,3),0.03,spreads(i,1),dateadd(spreads(i,1),'10y'));
end
spreads(:,6) = 10000*(spreads(:,5)-spreads(:,4));
%remove the spreads before the first roll date as the data is misleading
%given the 10y govtbond is just listed
firstRollDt = rollInfoTbl{1,1};
idx = spreads(:,1)>firstRollDt;
spreads = spreads(idx,:);
%
%
%compute the yield spread change volatility
yldSpreadChg = spreads(2:end,6)-spreads(1:end-1,6);

model = arima('ARLags',1,'Variance',garch('Garch',NaN,'Arch',NaN,'Distribution','t'));
modelEstimate = estimate(model,yldSpreadChg,'display','off');
[E0,V0,~] = infer(modelEstimate,yldSpreadChg);
nForecastPeriod = 21;
[Y,YMSE,V] = forecast(modelEstimate,nForecastPeriod,'Y0',yldSpreadChg,'E0',E0,'V0',V0);
upper = Y + 1.96*sqrt(YMSE);
lower = Y - 1.96*sqrt(YMSE);



if doPlot
    close all;
    N = size(E0,1);
    figure
    subplot(3,1,1)
    plot(spreads(:,6),'Color',[0.75,0.75,0.75]);
    title('Time Series of Yield Spread');
    grid on;
    subplot(3,1,2)
    plot(E0,'Color',[0.75,0.75,0.75])
    hold on
    plot(N+1:N+nForecastPeriod,Y,'r','LineWidth',2)
    plot(N+1:N+nForecastPeriod,[upper,lower],'k--','LineWidth',1.5)
    xlim([0,N+nForecastPeriod])
    title('Forecasted Returns')
    grid on;
    hold off
    subplot(3,1,3)
    plot(V0,'Color',[0.75,0.75,0.75])
    hold on
    plot(N+1:N+nForecastPeriod,V,'r','LineWidth',2);
    xlim([0,N+nForecastPeriod])
    title('Forecasted Conditional Variances')
    grid on;
    hold off
end
%
%

fvSpread = sqrt(sum(V)/nForecastPeriod*252);
hvSpread = std(yldSpreadChg(end-nForecastPeriod+1:end))*sqrt(252);
lambda = modelEstimate.Variance.GARCH{1};
ewmavSpread = abs(yldSpreadChg(end-nForecastPeriod+1));
for i = 2:nForecastPeriod
    ewmavSpread = ewmavSpread^2*lambda+yldSpreadChg(end-nForecastPeriod+i)^2*(1-lambda);
    ewmavSpread = sqrt(ewmavSpread);
end
ewmavSpread = ewmavSpread*sqrt(252);
%
%
output = struct('Data',spreads,...
    'HistoricalAnnualVol',hvSpread,...
    'EWMAAnnualVol',ewmavSpread,...
    'ForecastedAnnualVol',fvSpread,...
    'ForecastedSpreadVariance',V,...
    'ForecastedSpreadChange',Y,...
    'ForecastedSpreadChangeError',YMSE);

end

