%user inputs:
code = 'ni1809';
startdt = '2018-06-01';
enddt = '2018-06-23';
checkdt = '2018-06-19';
trade_freq = 3;
stop_nperiod = 72;

%%
db = cLocal;
instrument = code2instrument(code);
candle_db_1m = db.intradaybar(instrument,startdt,enddt,1,'trade');
trades = backtest_gentrades_wr(code,candle_db_1m,'tradefrequency',trade_freq,...
    'lengthofstopperiod',stop_nperiod);
%find trades which executed on the checkdt
checkdt_start = [checkdt,' ',instrument.break_interval{1,1}];
checkdt_end = [datestr(datenum(checkdt,'yyyy-mm-dd')+1,'yyyy-mm-dd'),' ',instrument.break_interval{end,end}];
trades2check = cTradeOpenArray;
for i = 1:trades.latest_
    if trades.node_(i).opendatetime1_ > datenum(checkdt_start) && trades.node_(i).opendatetime1_ < datenum(checkdt_end)
        trades2check.push(trades.node_(i));
    end
end
clc;
for i = 1:trades2check.latest_
    trade_i = trades2check.node_(i);
    fprintf('id: %3d, time:%s, direction:%2d, price:%s\n',...
        i,trade_i.opendatetime2_(end-8:end),trade_i.opendirection_,...
        num2str(trade_i.openprice_));
end
%results as follows
% id:   1, time: 09:03:01, direction: 1, price:114090
% id:   2, time: 09:06:01, direction: 1, price:113470
% id:   3, time: 14:12:01, direction: 1, price:113400
% id:   4, time: 14:15:01, direction: 1, price:113260
% id:   5, time: 14:18:01, direction: 1, price:113120
% id:   6, time: 14:24:01, direction: 1, price:113010
% id:   7, time: 14:27:01, direction: 1, price:113000
% id:   8, time: 14:30:01, direction: 1, price:112890
% id:   9, time: 14:33:01, direction: 1, price:112870
% id:  10, time: 14:36:01, direction: 1, price:112790
% id:  11, time: 14:39:01, direction: 1, price:112580
% id:  12, time: 21:00:01, direction: 1, price:112420
