%---cotton option for reval

nOpt = size(hv,1);
optPremiumSale = zeros(nOpt,1);
replicationCost = zeros(nOpt,1);
funding = zeros(nOpt,1);
liquidity = zeros(nOpt,1);
holding = zeros(nOpt,1);

count = 0;

for i = 1:nOpt
    optStart = hv(i,1);
    if i+nPeriod-1 > nOpt
        continue
    end
    
    count = count + 1;
    
    optEnd = hv(i+nPeriod-1,1);
    idx = find(index(:,1)==optStart);
    
    strike = 1;
    
    sigma = hv(i,2);
    
    rateSpec = intenvset('ValuationDate',optStart,'StartDates',optStart,...
        'EndDates',optEnd,'Rates',rates,'Compounding',-1,...
        'Basis',basis2num('ACT/365'));
    
    optInfo = optFullReval{i};
    
    volshift = 0.04;
    
    if volshift ~= 0
        sigma = sigma + volshift;
        stockSpecSale = stockspec(sigma,1.0,divType,divAmount);
        optPremiumSale(i) = optstockbybls(rateSpec,stockSpecSale,optStart,optEnd,...
            optSpec,strike);
    else
        optPremiumSale(i) = optInfo(1,1);
    end
    
    fundingCost = 0;
    liquidityCost = 0;
    riskLevel = 0.75;   %maitain the total margin as 1/riskLevel in the account
    marginRatio = 0.1;  %futures hedge leverage ratio
    liquidityRatio = 0.001; %open/close transaction cost
    businessdaysPerYear = 252;
    maxHolding = 0;
    
    
    for j = 1:size(optInfo,1)
        delta = optInfo(j,2);
        fundingCost = fundingCost + abs(delta)*marginRatio/riskLevel*(exp(rates/businessdaysPerYear)-1);
        if j == 1
            liquidityCost = liquidityCost + abs(delta)*liquidityRatio;
            maxHolding = abs(delta)*marginRatio/riskLevel;
        else
            liquidityCost = liquidityCost +abs(delta-optInfo(j-1,2))*liquidityRatio;
            maxHolding = max(maxHolding,abs(delta)*marginRatio/riskLevel);
        end
    end
    
    avgHolding = sum(abs(optInfo(:,2)))/size(optInfo,1)/riskLevel*marginRatio;
    
    if ~isempty(optInfo)
        optSC = optPremiumSale(i) - optInfo(1,1);
        optPnL = sum(optInfo(:,end))+optSC-fundingCost-liquidityCost;
        replicationCost(i) = -optPremiumSale(i) + optPnL;
        fprintf(['put issued on %s with premium:',...
            '%0.4f; sc:%0.4f; pnl:%0.4f; replication cost:%0.4f; funding:%0.4f; liquidity:%0.4f; holding:%0.4f\n'],...
            datestr(optStart),...
            optPremiumSale(i),...
            optSC,...
            optPnL,...
            replicationCost(i),...
            fundingCost,...
            liquidityCost,...
            avgHolding);
    end
    
    funding(i) = fundingCost;
    liquidity(i) = liquidityCost;
    holding(i) = avgHolding;
    
end

replicationCost = replicationCost(1:count);
funding = funding(1:count);
liquidity = liquidity(1:count);
holding = holding(1:count);

replicationCostRel = replicationCost./optPremiumSale(1:count);
cdfplot(replicationCostRel);
clear fundingCost liquidityCost maxHolding i

figure;
hist(funding+liquidity,30);