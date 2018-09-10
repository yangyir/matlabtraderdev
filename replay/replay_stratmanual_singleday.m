clear all;clc;delete(timerfindall);
countername = 'citic_kim_fut';
bookname = 'book1';
markettype = 'futures';
strategyname = 'manual';
instruments = {'T1809'};
code = instruments{1};
combos = rtt_setup('CounterName',countername,'BookName',bookname,...
    'MarketType',markettype,'StrategyName',strategyname,'Instruments',instruments);
fprintf('\ncombos successfully created...\n');

%%
% replay set up
replayspeed = 50;
checkdt = '2018-06-19';
replayfn = ['C:\yangyiran\regressiondata\',code,'_',datestr(checkdt,'yyyymmdd'),'_tick.mat'];

combos.mdefut.initreplayer('code',code,'fn',replayfn);
combos.mdefut.settimerinterval(0.5/replayspeed);
%
combos.ops.mode_ = 'replay';
combos.ops.settimerinterval(1/replayspeed);
%
combos.strategy.mode_ = 'replay';
combos.strategy.settimerinterval(1/replayspeed);

fprintf('\nready for replay with replay time at:%s...\n',combos.mdefut.replay_time2_);

%%
clc;
%always start the MDE first
combos.mdefut.start;
%%
%then we start the OPs
combos.ops.start;
%%
%last we start the strategy
combos.strategy.start;
%%
volume1 = 6;
volume2 = 2;
price1 = 95.095;
price2 = 95.115;
nentrusts = combos.ops.entrusts_.latest;
while nentrusts == 0
    combos.strategy.longopensingleinstrument(code,volume1,0,'overrideprice',price1);
    combos.strategy.longopensingleinstrument(code,volume2,0,'overrideprice',price2);
    nentrusts = combos.ops.entrusts_.latest;
end

closetoday = 1;
nfinished = combos.ops.entrustsfinished_.latest;
while nfinished ~= 2
    pause(10);
    nfinished = combos.ops.entrustsfinished_.latest;
    if nfinished == 2
        break
    end
end
combos.strategy.shortclosesingleinstrument(code,1,closetoday,0,'overrideprice',price2+0.4);
combos.strategy.shortclosesingleinstrument(code,1,closetoday,0,'overrideprice',price2+0.45);

%%
combos.strategy.withdrawentrusts(code,'time',combos.mdefut.getreplaytime);
%%
combos.mdefut.stop;
%%
delete(timerfindall);



