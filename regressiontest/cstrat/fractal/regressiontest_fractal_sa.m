%% create config file
try
    clear combo;
    delete(timerfindall);
catch
end
%
codes = {'SA409'};
path_ = [getenv('HOME'),'\regressiontest\cstrat\fractal\'];
cd(path_);
for i = 1:size(codes,1)
    addpath([getenv('DATAPATH'),'intradaybar\',codes{i},'\']);
    addpath([getenv('DATAPATH'),'ticks\',codes{i},'\']);
end
cd(path_);
bookname = 'sodaash';
strategyname = 'fractal';
riskconfigfilename = 'config_sodaash.txt';
genconfigfile(strategyname,[path_,riskconfigfilename],'instruments',codes);
for i = 1:length(codes)
modconfigfile([path_,riskconfigfilename],'code',codes{i},...
    'propnames',{'nfractals';'samplefreq';'baseunits';'maxunits';'riskmanagername';'autotrade';'usefractalupdate'},...
    'propvalues',{4;'30m';2;2;'spiderman';1;0});
end
%
combo = rtt_setup('countername','ccb_ly_fut',...
    'bookname',bookname,...
    'strategyname',strategyname,...
    'riskconfigfilenam',riskconfigfilename,...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate','2024-05-22','replaytodate','2024-05-24');
combo.strategy.displaysignalonly_ = false;
combo.mdefut.printflag_ = true;combo.mdefut.print_timeinterval_ = 30*60;
combo.ops.printflag_ = true;
combo.ops.print_timeinterval_ = 30*60;
combo.strategy.printflag_ = false;
combo.strategy.load_kelly_intraday('directory',[getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\'],...
    'filename','strat_comdty_i.mat');
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
set(0,'DefaultFigureWindowStyle','docked');
mde_fin_plot(combo.mdefut);
