clc;
%user inputs:
code = input('futures instrument = ');
checkdt = input('check date = ');
samplefreq = input('sample frequency = ');

%%
replay_speed = 50;
replay_strat = replay_setstrat('wlprbatman','replayspeed',replay_speed);
replay_strat.registerinstrument(code);
replay_strat.setsamplefreq(code,samplefreq);
replay_strat.setautotradeflag(code,1);
replay_strat.setmaxunits(code,100);
replay_strat.setmaxexecutionperbucket(code,1);
replay_strat.setbandtarget(code,0.02);
replay_strat.setbandstoploss(code,0.01);
%
replay_filename = [code,'_',datestr(checkdt,'yyyymmdd'),'_tick.txt'];
replay_strat.mde_fut_.initreplayer('code',code,'fn',replay_filename);
replay_strat.initdata;
replay_strat.mde_fut_.printflag_ = false;
replay_strat.helper_.print_timeinterval_ = 60*samplefreq;
fprintf('replay get ready......\n');
%%
clc;
replay_strat.mde_fut_.start;
replay_strat.helper_.start; 
replay_strat.start;

while strcmpi(replay_strat.mde_fut_.timer_.running,'on')
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
% id: 1,opentime: 09:04:50,direction: 1,price:114090,stoptime: 14:54:00,closetime: 09:06:05,pnl:-610
% id: 2,opentime: 09:06:01,direction: 1,price:113470,stoptime: 14:57:00,closetime: 09:48:01,pnl:510
% id: 3,opentime: 14:12:51,direction: 1,price:113400,stoptime: 23:48:00,closetime: 14:15:01,pnl:-140
% id: 4,opentime: 14:15:18,direction: 1,price:113260,stoptime: 23:51:00,closetime: 14:18:02,pnl:-140
% id: 5,opentime: 14:18:04,direction: 1,price:113120,stoptime: 23:54:00,closetime: 14:21:10,pnl:-90
% id: 6,opentime: 14:26:06,direction: 1,price:113010,stoptime: 00:00:00,closetime: 14:28:29,pnl:-40
% id: 7,opentime: 14:28:20,direction: 1,price:113000,stoptime: 00:03:00,closetime: 14:30:02,pnl:-100
% id: 8,opentime: 14:30:04,direction: 1,price:112890,stoptime: 00:06:00,closetime: 14:33:25,pnl:-50
% id: 9,opentime: 14:33:16,direction: 1,price:112870,stoptime: 00:09:00,closetime: 14:36:06,pnl:-50
% id:10,opentime: 14:36:19,direction: 1,price:112790,stoptime: 00:12:00,closetime: 14:40:10,pnl:-200