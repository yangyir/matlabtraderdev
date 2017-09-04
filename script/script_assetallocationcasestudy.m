%%
c = bbgconnect;
%%
assets = {'copper','aluminum','zinc','lead'};
holding = [21;74;44;48];
unitCost = [0.0005;0.0005;0.0005;0.0005];
nAsset = length(assets);
bbgCode = assets;
bbgSec = assets;
price = zeros(nAsset,1);
for i = 1:nAsset
    info = getassetinfo(assets{i});
    bbgCode{i} = info.BloombergCode;
    bbgSec{i} = [bbgCode{i},'1 Comdty'];
    data = getdata(c,bbgSec{i},'px_last');
    price(i) = data.px_last; 
end

blotter = dataset({price,'Price'},{holding,'InitHolding'},'obsnames',assets);
wealth = sum(blotter.Price.*blotter.InitHolding);
blotter.InitPort = (1/wealth)*(blotter.Price.*blotter.InitHolding);
blotter.UnitCost = unitCost;

% we also download the 3 year historical price for return and covariance
% calculation
dateEnd = today;
dateStart = dateadd(today,'-3y');
histPrice = cell(nAsset,1);
histRet = cell(nAsset,1);
assetMean = zeros(nAsset,1);
assetCovar = zeros(nAsset);
for i = 1:nAsset
    data = history(c,bbgSec{i},'px_last',dateStart,dateEnd);
    histPrice{i} = data;
    ret = log(data(2:end,end)./data(1:end-1,end));
    histRet{i} = ret;
    assetMean(i) = mean(ret);
end

nobs = size(histPrice{i},1);

for i = 1:nAsset
    for j = i:nAsset
        data1 = histRet{i}(:,end);
        data2 = histRet{j}(:,end);
        covariance = cov(data1,data2);
        assetCovar(i,j) = covariance(1,2);
        assetCovar(j,i) = assetCovar(i,j);
    end
end

