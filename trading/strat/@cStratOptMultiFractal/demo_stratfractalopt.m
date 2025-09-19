strategyname = 'fractalopt';
path_ = [getenv('HOME'),'\trading\strat\@cStratOptMultiFractal\'];
riskconfigfilename = 'config_eqindexfutwithopt_5m.txt';
call = 'MO2509-C-7300';
put = 'MO2509-P-7100';
codes = {'IM2509'};
baseunits = 1;
for i = 1:length(codes)
    addpath([getenv('DATAPATH'),'ticks\',codes{i}]);
    addpath([getenv('DATAPATH'),'intradaybar\',codes{i}]);
end
genconfigfile(strategyname,[path_,riskconfigfilename],'instruments',codes);
%
for i = 1:length(codes)
    modconfigfile([path_,riskconfigfilename],'code',codes{i},...
        'propnames',{'nfractals';'samplefreq';'baseunits';'maxunits';'riskmanagername';'autotrade';'usefractalupdate'},...
        'propvalues',{6;'5m';baseunits;baseunits;'spiderman';1;0});
end
%%
try
    delete(timerfindall);
catch
end

dt1 = '2025-09-11';
dt2 = '2025-09-11';
regressiontestcombo = rtt_setup('countername','ccb_ly_fut',...
    'bookname','fractaloptdemo',...
    'strategyname','fractalopt',...
    'markettype','futures',...
    'riskconfigfilename',[path_,riskconfigfilename],...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate',dt1,'replaytodate',dt2);

regressiontestcombo.strategy.load_kelly_intraday('directory',[getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\'],...
    'filename','strat_eqindexfut_m5.mat');

regressiontestcombo.mdefut.printflag_ = true;
regressiontestcombo.mdefut.print_timeinterval_ =  5*60;
regressiontestcombo.ops.printflag_ = true;
regressiontestcombo.ops.print_timeinterval_ = 5*60;
regressiontestcombo.strategy.printflag_ = false;

set(0,'DefaultFigureWindowStyle','docked');


%%
regressiontestcombo.mdefut.start;
regressiontestcombo.ops.start;
regressiontestcombo.strategy.start;
%%
regressiontestcombo.mdefut.stop;
