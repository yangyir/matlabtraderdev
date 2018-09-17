%%
clear all;clc
fprintf('load intraday candle stick from file......\n');
code = 'rb1805';
replay_startdt = '2017-12-01';
replay_enddt = '2018-04-01';
db = cLocal;
instrument = code2instrument(code);
candle_db_1m = db.intradaybar(instrument,replay_startdt,replay_enddt,1,'trade');
%%
fprintf('generate trades......\n');
trade_freq = 15;
stop_period = 72;
[trades,candle_db_freq] = backtest_gentrades_wr(code,candle_db_1m,'tradefrequency',trade_freq,...
    'lengthofstopperiod',stop_period);
fprintf('%d trades generated...\n',trades.latest_);
ntrades = trades.latest_;

%%
fprintf('risk management running on trades one by one...\n');
batman_extrainfo = struct('bandstoploss',0.01,'bandtarget',0.02);
profitLoss = zeros(ntrades,1);
for i = 1:ntrades
    fprintf('\trisk management on trade %d...\n',i);
    tradeOpen = trades.node_(i);
    tradeOpen.status_ = 'unset';
    tradeOpen.setriskmanager('name','batman','extrainfo',batman_extrainfo);
    for j = 1:size(candle_db_freq,1)
        unwindtrade = tradeOpen.riskmanager_.riskmanagementwithcandle(candle_db_freq(j,:),...
            'debug',false,'usecandlelastonly',false,'updatepnlforclosedtrade',true,...
            'useopencandle',false,...
            'resetstoplossandtargetonopencandle',true);
        if ~isempty(unwindtrade)
            profitLoss(i) = unwindtrade.closepnl_;
            break
        end
    end
end
fprintf('risk management done!...\n')
figure
plot(cumsum(profitLoss(1:ntrades)))
%%
wlpr = willpctr(candle_db_freq(:,3),candle_db_freq(:,4),candle_db_freq(:,5),144);
figure(1)
subplot(211)
candle(candle_db_freq(:,3),candle_db_freq(:,4),candle_db_freq(:,5),candle_db_freq(:,2));
grid on;
subplot(212);
plot(wlpr);grid on;
%%
itrade = 80;
tradeOpen = trades.node_(itrade);
idx = tradeOpen.opendatetime1_ > candle_db_freq(1:end-1,1) & tradeOpen.opendatetime1_ < candle_db_freq(2:end,1);
idx_open = find(candle_db_freq(:,1) == candle_db_freq(idx,1));
idx_stop = idx_open + stop_period;
idx_shift = 1;
figure(2)
subplot(211)
candle(candle_db_freq(idx_open-idx_shift:idx_stop,3),candle_db_freq(idx_open-idx_shift:idx_stop,4),candle_db_freq(idx_open-idx_shift:idx_stop,5),candle_db_freq(idx_open-idx_shift:idx_stop,2));
grid on;hold on;
plot(1:idx_shift+stop_period+1,tradeOpen.openprice_*ones(idx_shift+stop_period+1,1),'g:')
plot(1:idx_shift+stop_period+1,candle_db_freq(idx_open,3)*ones(idx_shift+stop_period+1,1),'r:')
plot(1:idx_shift+stop_period+1,candle_db_freq(idx_open,4)*ones(idx_shift+stop_period+1,1),'r:')
title(['trade ',num2str(itrade)]);
hold off;
subplot(212)
plot(wlpr(idx_open-idx_shift:idx_stop),'b');
grid on;hold off;

%
%run trade one by one
batman_extrainfo = struct('bandstoploss',0.01,'bandtarget',0.02);
fprintf('\n');
tradeOpen.setriskmanager('name','batman','extrainfo',batman_extrainfo);
for j = 1:size(candle_db_freq,1)
    unwindtrade = tradeOpen.riskmanager_.riskmanagementwithcandle(candle_db_freq(j,:),'debug',true,'updatepnlforclosedtrade',true,...
        'ResetStopLossAndTargetOnOpenCandle',true);
    if ~isempty(unwindtrade)
        break
    end
end
fprintf('trade open at %s; close at %s; close pnl:%s...\n',num2str(tradeOpen.openprice_),num2str(tradeOpen.closeprice_),num2str(tradeOpen.closepnl_));

%%
tradesmat = zeros(ntrades,11);
for i = 1:ntrades
    tradesmat(i,1) = m2xdate(trades.node_(i).opendatetime1_);
    tradesmat(i,2) = trades.node_(i).opendirection_;
    tradesmat(i,3) = trades.node_(i).openprice_;
    tradesmat(i,4) = trades.node_(i).riskmanager_.pxstoploss_;    
    tradesmat(i,5) = trades.node_(i).riskmanager_.pxtarget_;
    tradesmat(i,6) = trades.node_(i).opensignal_.highesthigh_;
    tradesmat(i,7) = trades.node_(i).opensignal_.lowestlow_;
    tradesmat(i,8) = m2xdate(trades.node_(i).stopdatetime1_);
    tradesmat(i,9) = m2xdate(trades.node_(i).closedatetime1_);
    tradesmat(i,10) = trades.node_(i).closeprice_;
    tradesmat(i,11) = trades.node_(i).closepnl_;
end
open tradesmat
%%
tbl = trades.totable;
trades.toexcel('temp1','shheet1');

