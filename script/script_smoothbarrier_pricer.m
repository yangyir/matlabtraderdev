%%
assets = 'soybean';
nForecastPeriod = 63;

histinfo = rollfutures(assets,'forecastperiod',nForecastPeriod,'UpdateTimeSeries',true);

sigma = histinfo.ForecastResults.ForecastedAnnualVol+0.05;

fprintf('pricing vol used:%4.1f%%\n',sigma*100);

%%
%black pricer for European option
strike = 1;
[europeanCblk,europeanPblk] = blkprice(1,strike,0,nForecastPeriod/252,sigma);
fprintf('black european put price:%4.2f%%\n',europeanPblk*100);

%%
%create gbm object
mdl = gbm(0,sigma);

dt = 1/252;
T = nForecastPeriod*dt;
rng(1);
nTrials = 20000;
rv = randn(nForecastPeriod+1,0.5*nTrials);
rv = [rv,-rv];
Z = zeros(size(rv,1),1,size(rv,2));
for i = 1:size(rv,1)
    Z(i,:) = rv(i,:);
end

[paths,times] = mdl.simBySolution(nForecastPeriod,'deltatime',dt,'nTrials',nTrials,...
    'Antithetic',false,'Z',Z);

F = zeros(nForecastPeriod+1,nTrials);
for j = 1:nForecastPeriod+1
    F(j,:) = paths(j,1,:);
end
%centering
adj = mean(F,2)-1;
for i = 1:nForecastPeriod+1
    F(i,:) = F(i,:) - adj(i);
end

%%
%european put payoff
payoff = max(strike-F(end,:),0);
premium = mean(payoff);
fprintf('mc european put price:%4.2f%%\n',premium*100);

%%
%asian put payoff
average = mean(F,1);
payoff = max(strike-average,0);
premium = mean(payoff);
fprintf('premium:%4.2f%%\n',premium*100);

%%
%asian with upper-and-out barriers
barriertype = 'di';
barrierlvl = 0.98;
barriershift = -0.01;   %for conservative booking
wedge = 0.01;
barrierdates = 21:21:63;
barrierdates = barrierdates';
%compute survival probability per-path
survprobs_s = ones(1,nTrials);
% survprobs_d = ones(1,nTrials);
for i = size(barrierdates,1)
    for j = 1:nTrials
        survprobs_s(j) = survprobs_s(j)*smoothbarrier(F(barrierdates(i),j),barrierlvl,barriertype,...
        'barriershift',barriershift,'wedge',wedge);
    
%         survprobs_d(j) = survprobs_d(j)*smoothbarrier(F(barrierdates(i),j),upperlvl,'uo',...
%         'barriershift',uppershift);
    end
end

payoff = max(strike-average,0).*survprobs_s;
premium = mean(payoff);
fprintf('asian with barrier premium:%4.2f%%\n',premium*100);






















