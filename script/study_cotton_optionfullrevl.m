%---cotton option for reval

nOpt = size(hv,1);
optFullReval = cell(nOpt,1);

for i = 1:size(hv,1)
    optStart = hv(i,1);
    optEnd = hv(i+nPeriod-1,1);
    idx = find(index(:,1)==optStart);
    
    optInfo = zeros(nPeriod,6);
    %1st column:option price
    %2nd column:option delta
    %3rd column:underlier relative spot
    %4th column:short option pnl
    %5th column:hedge futures pnl
    %6th column:delta-neutral position pnl
    refSpot = index(idx,2);
    strike = 1;
    
    count = 1;
    for j = i:size(hv,1)
        settle = hv(j,1);
        if settle > optEnd
            %option expired
            continue
        end
        sigma = hv(j,2);
        idx = find(index(:,1)==settle);
        relSpot = index(idx,2)/refSpot;
        optInfo(count,3) = relSpot;
        
        if settle == optEnd
            optInfo(count,1) = max(strike-relSpot,0);
            optInfo(count,4) = -1*(optInfo(count,1)-optInfo(count-1,1));
            optInfo(count,5) = optInfo(count-1,2)*(optInfo(count,3)-optInfo(count-1,3));
            optInfo(count,6) = optInfo(count,4)+optInfo(count,5);
            continue
        end
        % option still alive
        rateSpec = intenvset('ValuationDate',settle,'StartDates',settle,...
            'EndDates',optEnd,'Rates',rates,'Compounding',-1,...
            'Basis',basis2num('ACT/365'));
        
        stockSpec = stockspec(sigma,relSpot,divType,divAmount);
        if j == i
            volshift = 0.0;
            sigma = sigma + volshift;
            stockSpecSale = stockspec(sigma,relSpot,divType,divAmount);
            optPremiumSale = optstockbybls(rateSpec,stockSpecSale,settle,optEnd,...
            optSpec,strike);
        end
        
        [optInfo(count,1),optInfo(count,2)] = optstocksensbybls(rateSpec,stockSpec,settle,optEnd,...
            optSpec,strike,'OutSpec',outSpec);
        if count == 1
            optInfo(count,4) = optInfo(count,1);%the first day option pnl is the premium received
            optInfo(count,5) = 0;
            optInfo(count,6) = optInfo(count,4)+optInfo(count,5);
        else
            optInfo(count,4) = -1*(optInfo(count,1)-optInfo(count-1,1));
            optInfo(count,5) = optInfo(count-1,2)*(optInfo(count,3)-optInfo(count-1,3));
            optInfo(count,6) = optInfo(count,4)+optInfo(count,5);
        end
        
        count = count+1;
    end
    if ~isempty(optInfo)
        optSC = optPremiumSale - optInfo(1,1);
        optPnL = sum(optInfo(:,end))+optSC;
        replicationCost = -optPremiumSale + optPnL;
        fprintf(['put issued on %s with premium:',...
            '%0.4f; sc:%0.4f; pnl:%0.4f and replication cost:%0.4f\n'],...
            datestr(optStart),...
            optPremiumSale,...
            optSC,...
            optPnL,...
            replicationCost);
    end
    optFullReval{i} = optInfo;
end