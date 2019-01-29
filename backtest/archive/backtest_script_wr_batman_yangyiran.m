%%
clear all;clc
fprintf('load intraday candle stick from file......\n');
code = 'ni1809';
replay_startdt = '2018-06-01';
replay_enddt = '2018-06-23';
%
db = cLocal;
instrument = code2instrument(code);
candle_db_1m = db.intradaybar(instrument,replay_startdt,replay_enddt,1,'trade');
%%
fprintf('generate trades......\n');
trade_freq = 3;
stop_period = 72;
trades = backtest_gentrades_wr(code,candle_db_1m,'tradefrequency',trade_freq,...
    'lengthofstopperiod',stop_period);
fprintf('%d trades generated...\n',trades.latest_);

%%
fprintf('check whether stop time of trades are in line with candles......\n');
candle_db_freq = timeseries_compress(candle_db_1m,'frequency',[num2str(trade_freq),'m']);
ntrades = trades.latest_;
diff_found = false;
for i = 1:ntrades
    stoptime_trade = trades.node_(i).stopdatetime1_;
    idx = find(candle_db_freq(:,1) <= trades.node_(i).opendatetime1_,1,'last');
    stoptime_idx = idx + stop_period;
    if stoptime_idx > size(candle_db_freq,1), continue; end
    stoptime_candle = candle_db_freq(stoptime_idx,1);
    if ~strcmpi(datestr(stoptime_candle),  datestr(stoptime_trade))
        fprintf('trade %d:trade stop:%s; candle stop:%s...\n',...
            i,...
            datestr(stoptime_trade,'yyyy-mm-dd HH:MM:SS'),...
            datestr(stoptime_candle,'yyyy-mm-dd HH:MM:SS'));
        diff_found = true;
    end
end
if ~diff_found
    fprintf('well done!all stop time matches...\n')
end

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
            'useopencandle',true);
        if ~isempty(unwindtrade)
            profitLoss(i) = unwindtrade.closepnl_;
            break
        end
    end
end
fprintf('risk management done!...\n')
plot(cumsum(profitLoss))
%%
fprintf('\n');
tradeOpen = trades.node_(1);
tradeOpen.setriskmanager('name','batman','extrainfo',batman_extrainfo);
for j = 1:size(candle_db_freq,1)
    unwindtrade = tradeOpen.riskmanager_.riskmanagementwithcandle(candle_db_freq(j,:),'debug',true,'updatepnlforclosedtrade',true);
    if ~isempty(unwindtrade)
        break
    end
end

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
trades.totxt('c:\yangyiran\tbl1.txt');

