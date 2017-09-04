nPeriod = 126;
t = nPeriod/252;

%%
%gold
mdl_gold = rollinfo_gold.VolModel.Variance;
lv_gold = mdl_gold.Constant/(1-mdl_gold.GARCH{1}-mdl_gold.ARCH{1});
lv_gold = sqrt(lv_gold*252);
lastret_gold = rollinfo_gold.DailyReturn(end,2);
%calculate the 6m volatility
ret_gold = rollinfo_gold.DailyReturn(:,2);
variance_gold = ret_gold.^2;
hv_gold = zeros(length(ret_gold)-nPeriod+1,2);
for i = nPeriod:length(ret_gold)
    hv_gold(i-nPeriod+1,1) = rollinfo_gold.DailyReturn(i,1);
    hv_gold(i-nPeriod+1,2) = sum(variance_gold(i-nPeriod+1:i));
    hv_gold(i-nPeriod+1,2) = sqrt(hv_gold(i-nPeriod+1,2)/t);
end


%%
%silver
mdl_silver = rollinfo_silver.VolModel.Variance;
lv_silver = mdl_silver.Constant/(1-mdl_silver.GARCH{1}-mdl_silver.ARCH{1});
lv_silver = sqrt(lv_silver*252);
lastret_silver = rollinfo_silver.DailyReturn(end,2);
%calculate the 6m volatility
ret_silver = rollinfo_silver.DailyReturn(:,2);
variance_silver = ret_silver.^2;
hv_silver = zeros(length(ret_silver)-nPeriod+1,2);
for i = nPeriod:length(ret_silver)
    hv_silver(i-nPeriod+1,1) = rollinfo_silver.DailyReturn(i,1);
    hv_silver(i-nPeriod+1,2) = sum(variance_silver(i-nPeriod+1:i));
    hv_silver(i-nPeriod+1,2) = sqrt(hv_silver(i-nPeriod+1,2)/t);
end


%%
%copper
mdl_copper = rollinfo_copper.VolModel.Variance;
lv_copper = mdl_copper.Constant/(1-mdl_copper.GARCH{1}-mdl_copper.ARCH{1});
lv_copper = sqrt(lv_copper*252);
lastret_copper = rollinfo_copper.DailyReturn(end,2);
%calculate the 6m volatility
ret_copper = rollinfo_copper.DailyReturn(:,2);
variance_copper = ret_copper.^2;
hv_copper = zeros(length(ret_copper)-nPeriod+1,2);
for i = nPeriod:length(ret_copper)
    hv_copper(i-nPeriod+1,1) = rollinfo_copper.DailyReturn(i,1);
    hv_copper(i-nPeriod+1,2) = sum(variance_copper(i-nPeriod+1:i));
    hv_copper(i-nPeriod+1,2) = sqrt(hv_copper(i-nPeriod+1,2)/t);
end

%%
%delta ladder
strikes = [1;1.08];
iv = lv_gold;
volshift = [0;0];
spot = 1;
rates = 0.035;
yield = 0.035;
calls = zeros(length(strikes),1);
for i = 1:length(strikes)
    calls(i) = blsprice(spot,strikes(i),rates,0.5,iv+volshift(i),yield);
end

premium = calls(1)-calls(2)

daysshift = 120;
tminus = t-daysshift/252;
S = 0.8:0.005:1.2;
S = S';
deltas = zeros(length(S),1);
for i = 1:length(S)
    delta1 = blsdelta(S(i),strikes(1),rates,tminus,iv+volshift(1),yield);
    delta2 = blsdelta(S(i),strikes(2),rates,tminus,iv+volshift(2),yield);
    deltas(i) = delta1-delta2;
end

plot(S,deltas);

%%
%simulation
dt=1/252;
nperiod=126;
npath = 5000;
sims = zeros(2*npath,nperiod);
rv = randn(npath,nperiod-1);
rv = [rv;-rv];
sims(:,1) = 1;

for i = 2:nperiod
    for j = 1:2*npath
        sims(j,i) = sims(j,i-1)*exp(-iv^2*dt/2+iv*sqrt(dt)*rv(j,i-1));
    end
end

simdelta = zeros(2*npath,nperiod-1);
simtransactioncost = zeros(2*npath,1);
fundingcost = zeros(2*npath,1);
simmarginrequirement = zeros(2*npath,nperiod-1);
tc = 0.001;

for i = 1:nperiod-1
    for j = 1:2*npath
        delta1 = blsdelta(sims(j,i),strikes(1),rates,(nperiod-i)/252,iv,yield);
        delta2 = blsdelta(sims(j,i),strikes(2),rates,(nperiod-i)/252,iv,yield);
        simdelta(j,i) = delta1-delta2;
        if i == 1
            simtransactioncost(j) = abs(simdelta(j,i))*tc;
        else
            simtransactioncost(j) = simtransactioncost(j)+abs((simdelta(j,i)-simdelta(j,i-1)))*tc;
        end
        simmarginrequirement(j,i) = simdelta(j,i)*0.1/0.75;
        if i == 1
            fundingcost(j) = simmarginrequirement(j,i)*(exp(rates*dt)-1);
        else
            fundingcost(j) = fundingcost(j)+simmarginrequirement(j,i)*(exp(rates*dt)-1);
        end
    end
end

%%
discfact = exp(-rates*nperiod/252);
simpremium =sum(max(sims(:,end)-strikes(1),0))/2/npath*discfact;
simpremium =simpremium-sum(max(sims(:,end)-strikes(2),0))/2/npath*discfact;
costaddon = quantile(simtransactioncost,0.95)+quantile(fundingcost,0.95);
simtotal = simpremium+costaddon;


















