%% create config file
try
    clear;clc;
    delete(timerfindall);
catch
end
%
codes = {'p2101'};
path_ = [getenv('HOME'),'\regressiontest\cstrat\fractal\'];
cd(path_);
bookname = 'book11';
strategyname = 'fractal';
riskconfigfilename = 'config_book11.txt';
genconfigfile(strategyname,[path_,riskconfigfilename],'instruments',codes);
for i = 1:length(codes)
modconfigfile([path_,riskconfigfilename],'code',codes{i},...
    'propnames',{'nfractals';'samplefreq';'baseunits';'maxunits';'riskmanagername';'autotrade'},...
    'propvalues',{4;'30m';1;1;'spiderman';1});
end
%
combo = rtt_setup('countername','ccb_ly_fut',...
    'bookname',bookname,...
    'strategyname',strategyname,...
    'riskconfigfilename',riskconfigfilename,...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate','2020-11-02','replaytodate','2020-11-02');
combo.strategy.displaysignalonly_ = false;
combo.mdefut.printflag_ = true;combo.mdefut.print_timeinterval_ = 30*60;
combo.ops.printflag_ = true;combo.ops.print_timeinterval_ = 30*60;
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
combo.ops.condentrustspending_.latest
%%
mde_fin_plot(combo.mdefut);
