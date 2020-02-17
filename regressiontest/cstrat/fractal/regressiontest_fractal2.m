%%
try
    clear;clc;
    delete(timerfindall);
catch
end
combo = rtt_setup('countername','ccb_ly_fut',...
    'bookname','bookfractal',...
    'strategyname','fractal',...
    'riskconfigfilename','config_fractal_regressiontest.txt',...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate','2020-02-11','replaytodate','2020-02-12');
combo.strategy.displaysignalonly_ = false;
combo.mdefut.printflag_ = false;
combo.ops.printflag_ = true;
combo.ops.print_timeinterval_ = 15*60;
combo.strategy.printflag_ = false;
%%
db = cLocal;
p = db.intradaybar(code2instrument('p2005'),'2020-01-23','2020-02-17',15,'trade');
outputmat = tools_technicalplot1(p,6,1);
%%
candlesticks = combo.mdefut.getallcandles('p2005');
p = candlesticks{1};
outputmat = tools_technicalplot1(p,combo.mdefut.nfractals_(1),1);
%%
combo.mdefut.start;
combo.ops.start;
combo.strategy.start;
%%
combo.mdefut.stop
%%
timers = timerfindall;
fprintf('\n');
for i = 1:length(timers)
    fprintf('%25s:%3s\n',timers(i).name,timers(i).running);
end