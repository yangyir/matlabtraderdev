%%
clear all;clc
fprintf('load intraday candle stick from file......\n');
code = 'ni1809';
replay_startdt = '2018-06-01';
replay_enddt = '2018-06-23';
%
instrument = code2instrument(code);
replay_dates = gendates('fromdate',replay_startdt,'todate',replay_enddt);
candle_db_1m_1day = cell(size(replay_dates));
for i = 1:size(replay_dates,1)
    if weekday(replay_dates(i)) ~= 6
        fn_candles_ = [code,'_',datestr(replay_dates(i),'yyyymmdd'),'_1m.txt'];
        candle_db_1m_1day{i} = cDataFileIO.loadDataFromTxtFile(fn_candles_);
    else
        fn_candles_ = [code,'_',datestr(replay_dates(i),'yyyymmdd'),'_1m.txt'];
        candle_db_1 = cDataFileIO.loadDataFromTxtFile(fn_candles_);
        try
            fn_extra_ = [code,'_',datestr(replay_dates(i)+1,'yyyymmdd'),'_1m.txt'];
            candle_db_2 = cDataFileIO.loadDataFromTxtFile(fn_extra_);
            candle_db_1m_1day{i} = [candle_db_1;candle_db_2];
        catch
            candle_db_1m_1day{i} = candle_db_1;
        end
    end
end
candle_db_1m = cell2mat(candle_db_1m_1day);
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
    stoptime_idx = idx + stop_period - 1;
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
    tradeOpen.setriskmanager('name','batman','extrainfo',batman_extrainfo);
    for j = 1:size(candle_db_freq,1)
        unwindtrade = tradeOpen.riskmanager_.riskmanagementwithcandle(candle_db_freq(j,:),'debug',false,'updatepnlforclosedtrade',true);
        if ~isempty(unwindtrade)
            profitLoss(i) = unwindtrade.closepnl_;
            break
        end
    end
end
fprintf('risk management done!...\n')
%%
fprintf('\n');
tradeOpen = trades.node_(70);
tradeOpen.setriskmanager('name','batman','extrainfo',batman_extrainfo);
for j = 1:size(candle_db_freq,1)
    unwindtrade = tradeOpen.riskmanager_.riskmanagementwithcandle(candle_db_freq(j,:),'debug',true,'updatepnlforclosedtrade',true);
    if ~isempty(unwindtrade)
        break
    end
end

%%
tradesmat = zeros(ntrades,7);
for i = 1:ntrades
    tradesmat(i,1) = trades.node_(i).opendatetime1_;
    tradesmat(i,2) = trades.node_(i).opendirection_;
    tradesmat(i,3) = trades.node_(i).openprice_;
    tradesmat(i,4) = trades.node_(i).riskmanager_.pxstoploss_;    
    tradesmat(i,5) = trades.node_(i).riskmanager_.pxtarget_;
    tradesmat(i,6) = trades.node_(i).opensignal_.highesthigh_;
    tradesmat(i,7) = trades.node_(i).opensignal_.lowestlow_;
end



