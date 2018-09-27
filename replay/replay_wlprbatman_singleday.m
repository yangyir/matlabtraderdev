clc;delete(timerfindall);
fprintf('running replay of wlprbatman strategy on single instrument......\n\n');
%user inputs:
code = input('futures instrument = ');
checkdt = input('check date = ');
samplefreq = input('sample frequency = ');
reltarget = input('relative target = ');
relstoploss = input('relative stoploss = ');
fprintf('\n');
fprintf('instrument %s is selected for replay of wlprbatman strategy on %s with %s-minute sample frequency...\n',...
    code,datestr(checkdt,'yyyy-mm-dd'),num2str(samplefreq));

%%
replay_speed = 50;
replay_strat = replay_setstrat('wlprbatman','replayspeed',replay_speed);
replay_strat.registerinstrument(code);
replay_strat.setsamplefreq(code,samplefreq);
replay_strat.setautotradeflag(code,1);
replay_strat.setmaxunits(code,100);
replay_strat.setmaxexecutionperbucket(code,1);
replay_strat.setbandtarget(code,reltarget);
replay_strat.setbandstoploss(code,relstoploss);
%
fprintf('\nload tick data......\n')
replay_filename = [code,'_',datestr(checkdt,'yyyymmdd'),'_tick.txt'];
replay_strat.mde_fut_.initreplayer('code',code,'fn',replay_filename);
replay_strat.initdata;
replay_strat.mde_fut_.printflag_ = false;
replay_strat.helper_.print_timeinterval_ = 60*samplefreq;
replay_strat.helper_.savedir_ = 'c:\yangyiran\';
replay_strat.helper_.loaddir_ = 'c:\yangyiran\';
fprintf('\nreplay get ready......\n\n');
replay_strat.printinfo;

%%
close all;
ticks = replay_strat.mde_fut_.replayer_.tickdata_{1};
timeseries_plot(ticks(:,1:2),'dateformat','hh:mm','title',[code,'-',datestr(checkdt,'yyyymmdd')]);
%%
replay_strat.mde_fut_.start;
replay_strat.helper_.start; 
replay_strat.start;

%%
isrunning = strcmpi(replay_strat.mde_fut_.timer_.running,'on');
while( isrunning)
    pause(1);
    isrunning = strcmpi(replay_strat.mde_fut_.timer_.running,'on');
end
%%
if ~isrunning
    dir_data = replay_strat.helper_.savedir_;
    bookname = replay_strat.helper_.book_.bookname_;
    fn = [dir_data,bookname,'\',bookname,'_trades_',datestr(checkdt,'yyyymmdd'),'.txt'];
    try
        trades = cTradeOpenArray;
        trades.fromtxt(fn);
        ntrades = trades.latest_;
    catch
        ntrades = 0;
    end
    if ntrades > 0
        fprintf('\ntrades executed on %s daytime:\n',datestr(checkdt,'yyyymmdd'));
        totalpnl = 0;
        for j = 1:trades.latest_
            trade_j = trades.node_(j);
            if strcmpi(trade_j.status_,'closed')
                fprintf('\tid:%2d,opentime:%s,direction:%2d,openprice:%s,closeprice:%s,closetime:%s,pnl:%s\n',...
                    j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
                    num2str(trade_j.openprice_),...
                    num2str(trade_j.closeprice_),...
                    trade_j.closedatetime2_(end-8:end),...
                    num2str(trade_j.closepnl_));
            end
            totalpnl = totalpnl + trade_j.closepnl_;
        end
    
        fprintf('\ttotal pnl:%s\n',num2str(totalpnl));
    else
        fprintf('none trades executed on %s...\n',datestr(checkdt,'yyyymmdd'));
    end
    %
    trades = replay_strat.helper_.trades_;
    ntrades = trades.latest_;
    carriedtrades = cTradeOpenArray;
    if ntrades > 0
        fprintf('\ntrades executed in the evening....\n');
        totalpnl = 0;
        for j = 1:trades.latest_
            trade_j = trades.node_(j);
            if strcmpi(trade_j.status_,'closed')
                fprintf('\tid:%2d,opentime:%s,direction:%2d,openprice:%s,closeprice:%s,closetime:%s,pnl:%s\n',...
                    j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
                    num2str(trade_j.openprice_),...
                    num2str(trade_j.closeprice_),...
                    trade_j.closedatetime2_(end-8:end),...
                    num2str(trade_j.closepnl_));
            else
                carriedtrades.push(trade_j);
            end
            totalpnl = totalpnl + trade_j.closepnl_;
        end
        fprintf('\ttotal pnl:%s\n',num2str(totalpnl));
    else
        fprintf('none trades executed in the evening so far...\n');
    end
    
    ncarriedtrades = carriedtrades.latest_;
    if ncarriedtrades > 0
        fprintf('\ntrades carried from the evening....\n');
        for j = 1:ncarriedtrades;
            trade_j = carriedtrades.node_(j);
                fprintf('\tid:%2d,opentime:%s,direction:%2d,openprice:%s,stoptime:%s,pnl:%s\n',...
                    j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
                    num2str(trade_j.openprice_),...
                    trade_j.stopdatetime2_(end-8:end),...
                    num2str(trade_j.runningpnl_));
        end
    end
end
