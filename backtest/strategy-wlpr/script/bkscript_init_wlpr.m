% script to init parameters and variables for strategy wlpr
%
clear
%% Bloomberg connection
if ~exist('bbgConn','var'), bbgConn = bbgconnect;end

%% Download intraday bar data from Bloomberg
assetList_wlpr = {'govtbond_10y'};
[dataIntradaybar_wlpr,codeList_wlpr] = bkfuns_loadintradaydata( bbgConn, assetList_wlpr );

%% generate trades
nasset_wlpr = size(assetList_wlpr,1);
tradesAll_wlpr = cell(nasset_wlpr,1);
dataIntradaybarUsed_wlpr = cell(nasset_wlpr,1);
sampleFreq_wlpr = {'15m'};
nperiod_wlpr = [144];
for i = 1:nasset_wlpr
    [tradesAll_wlpr{i},dataIntradaybarUsed_wlpr{i}] = bkfunc_gentrades_wlpr(codeList_wlpr{i},dataIntradaybar_wlpr{i},...
        'SampleFrequency',sampleFreq_wlpr{i},...
        'NPeriod',nperiod_wlpr(i),...
        'LongOpenSpread',0,...
        'ShortOpenSpread',0);
end
%%
iAsset = 1;
iTrade = 1;
bkfunc_checksingletrade_wlpr(assetList_wlpr{iAsset},assetList_wlpr,dataIntradaybarUsed_wlpr,tradesAll_wlpr,iTrade);
%%
% idxAsset = 1;
% idxTrade = 1;
% [pnls,pnlBest,pnlWorst] = bkfunc_tradepnldistribution(tradesAll_wlpr{idxAsset}.node_(idxTrade),dataIntradaybarUsed_wlpr{idxAsset});