clear all;clc;delete(timerfindall);
%%
countername = 'citic_kim_fut';
bookname = 'book1';
markettype = 'futures';
strategyname = 'manual';
instruments = {'T1809'};
filename = 'C:\yangyiran\ops\save\citic_kim_fut-book1\citic_kim_fut-book1_trades_20180619.txt';
code = instruments{1};
%assume we have finished trading on 20180619 and we load open trades, i.e.
%trades not closed yet to init the carry positions
combos = rtt_setup('CounterName',countername,'BookName',bookname,...
    'MarketType',markettype,'StrategyName',strategyname,'Instruments',instruments,...
    'TradesFileName',filename);
fprintf('The Carried Position as of 20180619......\n');
combos.ops.book_.printpositions;
ncarry_20180619 = combos.book.positions_{1}.position_total_;
fprintf('\ncombos successfully created...\n');
%%
% replay set up
replayspeed = 50;
replayfns = {['C:\yangyiran\regressiondata\',code,'_20180620_tick.mat'];...
    ['C:\yangyiran\regressiondata\',code,'_20180621_tick.mat'];...
    ['C:\yangyiran\regressiondata\',code,'_20180622_tick.mat']};
combos.mdefut.initreplayer('code',code,'filenames',replayfns);
combos.mdefut.settimerinterval(0.5/replayspeed);
%
combos.ops.mode_ = 'replay';
combos.ops.settimerinterval(1/replayspeed);
%
combos.strategy.mode_ = 'replay';
combos.strategy.settimerinterval(1/replayspeed);
fprintf('\nready for replay with replay time at:%s...\n',combos.mdefut.replay_time2_);

%%
%always start the MDE first
combos.mdefut.start;
%%
%then we start the OPs
combos.ops.start;
%
%last we start the strategy
combos.strategy.start;
%
replay_stratmanual_multidays_executionscript;

%%
combos.mdefut.stop;
%%
delete(timerfindall);
%%
data =  combos.mdefut.replayer_.tickdata_;data = data{1};
figure(1),plot(data(:,2));title(combos.mdefut.replay_date2_);


