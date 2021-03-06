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
trades = bkfunc_gentrades_wlpr(code,candle_db_1m,'SampleFrequency',[num2str(trade_freq),'m'],...
    'NStopPeriod',stop_nperiod);
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
delete(timerfindall);
replay_speed = 50;
replay_strat = replay_setstrat('wlprbatman','replayspeed',replay_speed);
replay_strat.setavailablefund(1e6,'firstset',true);
% Name	cStratConfigWRBatman
% CodeCTP	ni1809
% SampleFreq	3m
% PnLStopType	ABS
% PnLStop	50000
% PnLLimitType	ABS
% PnLLimit	50000
% BidOpenSpread	0
% BidCloseSpread	0
% AskOpenSpread	0
% AskCloseSpread	0
% BaseUnits	1
% MaxUnits	100
% AutoTrade	1
% ExecutionPerBucket	1
% MaxExecutionPerBucket	1
% NumofPeriod	144
% OverBought	0
% OverSold	-100
% ExecutionType	fixed
% BandwidthMin	0.333333
% BandwidthMax	0.5
% BandStopLoss	0.01
% BandTarget	0.02
% BandType	0
replay_strat.loadriskcontrolconfigfromfile('filename','wrbatmanconfig_regressiontest.txt');
%
% replay_filename = ['C:\yangyiran\regressiondata\',code,'_',datestr(checkdt,'yyyymmdd'),'_tick.mat'];
replay_filename = [code,'_',datestr(checkdt,'yyyymmdd'),'_tick.mat'];
replay_strat.mde_fut_.initreplayer('code',code,'fn',replay_filename);
replay_strat.initdata;
replay_strat.mde_fut_.printflag_ = false;
replay_strat.helper_.print_timeinterval_ = 60*trade_freq;
clc;
fprintf('replay get ready......\n');
%%
clc;
replay_strat.mde_fut_.start;
replay_strat.helper_.start; 
replay_strat.start;

%%
try
    replay_strat.mde_fut_.stop;
    delete(timerfindall);
catch
    clear all;
    fprintf('all deleted\n');
end
%%
fprintf('\ntrades info from replay......\n')
totalpnl = 0;
for j = 1:replay_strat.helper_.trades_.latest_
    trade_j = replay_strat.helper_.trades_.node_(j);
    fprintf('id:%2d,opentime:%s,direction:%2d,price:%s,stoptime:%s,closetime:%s,pnl:%s\n',...
        j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
        num2str(trade_j.openprice_),...
        trade_j.stopdatetime2_(end-8:end),...
        trade_j.closedatetime2_(end-8:end),...
        num2str(trade_j.closepnl_));
    totalpnl = totalpnl + trade_j.closepnl_;
end
fprintf('total pnl:%s\n',num2str(totalpnl));
% trades info from replay......
% id:1,opentime: 14:39:02,direction: 1,price:112580,stoptime: 00:15:00,closetime: 21:00:01,pnl:-110
% id:2,opentime: 21:00:04,direction: 1,price:112420,stoptime: 00:36:00,closetime: 22:24:03,pnl:680
% total pnl:570

%%
trades = cTradeOpenArray;
trades.fromtxt('c:\yangyiran\ops\save\replay_book\replay_book_trades_20180619.txt');
for j = 1:trades.latest_
    trade_j = trades.node_(j);
    if strcmpi(trade_j.status_,'closed')
        fprintf('id:%2d,opentime:%s,direction:%2d,price:%s,stoptime:%s,closetime:%s,pnl:%s\n',...
            j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
            num2str(trade_j.openprice_),...
            trade_j.stopdatetime2_(end-8:end),...
            trade_j.closedatetime2_(end-8:end),...
            num2str(trade_j.closepnl_));
    end
end
% results as of the old version:i.e only 1 instrument and run through tick
% time rather than calendar time directly:
% id: 1,opentime: 09:04:49,direction: 1,price:114090,stoptime: 14:53:59,closetime: 09:04:50,pnl:-170
% id: 2,opentime: 09:06:00,direction: 1,price:113470,stoptime: 14:57:00,closetime: 09:48:01,pnl:510
% id: 3,opentime: 14:12:47,direction: 1,price:113400,stoptime: 23:48:00,closetime: 14:15:19,pnl:-160
% id: 4,opentime: 14:15:01,direction: 1,price:113260,stoptime: 23:51:00,closetime: 14:18:04,pnl:-170
% id: 5,opentime: 14:18:01,direction: 1,price:113120,stoptime: 23:53:59,closetime: 14:27:01,pnl:40
% id: 6,opentime: 14:21:02,direction: 1,price:113010,stoptime: 23:57:00,closetime: 14:30:00,pnl:-110
% id: 7,opentime: 14:28:09,direction: 1,price:113000,stoptime: 00:02:59,closetime: 14:34:13,pnl:-180
% id: 8,opentime: 14:30:02,direction: 1,price:112890,stoptime: 00:06:00,closetime: 14:36:55,pnl:-190
% id: 9,opentime: 14:33:10,direction: 1,price:112870,stoptime: 00:09:00,closetime: 14:37:05,pnl:-190
% id:10,opentime: 14:36:16,direction: 1,price:112790,stoptime: 00:11:59,closetime: 14:38:06,pnl:-190
