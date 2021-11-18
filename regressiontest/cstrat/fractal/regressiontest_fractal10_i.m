%% create config file
try
    clear;clc;
    delete(timerfindall);
catch
end
%
<<<<<<< Updated upstream
codes = {'i2201'};
=======
codes = {'i2105'};
>>>>>>> Stashed changes
path_ = [getenv('HOME'),'\regressiontest\cstrat\fractal\'];
for i = 1:length(codes)
    addpath([getenv('DATAPATH'),'\intradaybar\',codes{i},'\']);
    addpath([getenv('DATAPATH'),'\ticks\',codes{i},'\']);
end
cd(path_);
bookname = 'ironore';
strategyname = 'fractal';
riskconfigfilename = 'config_ironore.txt';
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
<<<<<<< Updated upstream
    'replayfromdate','2021-10-21','replaytodate','2021-10-21');
=======
    'replayfromdate','2021-03-22','replaytodate','2021-03-22');
>>>>>>> Stashed changes
combo.strategy.displaysignalonly_ = false;
combo.mdefut.printflag_ = true;combo.mdefut.print_timeinterval_ = 30*60;
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
combo.ops.condentrustspending_.latest
%%
mde_fin_plot(combo.mdefut);
