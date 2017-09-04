%%
%create the synthetic index based on the first futures
%---user inputs
asset = 'aluminum';     % underlying asset name
nPeriod = 22;          % period for historical volatility window

rollinfo = rollfutures(asset,'calcdailyreturn',true,...
    'calibratevolmodel',true,...
    'printresults',false);

ret = rollinfo.DailyReturn(:,2);
%replicate the index
index = rollinfo.ContinousFutures(:,1:2);
index(1,2) = 100;
for i = 2:size(index,1)
    index(i,2) = index(i-1,2)*exp(ret(i-1));
end


close all;
timeseries_plot(index,'dateformat','mmm-yy',...
    'title',[asset,' index']);

%%
%calculat the period relative change of the index
periodChange = zeros(size(index,1)-nPeriod+1,2);
for i = nPeriod:size(index,1)
    periodChange(i-nPeriod+1,1) = index(i,1);
    periodChange(i-nPeriod+1,2) = index(i,2)/index(i-nPeriod+1,2)-1;
end
timeseries_plot(periodChange,'dateformat','mmm-yy',...
    'title',[asset, ' relative change within ',num2str(nPeriod),' business days']);
figure;
boxplot(periodChange(:,2),month(periodChange(:,1)));
xlabel('month');
ylabel(['relative change within ',num2str(nPeriod),' business days']);
title([asset, ' relative change within ',num2str(nPeriod),' business days']);


%calculate the historical volatility
variance = ret.^2;
hv = zeros(length(ret)-nPeriod+1,2);
for i = nPeriod:length(ret)
    hv(i-nPeriod+1,1) = rollinfo.DailyReturn(i,1);
    hv(i-nPeriod+1,2) = sum(variance(i-nPeriod+1:i));
    t = rollinfo.DailyReturn(i,1) - rollinfo.DailyReturn(i-nPeriod+1,1);
    t = t/365;
    hv(i-nPeriod+1,2) = sqrt(hv(i-nPeriod+1,2)/t);
end

timeseries_plot(hv,'dateformat','mmm-yy',...
    'title',[asset,' ',num2str(nPeriod),'-business day historical volatility']);

clear variance ret i t

%%
%option full reval
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
            volshift = 0.04;
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
