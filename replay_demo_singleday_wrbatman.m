clear all;clc;
replay_speed = 5;
replay_strat = replay_setstrat('wlprbatman','replayspeed',replay_speed);
%%
code = 'ni1809';
instr = code2instrument(code);
replay_strat.mde_fut_.registerinstrument(instr);
replay_strat.registerinstrument(instr);
replay_samplefreq = 3;    % use 3m candle sticks
replay_strat.setsamplefreq(instr,replay_samplefreq);
replay_autotrade = 1;   % use autotrade
replay_strat.setautotradeflag(instr,replay_autotrade);
replay_maxunits = 100;
replay_strat.setmaxunits(instr,replay_maxunits);
replay_maxexecutionperbucket = 1;
replay_strat.setmaxexecutionperbucket(instr,replay_maxexecutionperbucket);

%%
replay_dt = '2018-06-19';
replay_filename = [code,'_',datestr(replay_dt,'yyyymmdd'),'_tick.txt'];
replay_strat.mde_fut_.initreplayer('code',code,'fn',replay_filename);
%% double check whether the datevec of the candles is inline with the replay date
% datestr(replay_strat.mde_fut_.candles_{1}(:,1))
%%
replay_strat.initdata;
%% double check whether the last history candle is inline with the replay date
% datestr(replay_strat.mde_fut_.hist_candles_{1}(end,1))
%% print the latest wlpr, william percentage ratio
replay_strat.printinfo;
%%
replay_strat.mde_fut_.replay_count_ = 1;
%% start the trading (replay) process
replay_strat.start;
replay_strat.helper_.start; 
replay_strat.mde_fut_.start;
%% 
replay_strat.helper_.book_.printpositions;
%%
replay_strat.helper_.printrunningpnl('MDEFut',replay_strat.mde_fut_);
%% print all entrusts
replay_strat.helper_.printallentrusts;
%%
tbl = replay_strat.helper_.trades_.totable;
disp(tbl)
%% delete all in a safe way
try
    replay_strat.stop;
    replay_strat.helper_.stop;
    replay_strat.mde_fut_.stop;
    delete(timerfindall);
catch
    clear all;
    fprintf('all deleted\n');
end
    