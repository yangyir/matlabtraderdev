% script to init parameters and variables for strategy wlpr
%
clear
%% Bloomberg connection
if ~exist('bbgConn','var'), bbgConn = bbgconnect;end
%% Download intraday bar data from Bloomberg
assetList_wlpr = {'govtbond_10y'};
nasset_wlpr = length(assetList_wlpr);
codeList_wlpr = cell(nasset_wlpr,1);
assetInfo_wlpr = cell(nasset_wlpr,1);
dataIntradaybar_wlpr = cell(nasset_wlpr,1);
for i = 1:nasset_wlpr
    assetInfo_wlpr{i} = getassetinfo(assetList_wlpr{i});
    if strcmpi(assetList_wlpr{i},'eqindex_300') || strcmpi(assetList_wlpr{i},'eqindex_50') || strcmpi(assetList_wlpr{i},'eqindex_500')
        dataIntradaybar_wlpr{i} = bbgConn.timeseries([assetInfo_wlpr{i}.BloombergCode,'1 Index'],{'2018-01-01',datestr(getlastbusinessdate,'yyyy-mm-dd')},1,'trade');
        temp = bbgConn.getdata([assetInfo_wlpr{i}.BloombergCode,'A Index'],'parsekyable_des');
    else
        dataIntradaybar_wlpr{i} = bbgConn.timeseries([assetInfo_wlpr{i}.BloombergCode,'1 Comdty'],{'2018-01-01',datestr(getlastbusinessdate,'yyyy-mm-dd')},1,'trade');
        temp = bbgConn.getdata([assetInfo_wlpr{i}.BloombergCode,'A Comdty'],'parsekyable_des');
    end
    codeList_wlpr{i} = bbg2ctp(temp.parsekyable_des{1});
end

%% generate trades
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
bkfunc_checksingletrade_wlpr(assetList_wlpr{1},assetList_wlpr,dataIntradaybarUsed_wlpr,tradesAll_wlpr,1);
%%
idxAsset = 1;
idxTrade = 1;
[pnls,pnlBest,pnlWorst] = bkfunc_tradepnldistribution(tradesAll_wlpr{idxAsset}.node_(idxTrade),dataIntradaybarUsed_wlpr{idxAsset});