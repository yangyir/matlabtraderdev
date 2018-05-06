%%
replay_strat = replay_setstrat('wlpr','replayspeed',50);
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
replay_tradingfreq = 15;
replay_strat.settradingfreq(instrument,replay_tradingfreq);
replay_strat.setautotradeflag(instrument,1);
%%
replay_strat.mde_fut_.initreplayer('code',code,'fn',fns{1});
%%
replay_strat.initdata;
%%
replay_strat.printinfo
%%
replay_strat.helper_.book_.printpositions;
%%
replay_strat.pnl_running_
%%
replay_strat.start;
replay_strat.helper_.start;
replay_strat.mde_fut_.start;
%%
ticks = replay_strat.mde_fut_.getlasttick(instrument);
fprintf('last tick time:%s; trade:%s\n',datestr(ticks(1),'yyyy-mm-dd HH:MM:SS'),num2str(ticks(2)));
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
    