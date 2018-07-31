%user inputs:
code = 'ni1809';
startdt = '2018-06-14';
enddt = '2018-06-19';
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
    trade_j = trades2check.node_(i);
    fprintf('id:%2d,opentime:%s,direction:%2d,price:%s,stoptime:%s\n',...
        i,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
        num2str(trade_j.openprice_),...
        trade_j.stopdatetime2_(end-8:end));
end
%results as follows
% id: 1,opentime: 09:03:01,direction: 1,price:114090,stoptime: 14:54:00
% id: 2,opentime: 09:06:01,direction: 1,price:113470,stoptime: 14:57:00
% id: 3,opentime: 14:12:01,direction: 1,price:113400,stoptime: 23:48:00
% id: 4,opentime: 14:15:01,direction: 1,price:113260,stoptime: 23:51:00
% id: 5,opentime: 14:18:01,direction: 1,price:113120,stoptime: 23:54:00
% id: 6,opentime: 14:24:01,direction: 1,price:113010,stoptime: 00:00:00
% id: 7,opentime: 14:27:01,direction: 1,price:113000,stoptime: 00:03:00
% id: 8,opentime: 14:30:01,direction: 1,price:112890,stoptime: 00:06:00
% id: 9,opentime: 14:33:01,direction: 1,price:112870,stoptime: 00:09:00
% id:10,opentime: 14:36:01,direction: 1,price:112790,stoptime: 00:12:00
% id:11,opentime: 14:39:01,direction: 1,price:112580,stoptime: 00:15:00
% id:12,opentime: 21:00:01,direction: 1,price:112420,stoptime: 00:36:00

%%
replay_speed = 50;
replay_strat = replay_setstrat('wlprbatman','replayspeed',replay_speed);
replay_strat.registerinstrument(code);
replay_strat.setsamplefreq(code,trade_freq);
replay_strat.setautotradeflag(code,1);
replay_strat.setmaxunits(code,100);
replay_strat.setmaxexecutionperbucket(code,1);
replay_strat.setbandtarget(code,0.02);
replay_strat.setbandstoploss(code,0.01);
%
replay_filename = [code,'_',datestr(checkdt,'yyyymmdd'),'_tick.txt'];
replay_strat.mde_fut_.initreplayer('code',code,'fn',replay_filename);
replay_strat.initdata;
clc;
fprintf('replay get ready......\n');
%%
clc;
replay_strat.mde_fut_.display_ = 0;
replay_strat.start;
replay_strat.helper_.start; 
replay_strat.mde_fut_.start;
%%
try
    replay_strat.stop;
    replay_strat.helper_.stop;
    replay_strat.mde_fut_.stop;
    delete(timerfindall);
catch
    clear all;
    fprintf('all deleted\n');
end
%%
fprintf('\ntrades info from replay......\n')
for j = 1:replay_strat.helper_.trades_.latest_
    trade_j = replay_strat.helper_.trades_.node_(j);
    fprintf('id:%2d,opentime:%s,direction:%2d,price:%s,stoptime:%s\n',...
        j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
        num2str(trade_j.openprice_),...
        trade_j.stopdatetime2_(end-8:end));
end

%%
fprintf('\ntrades info from replay......\n')
pnl = 0;
for j = 1:replay_strat.helper_.trades_.latest_
    trade_j = replay_strat.helper_.trades_.node_(j);
    pnl = pnl + trade_j.closepnl_;
end
