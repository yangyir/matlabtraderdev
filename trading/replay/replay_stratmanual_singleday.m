countername = 'citic_kim_fut';
bookname = 'book1';
markettype = 'futures';
strategyname = 'manual';
instruments = {'T1809'};
code = instruments{1};

combos = rtt_setup('CounterName',countername,'BookName',bookname,...
    'MarketType',markettype,'StrategyName',strategyname,'Instruments',instruments);
%%
% replay set up
replayspeed = 50;
checkdt = '2018-06-19';
replayfn = ['C:\yangyiran\regressiondata\',code,'_',datestr(checkdt,'yyyymmdd'),'_tick.mat'];

combos.mdefut.initreplayer('code',code,'fn',replayfn);
combos.mdefut.timer_interval_ = 0.5/replayspeed;
%
combos.ops.mode_ = 'replay';
combos.ops.timer_interval_ = 1/replayspeed;
%
combos.strategy.mode_ = 'replay';
combos.strategy.timer_interval_ = 1/replayspeed;

fprintf('\nready for replay with replay time at:%s...\n',combos.mdefut.replay_time2_);
%%
%test mdefut refresh in replay mode with fast replay speed
fastreplayspeed = 100;
combos.mdefut.timer_interval_ = 0.5/fastreplayspeed;
combos.mdefut.start;
%%
%test the manual trading at a lower replay speed
slowreplayspeed = 10;
combos.mdefut.timer_interval_ = 0.5/slowreplayspeed;
combos.ops.timer_interval_ = 1/slowreplayspeed;
combos.strategy.timer_interval_ = 1/slowreplayspeed;
combos.mdefut.start;
combos.strategy.start;
combos.ops.start;
%%
combos.strategy.longopensingleinstrument(code,1)
