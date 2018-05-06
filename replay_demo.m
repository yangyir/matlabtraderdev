replay_speed = 50;
replay_strat = replay_setstrat('wlpr','replayspeed',replay_speed);
%%
code = 'rb1810';
instrument = code2instrument(code);
replay_strat.mde_fut_.registerinstrument(instrument);
replay_strat.registerinstrument(instrument);
%%
fns = {'rb1810_20180423_tick.mat';'rb1810_20180424_tick.mat';...
    'rb1810_20180425_tick.mat';'rb1810_20180426_tick.mat';...
    'rb1810_20180427_tick.mat';'rb1810_20180502_tick.mat';...
    'rb1810_20180503_tick.mat';'rb1810_20180504_tick.mat'};
n = size(fns,1);
%%
replay_tradingfreq = 15;    % use 15m candle sticks
replay_strat.settradingfreq(instrument,replay_tradingfreq);
replay_autotrade = 1;
replay_strat.setautotradeflag(instrument,replay_autotrade);
%%
% load the tick data into replayer and the tick data is restricted to tick
% data on 2018-04-24
replay_strat.mde_fut_.initreplayer('code',code,'fn',fns{1});
%% double check whether the datevec of the candles is inline with the replay date
datestr(replay_strat.mde_fut_.candles_{1}(:,1))
%%
replay_strat.initdata;
%% double check whether the last history candle is inline with the replay date
datestr(replay_strat.mde_fut_.hist_candles_{1}(end,1))
%% print the latest wlpr, william percentage ratio
replay_strat.printinfo
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
    