assetMean = nobs*assetMean/3;
assetCovar = nobs*assetCovar/3;
%%
% step2: simulating asset prices
numObs = 255;   %one calendar year of daily returns
numSim = 1;
retIntervals = 1;   %one trading dat
x = portsim(assetMean'*3/nobs,assetCovar*3/nobs,numObs,retIntervals,numSim,'Exact');
[y,t] = ret2tick(x,[],1/size(x,1));
plot(t,log(y));
title('\bfSimulated Asset Class Total Return Prices');
xlabel('year');
ylabel('Log Total Return Price');
legend(assets,'Location','best');

%%
% step3: setting up the portfolio object
% portfolio weights are nonnegative and sum to 1
p = Portfolio('Name','Asset Allocation Portfolio',...
    'AssetList',assets,...
    'InitPort',blotter.InitPort);
p = setDefaultConstraints(p);
p = estimateAssetMoments(p,y,'DataFormat','Prices');
p.AssetMean = nobs/3*p.AssetMean;
p.AssetCovar = nobs/3*p.AssetCovar;
%%
% step4: validate the portfolio problem
% an important step in portfolio optimization is to validate that the
% portfolio problem is feasible and the main test is to ensure that the set
% of portfolio is nonempty and bounded. 
[lb,ub] = estimateBounds(p);
%%
% step5: plot the efficient frontier
plotFrontier(p,40);
%% 
% step6: evaluating gross vs. net portfolio return
% the portfolio object p does not include transaction costs. To handle net
% returns, create a second portfolio object q that includes transaction
% costs
q = setCosts(p,unitCost,unitCost);

%%
% step7: analyzing descriptive properties of the portfolio structures
[prsk0, pret0] = estimatePortMoments(p, p.InitPort);

pret = estimatePortReturn(p, p.estimateFrontierLimits);
qret = estimatePortReturn(q, q.estimateFrontierLimits);

fprintf('Annualized Portfolio Returns ...\n');
fprintf('                                   %6s    %6s\n','Gross','Net');
fprintf('Initial Portfolio Return           %6.2f %%  %6.2f %%\n',...
    100*pret0,100*pret0);
fprintf('Minimum Efficient Portfolio Return %6.2f %%  %6.2f %%\n',...
    100*pret(1),100*qret(1));
fprintf('Maximum Efficient Portfolio Return %6.2f %%  %6.2f %%\n',...
    100*pret(2),100*qret(2));

%%
% step8: obtaining a portfolio at the specified return level on the
% efficient frontier
% a common approach to select efficient portfolios is to pick a portfolio
% that has desired fraction of the range of expected portfolio returns. To
% obtain the portfolio that is 30% of the ranghe from the minimum to
% maximum return on the efficient frontier, obtain the range of net returns
% in qret using the portfolio object q and interpolate to obtain a 30%
% level with the the interp1 function to obtain a portfolio qwgt
level = 0.7;
qret = estimatePortReturn(q, q.estimateFrontierLimits);
qwgt = estimateFrontierByReturn(q, interp1([0, 1], qret, level));
[qrsk, qret] = estimatePortMoments(q, qwgt);

fprintf('Portfolio at %g%% return level on efficient frontier ...\n',100*level);
fprintf('%10s %10s\n','Return','Risk');
fprintf('%10.2f %10.2f\n',100*qret,100*qrsk);
display(qwgt);

%%
% step9: obtaining a portfolio at the specified risk levels on the
% efficient frontier
% suppose that you have a conservative target risk of 14%, a moderate
% target risk of 16%, and an aggressive target risk of 18% and you want to
% obtain porfolios that satisfy each risk target.
targetRisk = [0.14;0.16;0.18];
qwgt = estimateFrontierByRisk(q,targetRisk);
display(qwgt);
%
% Use the estimatePortRisk function to compute
% the portfolio risks for the three portfolios to confirm that the target
% risks have been attained:

display(estimatePortRisk(q, qwgt));

% Suppose that you want to shift from the current portfolio to the moderate
% portfolio. You can estimate the purchases and sales to get to this
% portfolio:

[qwgt, qbuy, qsell] = estimateFrontierByRisk(q, 0.15);

% If you average the purchases and sales for this portfolio, you can see
% that the average turnover is 17%, which is greater than the target of
% 15%:

disp(sum(qbuy + qsell)/2)

% Since you also want to ensure that average turnover is no more than 15%,
% you can add the average turnover constraint to the Portfolio object:

q = setTurnover(q, 0.15);
[qwgt, qbuy, qsell] = estimateFrontierByRisk(q, 0.15);

% You can enter the estimated efficient portfolio with purchases and sales into the Blotter:
qbuy(abs(qbuy) < 1.0e-5) = 0;
qsell(abs(qsell) < 1.0e-5) = 0;  % zero out near 0 trade weights

blotter.Port = qwgt;
blotter.Buy = qbuy;
blotter.Sell = qsell;

display(blotter);

% The Buy and Sell elements of the Blotter are changes in portfolio weights that
% must be converted into changes in portfolio holdings to determine
% the trades. Since you are working with net portfolio returns, you
% must first compute the cost to trade from your initial portfolio to
% the new portfolio. This can be accomplished as follows:

totalCost = wealth * sum(blotter.UnitCost .* (blotter.Buy + blotter.Sell));

% in general, you would have to
% adjust your initial wealth accordingly before setting up your new
% portfolio weights. However, to keep the analysis simple, note that you
% have sufficient cash set aside to pay the trading costs and
% that you will not touch the cash position to build up any positions in
% your portfolio. Thus, you can populate your blotter with the new
% portfolio holdings and the trades to get to the new portfolio without
% making any changes in your total invested wealth. First, compute portfolio holding:

blotter.Holding = wealth * (blotter.Port ./ blotter.Price);

% Compute number of shares to Buy and Sell in your Blotter:

blotter.BuyShare = wealth * (blotter.Buy ./ blotter.Price);
blotter.SellShare = wealth * (blotter.Sell ./ blotter.Price);

% Notice how you used an add-hoc truncation rule to obtain unit numbers of
% shares to buy and sell. Clean up the blotter by removing the unit costs
% and the buy and sell portfolio weights:

blotter.Buy = [];
blotter.Sell = [];
blotter.UnitCost = [];

display(blotter);

plotFrontier(q, 40);
hold on
scatter(estimatePortRisk(q, qwgt), estimatePortReturn(q, qwgt), 'filled', 'r');
h = legend('Initial Portfolio', 'Efficient Frontier', 'Final Portfolio', 'location', 'best');
set(h, 'Fontsize', 8);
hold off
