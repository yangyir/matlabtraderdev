strategyname = 'fractalopt';
path_ = [getenv('HOME'),'\trading\strat\@cStratOptMultiFractal\'];
riskconfigfilename = 'config_eqindexfutwithopt_5m.txt';
options = {'MO2510-C-7600';'MO2510-P-7500'};
underlier = 'IM2510';
baseunits = 1;
for i = 1:length(options)
    addpath([getenv('DATAPATH'),'ticks\',options{i}]);
    addpath([getenv('DATAPATH'),'intradaybar\',options{i}]);
end
addpath([getenv('DATAPATH'),'ticks\',underlier]);
addpath([getenv('DATAPATH'),'intradaybar\',underlier]);

genconfigfile(strategyname,[path_,riskconfigfilename],'instruments',options);
%
for i = 1:length(options)
    modconfigfile([path_,riskconfigfilename],'code',options{i},...
        'propnames',{'nfractals';'samplefreq';'baseunits';'maxunits';'riskmanagername';'autotrade';'usefractalupdate'},...
        'propvalues',{6;'5m';baseunits;baseunits;'spiderman';1;0});
end
%%
mdeopt = cMDEOpt;
strat = cStratOptMultiFractal;
strat.registermdeopt(mdeopt);
strat.loadriskcontrolconfigfromfile('filename',[path_,riskconfigfilename]);
strat.call_ = options{1};
strat.put_ = options{2};
dt = '20251010';
fn1 = [getenv('datapath'),'ticks\',underlier,'\',underlier,'_',dt,'_tick.txt'];
fn2 = [getenv('datapath'),'ticks\',options{1},'\',options{1},'_',dt,'_tick.txt'];
fn3 = [getenv('datapath'),'ticks\',options{2},'\',options{2},'_',dt,'_tick.txt'];
mdeopt.initreplayer('code',underlier,'fn',fn1);fprintf('loading of %s is finished...\n',underlier)
mdeopt.initreplayer('code',options{1},'fn',fn2);fprintf('loading of %s is finished...\n',options{1});
mdeopt.initreplayer('code',options{2},'fn',fn3);fprintf('loading of %s is finished....\n',options{2});
mdeopt.mode_ = 'replay';
strat.mode_ = 'replay';
%
strat.initdata;
%
strat.load_kelly_intraday('directory',[getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\'],...
    'filename','strat_eqindexfut_m5.mat');
strat.setavailablefund(1e6,'firstset',true);
%
helper = cOps('Name','irene');
helper.registermdeopt(mdeopt);
book = cBook('BookName','book1','CounterName','ccb_ly_fut');
helper.registerbook(book);
helper.mode_ = 'replay';
strat.registerhelper(helper);
%%
speedadj = 50;
mdeopt.settimerinterval(0.5/speedadj);
helper.settimerinterval(0.1/speedadj);
strat.settimerinterval(0.5/speedadj);
mdeopt.showfigures_ = false;
mdeopt.printflag_ = true;mdeopt.print_timeinterval_ = 5*60;
helper.printflag_ = true;helper.print_timeinterval_ = 5*60;
strat.printflag_ = false;
mdeopt.start;
strat.start;
helper.start;
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
