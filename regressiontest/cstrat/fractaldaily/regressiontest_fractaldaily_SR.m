%% create config file
try
    clear;clc;
    delete(timerfindall);
catch
end
%
codes = {'SR401'};
path_ = [getenv('HOME'),'\regressiontest\cstrat\fractaldaily\'];
cd(path_);
for i = 1:size(codes,1)
    addpath([getenv('DATAPATH'),'intradaybar\',codes{i},'\']);
    addpath([getenv('DATAPATH'),'ticks\',codes{i},'\']);
end
cd(path_);
bookname = 'daily_sugar';
strategyname = 'fractal';
riskconfigfilename = 'daily_config_sugar.txt';
genconfigfile(strategyname,[path_,riskconfigfilename],'instruments',codes);
for i = 1:length(codes)
modconfigfile([path_,riskconfigfilename],'code',codes{i},...
    'propnames',{'nfractals';'samplefreq';'baseunits';'maxunits';'riskmanagername';'autotrade';'usefractalupdate'},...
    'propvalues',{2;'1440m';1;1;'spiderman';1;0});
end
%
combo = rtt_setup('countername','ccb_ly_fut',...
    'bookname',bookname,...
    'strategyname',strategyname,...
    'riskconfigfilename',riskconfigfilename,...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate','2023-09-07','replaytodate','2023-09-07');
combo.strategy.displaysignalonly_ = false;
combo.mdefut.printflag_ = true;combo.mdefut.print_timeinterval_ = 30*60;
combo.ops.printflag_ = true;
combo.ops.print_timeinterval_ = 30*60;
combo.strategy.printflag_ = false;
combo.strategy.load_kelly_daily('directory','C:\Users\yiran\OneDrive\fractal backtest\kelly distribution\matlab\comdty_domestic\',...
    'filename','strat_comdty_domestic_daily_2023w37.mat');
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
set(0,'DefaultFigureWindowStyle','docked');
mde_fin_plot(combo.mdefut);
