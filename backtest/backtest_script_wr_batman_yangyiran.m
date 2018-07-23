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
%%
fprintf('check whether stop time of trades are in line with candles......\n');
candle_db_freq = timeseries_compress(candle_db_1m,'frequency',[num2str(trade_freq),'m'],...
        'tradinghours',instrument.trading_hours,...
        'tradingbreak',instrument.trading_break);
ntrades = trades.latest_;
diff_found = false;
for i = 1:ntrades
    stoptime_trade = trades.node_(i).stoptime1_;
    opentime_trade = trades.node_(i).opendatetime1_;
    opentime_idx = candle_db_freq(1:end-1) < opentime_trade & candle_db_freq(2:end) >= opentime_trade;
    opentime_candle = candle_db_freq(opentime_idx);
    idx = find(candle_db_freq == opentime_candle);
    stoptime_idx = idx + stop_period - 1;
    if stoptime_idx <= size(candle_db_freq,1)
        stoptime_candle = candle_db_freq(stoptime_idx,1);
        if ~strcmpi(datestr(stoptime_candle),  datestr(stoptime_trade))
            fprintf('trade %d:trade stop:%s; candle stop:%s...\n',...
                i,...
                datestr(stoptime_trade,'yyyy-mm-dd HH:MM:SS'),...
                datestr(stoptime_candle,'yyyy-mm-dd HH:MM:SS'));
            diff_found = true;
        end
    end
end
if ~diff_found
    fprintf('well done!all stop time matches...\n')
end
%%
fprintf('use riskmanagement_batman for one trade risk management...\n');
tradeOpen = trades.node_(1);
for i = 1:size(candle_db_freq,1)
    riskmanagement_batman(tradeOpen,candle_db_freq(1,:),trade_freq);
end


