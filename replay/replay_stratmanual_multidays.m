clear all;clc
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
replayfns = cell(4,1);
replayfns{1,1} = ['C:\yangyiran\regressiondata\',code,'_20180619_tick.mat'];
replayfns{2,1} = ['C:\yangyiran\regressiondata\',code,'_20180620_tick.mat'];
replayfns{3,1} = ['C:\yangyiran\regressiondata\',code,'_20180621_tick.mat'];
replayfns{4,1} = ['C:\yangyiran\regressiondata\',code,'_20180622_tick.mat']; 

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
%test the manual trading at a lower replay speed
clc;
slowreplayspeed = 20;
combos.mdefut.settimerinterval(0.5/slowreplayspeed);
combos.ops.settimerinterval(1/slowreplayspeed);
combos.strategy.settimerinterval(1/slowreplayspeed);
%always start the MDE first
combos.mdefut.start;
%%
%then we start the OPs
combos.ops.start;
%%
%last we start the strategy
combos.strategy.start;
%%
signalinfo = struct('name','manual');
volume = 6;
direction = 's';
offset = 'close';
spread = 0;
price = 95.615;
closetoday = 1;
if strcmpi(direction,'b') && strcmpi(offset,'open')
    combos.strategy.longopensingleinstrument(code,volume,spread,'overrideprice',price,'signalinfo',signalinfo);
elseif strcmpi(direction,'s') && strcmpi(offset,'open')
    combos.strategy.shortopensingleinstrument(code,volume,spread,'overrideprice',price,'signalinfo',signalinfo);
elseif strcmpi(direction,'b') && strcmpi(offset,'close')    
    combos.strategy.longclosesingleinstrument(code,volume,closetoday,spread,'overrideprice',price);
elseif strcmpi(direction,'s') && strcmpi(offset,'close')
    combos.strategy.shortclosesingleinstrument(code,volume,closetoday,spread,'overrideprice',price);
end
%%
combos.strategy.withdrawentrusts(code,'time',combos.mdefut.getreplaytime);
%%
combos.mdefut.stop;
%%
delete(timerfindall);



