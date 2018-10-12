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
combos.strategy.mode_ = 'replay';
combos.strategy.setavailablefund(1e6,'firstset',true);

%%
% replay set up
replayspeed = 1;
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
unit_base = 1; %volume to open per entrust of per instrument
unit_max = 3;  %maximum volume per instrument
combos.strategy.setmaxunits(code,unit_max);
combos.strategy.setbaseunits(code,unit_base);
%%
clc;
%always start the MDE first
combos.mdefut.start;
%%
%then we start the OPs
combos.ops.start;
%
%last we start the strategy
combos.strategy.start;
%%
%try to place an entrust
volume1 = 1;
combos.strategy.longopen(code,volume1,'spread',0);
%%
%try to place an limit order which is 20 spread lower then the current
%market
volume2 = 1;
combos.strategy.longopen(code,volume1,'spread',20);
%%
fprintf('\n');
currentmargin = combos.strategy.getcurrentmargin;
fprintf('%10s:%8s\n','currentmargin',num2str(round(currentmargin)));
%
availablefund = combos.strategy.getavailablefund;
fprintf('%10s:%8s\n','availablefund',num2str(round(availablefund)));
%
frozenmargin = combos.strategy.getfrozenmargin;
fprintf('%10s:%8s\n','frozenmargin',num2str(round(frozenmargin)));

%%
combos.mdefut.stop;
%%
delete(timerfindall);



