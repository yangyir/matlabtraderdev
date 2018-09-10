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
%test the manual trading at a lower replay speed
clc;
slowreplayspeed = 5;
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
volume = 1;
direction = 'b';
offset = 'open';
spread = 0;
price = 95.2;
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



