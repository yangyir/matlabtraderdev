clear
if ~exist('bbgConn','var'), bbgConn = bbgconnect;end
%% download intraday data
assets = getassetmaptable;
[dataIntradaybar,codes] = bkfunc_loadintradaydata(bbgConn, assets);
%% compress data into trading freq
nassets = size(assets,1);
dataIntraday2use = cell(nassets,1);
freq = '15m';
for i = 1:nassets
    instrument = code2instrument(codes{i});
    dataIntraday2use{i} = timeseries_compress(dataIntradaybar{i},...
        'frequency',freq,...
        'tradinghours',instrument.trading_hours,...
        'tradingbreak',instrument.trading_break);
end
%% vol model calibrate
model = arima('ARLags',1,'Variance',garch(1,1));
modelCalibrated = cell(nassets,1);
for i = 1:nassets
    ret = log(dataIntraday2use{i}(2:end,5)./dataIntraday2use{i}(1:end-1,5));
    try
        modelCalibrated{i} = estimate(model,ret,'print',false);
    catch e
        fprintf('%s:%s\n',assets{i},e.message);
    end
        
end
%% long-term average vol
clc;
lv = NaN(nassets,1);
for i = 1:nassets
    if isempty(modelCalibrated{i}), continue; end
    paramGarch = modelCalibrated{i}.Variance.GARCH{1};
    paramArch = modelCalibrated{i}.Variance.ARCH{1};
    paramConst = modelCalibrated{i}.Variance.Constant;
    %long-term average vol
    lv(i) = sqrt(paramConst/(1-paramGarch-paramArch));
    fprintf('%15s:%8.2f%%\n',assets{i},lv(i)*100);
end