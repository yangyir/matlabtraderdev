%%
%shanghai nickel futures
asset = 'nickel';
datainfo = rollfutures(asset);



%%
%statistics of volatilities of shanghai nickel futures
lv = datainfo.ForecastResults.LongTermAnnualVol;
hv = datainfo.ForecastResults.HistoricalAnnualVol;
ev = datainfo.ForecastResults.EWMAAnnualVol;
fv = datainfo.ForecastResults.ForecastedAnnualVol;

fprintf('\n');
fprintf('mean vol:%4.1f%%\n',lv*100);
fprintf('hist vol:%4.1f%%\n',lv*100);
fprintf('ewma vol:%4.1f%%\n',ev*100);
fprintf('fest vol:%4.1f%%\n',fv*100);

%%
%LME nickel 3m rolling futures
lme_nickel = 'LMNIDS03 LME Comdty';
datestart = datainfo.ContinousFutures(1,1);
lme_nickel_hd = history(conn,lme_nickel,{'px_last','volume','open_int'},datestart,today);
%%
%basic teninical analysis
tu_basictechnical(lme_nickel_hd,'lme nickel');


%%
%time series forecast of LME nickel 3m rolling futures
%note the arlags might be updated by user himself
tsmdl = arima('arlags',1,'variance',garch(1,1));
tsmdlest = estimate(tsmdl,lme_nickel_dailyret);
[e0,v0] = infer(tsmdlest,lme_nickel_dailyret);
[y,ymse,v] = forecast(tsmdlest,1,'Y0',lme_nickel_dailyret,'E0',e0,'V0',v0);

fprintf('\nforecast ret:%4.2f%%; upper:%4.2f%%; lower:%4.2f%%; volatility:%4.2f%%\n',...
    y*100,100*(y+1.96*sqrt(ymse)),100*(y-1.96*sqrt(ymse)),100*sqrt(v));
lme_nickel_lv = sqrt(tsmdlest.Variance.UnconditionalVariance*252);
fprintf('mean vol:%4.1f%%\n',lme_nickel_lv*100);
fprintf('\n');
%%
%LME nickel option market
deltastr = {'10DP';'25DP';'50DP';'25DC';'10DC'};
tenor = {'1M';'3M'};
ndelta = size(deltastr,1);
ntenor = size(tenor,1);
sec = cell(ntenor,ndelta);
vols = zeros(ntenor,ndelta);
for i = 1:ntenor
    for j = 1:ndelta
        sec{i,j} = ['LN ',tenor{i},' ',deltastr{j},' VOL LME Comdty'];
        data = getdata(conn,sec{i,j},'last_price');
        vols(i,j) = data.last_price;
    end
end

deltanum = [0.1,0.25,0.5,0.75,0.9];
plot(deltanum,vols(1,:),'-bo');
hold on;
plot(deltanum,vols(2,:),'-r*');
legend('1m','3m');xlabel('delta');ylabel('implied vol');
hold off;

