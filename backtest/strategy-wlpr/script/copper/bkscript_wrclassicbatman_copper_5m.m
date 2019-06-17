%%
% load all intraday candles from onedrive
% the intraday data is stored in 5min interval
ui_freq = 5;
dir_ = [getenv('OneDrive'),'\backtest\copper\'];
fn = 'copper_intraday_5m';
data = load([dir_,fn]);
candles = data.candles_5m;
dt1 = floor(candles{1,2}(1,1));
dt2 = floor(candles{end,2}(end,1));
bds = gendates('fromdate',dt1,'todate',dt2);
nbds = size(bds,1);

%%
pnls = cell(size(candles,1),1);
ui_wrmode = 'classic';
ui_nperiod = 100;
ui_overbought = 0;
ui_oversold = -100;
ui_riskmanagername = 'batman';
ui_bandtarget = 0.15;
ui_bandstoploss = 0.05;
extrainfo = struct('bandstoploss_',ui_bandstoploss,...
        'bandtarget_',ui_bandtarget);

for ifut = 1:size(candles,1)
    candlek = candles{ifut,2};
    [trades,~] = bkfunc_gentrades_wlpr(candles{ifut,1},candlek,...
        'wrmode',ui_wrmode,...
        'nperiod',ui_nperiod,...
        'samplefrequency',[num2str(ui_freq),'m'],...
        'overbought',ui_overbought,...
        'oversold',ui_oversold);
     fprintf('%s:%d trades...\n',candles{ifut,1},trades.latest_);
     ntrades = trades.latest_;
     pnl2 = zeros(ntrades,1);%wrstrp pnl
     for itrade = 1:ntrades
        tradein2 = trades.node_(itrade).copy;
        tradein2.setriskmanager('name',ui_riskmanagername,'extrainfo',extrainfo);
        openbucket = gettradeopenbucket(tradein2,tradein2.opensignal_.frequency_);
        idxopen = find(candlek(:,1) == openbucket);
        for iprice = idxopen:size(candlek,1)
            candlein = candlek(iprice,:);
            unwindtrade = tradein2.riskmanager_.riskmanagementwithcandle(candlein,...
                'usecandlelastonly',false,...
                'updatepnlforclosedtrade',true);
            if ~isempty(unwindtrade)
                pnl2(itrade) = unwindtrade.closepnl_;
                break
            end
        end
        if isempty(unwindtrade)
            pnl2(itrade) = tradein2.runningpnl_;
        end
     end
     pnls{ifut} = pnl2;
end
pnlmat = cell2mat(pnls);
close all;
plot(cumsum(pnlmat));
sharpratio = sqrt(nbds)*mean(pnlmat)/std(pnlmat);
fprintf('sharp ratio:%4.2f\n',sharpratio);
fprintf('total pnl:%s\n',num2str(sum(pnlmat)));

