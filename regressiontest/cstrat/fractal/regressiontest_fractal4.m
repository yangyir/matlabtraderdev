%%
try
    clear;clc;
    delete(timerfindall);
catch
end
combo = rtt_setup('countername','ccb_ly_fut',...
    'bookname','bookfractal',...
    'strategyname','fractal',...
    'riskconfigfilename','config_fractal4.txt',...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate','2020-04-03','replaytodate','2020-04-03');
combo.strategy.displaysignalonly_ = false;
combo.mdefut.printflag_ = false;
combo.ops.printflag_ = true;
combo.ops.print_timeinterval_ = 30*60;
combo.strategy.printflag_ = false;
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
%%
pnl = fractal_backtest(p(:,1:5),4,'code','IH2003','freq','30m','volatilityperiod',0);