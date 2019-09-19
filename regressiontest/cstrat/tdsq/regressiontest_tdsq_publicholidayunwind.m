%%
try
    clc;
    delete(timerfindall);
catch
end
combo = rtt_setup('countername','ccb_ly_fut',...
    'bookname','tdsq-publicholiday',...
    'strategyname','tdsq',...
    'riskconfigfilename','config_tdsq_regressiontest.txt',...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate','2019-09-12','replaytodate','2019-09-12');
%
combo.mdefut.printflag_ = false;
combo.ops.printflag_ = true;
combo.ops.print_timeinterval_ = 15*60;
combo.strategy.printflag_ = false;
%%
combo.mdefut.start;
combo.ops.start;
combo.strategy.start;
%%
combo.mdefut.stop;
%%
timers = timerfindall;
fprintf('\n');
for i = 1:length(timers)
    fprintf('%25s:%3s\n',timers(i).name,timers(i).running);
end
    