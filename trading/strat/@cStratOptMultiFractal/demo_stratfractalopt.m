strategyname = 'fractalopt';
path_ = [getenv('HOME'),'\trading\strat\@cStratOptMultiFractal\'];
riskconfigfilename = 'config_eqindexfutwithopt_5m.txt';
codes = {'MO2509-C-7300';'MO2509-P-7100'};
addpath([getenv('DATAPATH'),'ticks\IM2509\']);
addpath([getenv('DATAPATH'),'intradaybar\IM2509\']);
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
% strat = cStratOptMultiFractal;

% mdefut = cMDEFut;
% mdeopt = cMDEOpt;

% strat.registermdefut(mdefut);
% strat.registermdeopt(mdeopt);


% strat.loadriskcontrolconfigfromfile('filename',[path_,riskconfigfilename]);
%%
% strat.initdata;
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
    'markettype','options',...
    'riskconfigfilename',[path_,riskconfigfilename],...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate',dt1,'replaytodate',dt2);

regressiontestcombo.strategy.loadkellytable('directory',[getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\'],...
    'filename','strat_eqindexfut_m5.mat');

regressiontestcombo.mdefut.printflag_ = true;
regressiontestcombo.mdefut.print_timeinterval_ =  5*60;
regressiontestcombo.ops.printflag_ = true;
regressiontestcombo.ops.print_timeinterval_ = 5*60;
regressiontestcombo.strategy.printflag_ = false;

set(0,'DefaultFigureWindowStyle','docked');


%%
regressiontestcombo.mdefut.start;
regressiontestcombo.mdeopt.start;
regressiontestcombo.ops.start;
regressiontestcombo.strategy.start;
%%
regressiontestcombo.mdefut.stop;
