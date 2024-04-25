%% create config file
try
    clear;clc;
    delete(timerfindall);
catch
end
%
codes = {'cu2404';'al2404';'zn2404';'pb2404';'ni2405';'sn2404'};
lots = [1;2;2;2;1;1];
for i = 1:length(codes)
    addpath([getenv('DATAPATH'),'ticks\',codes{i}]);
    addpath([getenv('DATAPATH'),'intradaybar\',codes{i}]);
end
path_ = [getenv('HOME'),'\regressiontest\cstrat\fractal\'];
cd(path_);
bookname = 'basemetals';
strategyname = 'fractal';
riskconfigfilename = 'config_basemetals.txt';
genconfigfile(strategyname,[path_,riskconfigfilename],'instruments',codes);
for i = 1:length(codes)
modconfigfile([path_,riskconfigfilename],'code',codes{i},...
    'propnames',{'nfractals';'samplefreq';'baseunits';'maxunits';'riskmanagername';'autotrade'},...
    'propvalues',{4;'30m';lots(i);lots(i);'spiderman';1});
end
%
combo = rtt_setup('countername','ccb_ly_fut',...
    'bookname',bookname,...
    'strategyname',strategyname,...
    'riskconfigfilename',riskconfigfilename,...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate','2024-02-29','replaytodate','2024-02-29');
combo.strategy.displaysignalonly_ = false;
combo.mdefut.printflag_ = true;combo.mdefut.print_timeinterval_ = 30*60;
combo.ops.printflag_ = true;
combo.ops.print_timeinterval_ = 30*60;
combo.strategy.printflag_ = false;
combo.mdefut.showfigures_ = false;
combo.strategy.load_kelly_intraday('directory',[getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\'],'filename','strat_comdty_i.mat');
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
