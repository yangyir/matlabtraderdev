%% create config file
try
    clear;clc;
    delete(timerfindall);
catch
end
%
codes = {'TL2406'};
for i = 1:length(codes)
    addpath([getenv('DATAPATH'),'ticks\',codes{i}]);
    addpath([getenv('DATAPATH'),'intradaybar\',codes{i}]);
end
path_ = [getenv('HOME'),'\regressiontest\cstrat\fractal\'];
cd(path_);
bookname = 'govtbond_tl_15m';
strategyname = 'fractal';
riskconfigfilename = 'config_govtbond_tl_15m.txt';
genconfigfile(strategyname,[path_,riskconfigfilename],'instruments',codes);
for i = 1:length(codes)
modconfigfile([path_,riskconfigfilename],'code',codes{i},...
    'propnames',{'nfractals';'samplefreq';'baseunits';'maxunits';'riskmanagername';'autotrade';'usefractalupdate'},...
    'propvalues',{4;'15m';1;1;'spiderman';1;0});
end
%
combo = rtt_setup('countername','ccb_ly_fut',...
    'bookname',bookname,...
    'strategyname',strategyname,...
    'riskconfigfilename',riskconfigfilename,...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate','2024-03-01','replaytodate','2024-03-08');
combo.strategy.displaysignalonly_ = false;
combo.mdefut.printflag_ = true;combo.mdefut.print_timeinterval_ =  15*60;
combo.ops.printflag_ = true;
combo.ops.print_timeinterval_ = 15*60;
combo.strategy.printflag_ = false;
combo.strategy.load_kelly_intraday('directory',[getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\'],...
    'filename','strat_govtbondfut_15m.mat');
set(0,'DefaultFigureWindowStyle','docked');
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
