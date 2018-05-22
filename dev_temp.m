mde = cMDEFut;
code = 'rb1810';
inst = code2instrument(code);
mde.registerinstrument(inst);
mde.candle_freq_ = 15;
mde.display_ = 1;
%%
fns = {'rb1810_20180423_tick';...
    'rb1810_20180424_tick';...
    'rb1810_20180425_tick';...
    'rb1810_20180426_tick';...
    'rb1810_20180427_tick';...
    'rb1810_20180502_tick';...
    'rb1810_20180503_tick';...
    'rb1810_20180504_tick';...
    'rb1810_20180507_tick';...
    'rb1810_20180508_tick';...
    'rb1810_20180509_tick';...
    'rb1810_20180510_tick';...
    'rb1810_20180511_tick';...
    'rb1810_20180514_tick';...
    'rb1810_20180515_tick';......
    'rb1810_20180516_tick'};
mde.initreplayer('code',code,'filenames',fns);
%%
mde.initcandles;
%%
replay_speed = 60000;
mde.timer_interval_ = 60/ replay_speed;
%%
clc;
mde.replay_count_ = 39015;
mde.start
%%
ticks = mde.getlasttick(inst);
fprintf('time:%s price:%s\n',datestr(ticks(1),'yyyy-mm-dd HH:MM:SS'),num2str(ticks(2)));
%%
mde.stop;
delete(timerfindall)
