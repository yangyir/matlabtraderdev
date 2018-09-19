%user inputs:
clear;clc;
code = 'ni1809';
startdt = '2018-06-14';
enddt = '2018-06-19';
checkdt = '2018-06-19';
trade_freq = 3;
stop_nperiod = 72;

%%
replay_speed = 50;
replay_strat = replay_setstrat('batman','replayspeed',replay_speed);
replay_strat.registerinstrument(code);
replay_strat.setsamplefreq(code,trade_freq);
%
replay_filename = ['C:\yangyiran\regressiondata\',code,'_',datestr(checkdt,'yyyymmdd'),'_tick.mat'];
replay_strat.mde_fut_.initreplayer('code',code,'fn',replay_filename);
replay_strat.initdata;
replay_strat.mde_fut_.printflag_ = true;
replay_strat.helper_.print_timeinterval_ = 60*trade_freq;
clc;
fprintf('replay get ready......\n');
%%
clc;
replay_strat.mde_fut_.start;
replay_strat.helper_.start; 
replay_strat.start;

%%
price = 114500;
target = 114000;
stoploss = 115000;
replay_strat.placeentrust(code,'buysell','s','price',price,'volume',3,'target',target,'stoploss',stoploss);

%%
try
    replay_strat.mde_fut_.stop;
    delete(timerfindall);
catch
    clear all;
    fprintf('all deleted\n');
end
