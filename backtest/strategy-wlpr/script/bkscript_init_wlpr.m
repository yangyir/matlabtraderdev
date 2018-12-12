% script to init parameters and variables for strategy wlpr
%
clear
%% Bloomberg connection
if ~exist('bbgConn','var'), bbgConn = bbgconnect;end

%% Download intraday bar data from Bloomberg
assetList_wlpr = {'iron ore'};
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
        'OverBought',-0.1,...
        'OverSold',-99.9,...
        'WRMode','classic');
    fprintf('%s:%d trades\n',assetList_wlpr{i},tradesAll_wlpr{i}.latest_);
end
%%
clc;
iAsset = 1;
iTrade = 4;
trade2check = tradesAll_wlpr{iAsset}.node_(iTrade);
bkfunc_checksingletrade_wlpr(assetList_wlpr{iAsset},assetList_wlpr,dataIntradaybarUsed_wlpr,tradesAll_wlpr,iTrade);
%%
batman_extrainfo = struct('bandstoploss',0.01,'bandtarget',0.02);

fprintf('risk management running on trade %d of %s...\n',iTrade,assetList_wlpr{iAsset});

trade2check.setriskmanager('name','batman','extrainfo',batman_extrainfo);
for j = 1:size(dataIntradaybarUsed_wlpr{iAsset},1)
    unwindtrade = trade2check.riskmanager_.riskmanagementwithcandle(dataIntradaybarUsed_wlpr{iAsset}(j,:),...
            'debug',true,...
            'usecandlelastonly',false,...
            'updatepnlforclosedtrade',true,...
            'useopencandle',true,...
            'resetstoplossandtargetonopencandle',true);
        
    if ~isempty(unwindtrade)
        profitLoss = unwindtrade.closepnl_;
        break
    end
end

fprintf('pnl of checked trade:%s...\n',num2str(profitLoss))