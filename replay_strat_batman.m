replay_speed = 50;
replay_strat = replay_setstrat('batman','replayspeed',replay_speed);
%%
code = 'rb1810';
instrument = code2instrument(code);
replay_strat.mde_fut_.registerinstrument(instrument);
replay_strat.registerinstrument(instrument);
%%
<<<<<<< HEAD
fns = {'rb1810_20180522_tick.mat'};
n = size(fns,1);
=======
fns = {'rb1810_20180522_tick.mat';};
n = size(fns,1);
% load the tick data into replayer and the tick data is restricted to tick
% data on 2018-05-22
>>>>>>> c49191705c205d0cda0b8ecb6161bb96b63e9bba
replay_strat.mde_fut_.initreplayer('code',code,'fn',fns{1});
%% start the trading (replay) process
replay_strat.start;
replay_strat.helper_.start;
replay_strat.mde_fut_.start;
<<<<<<< HEAD

%%
lots = 1;
spreads = 0;
px = 3600;
pxstoploss = 3620;
pxtarget = 3580;
%sanity check
if px >= pxstoploss, error('stoploss shall be above open price when to short the asset!');end
if px <= pxtarget, error('target shall be below open price when to short the asset!');end
%
replay_strat.shortopensingleinstrument(code,lots,spreads,'overrideprice',px);
replay_strat.setpxstoploss(code,pxstoploss);
replay_strat.setpxtarget(code,pxtarget);

%%
replay_strat.helper_.printrunningpnl('MDEFut',replay_strat.mde_fut_);
fprintf('high:%s\n',num2str(replay_strat.getpxhigh(code)))
fprintf('withdrawmin:%s\n',num2str(replay_strat.getpxwithdrawmin(code)))
fprintf('withdrawmax:%s\n',num2str(replay_strat.getpxwithdrawmax(code)))
=======

%% short open positions
lots_short_open = 1;
spreads_short_open = 0;
px = 3600;
pxstoploss = 3620;
pxtarget = 3580;
%sanity check
if px >= pxstoploss, error('stoploss shall be above open price when to short the asset!');end
if px <= pxtarget, error('target shall be below open price when to short the asset!');end
%
replay_strat.shortopensingleinstrument(code,lots_short_open,spreads_short_open,'overrideprice',px);
replay_strat.setpxstoploss(code,pxstoploss);
replay_strat.setpxtarget(code,pxtarget);

%%
replay_strat.helper_.printrunningpnl('MDEFut',replay_strat.mde_fut_);
fprintf('high:%s\n',num2str(replay_strat.getpxhigh(code)));
fprintf('withdrawmin:%s\n',num2str(replay_strat.getpxwithdrawmin(code)));
fprintf('withdrawmax:%s\n',num2str(replay_strat.getpxwithdrawmax(code)));

>>>>>>> c49191705c205d0cda0b8ecb6161bb96b63e9bba
%% print all entrusts
replay_strat.helper_.printallentrusts;
%% delete all in a safe way
try
    replay_strat.stop;
    replay_strat.helper_.stop;
    replay_strat.mde_fut_.stop;
    delete(timerfindall);
<<<<<<< HEAD
    clear all;
=======
>>>>>>> c49191705c205d0cda0b8ecb6161bb96b63e9bba
catch
    clear all;
    fprintf('all deleted\n');
end
    