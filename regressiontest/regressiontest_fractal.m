function [regressiontestcombo] = regressiontest_fractal(varargin)
%regressiontest of our best performed fractal strategy
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('code','',@ischar);
p.addParameter('datefrom','',@ischar);
p.addParameter('dateto','',@ischar);
p.addParameter('frequency','30m',@ischar);
p.addParameter('kellytabledir','',@ischar);
p.addParameter('kellytablename','',@ischar);
p.parse(varargin{:});
code = p.Results.code;
dt1 = p.Results.datefrom;
dt2 = p.Results.dateto;
freq = p.Results.frequency;
kellytbldir = p.Results.kellytabledir;
kellytblname = p.Results.kellytablename;


addpath([getenv('DATAPATH'),'ticks\',code]);
addpath([getenv('DATAPATH'),'intradaybar\',code]);

path_ = [getenv('HOME'),'\regressiontest\cstrat\fractal\'];
cd(path_);

bookname = ['regressiontest_',code,'_',freq];
strategyname = 'fractal';
riskconfigfilename = ['config_',code,'_',freq,'.txt'];
genconfigfile(strategyname,[path_,riskconfigfilename],'instruments',{code});

if strcmpi('freq','5m')
    nfractal = 6;
    displayfreq = 5;
elseif strcmpi(freq,'15m')
    nfractal = 4;
    displayfreq = 15;
elseif strcmpi(freq,'30m')
    nfractal = 4;
    displayfreq = 30;
elseif strcmpi(freq,'daily')
    nfractal = 2;
    displayfreq = 30;
else
    nfractal = 2;
    displayfreq = 30;
end

modconfigfile([path_,riskconfigfilename],'code',code,...
    'propnames',{'nfractals';'samplefreq';'baseunits';'maxunits';'riskmanagername';'autotrade';'usefractalupdate'},...
    'propvalues',{nfractal;freq;1;1;'spiderman';1;0});

regressiontestcombo = rtt_setup('countername','ccb_ly_fut',...
    'bookname',bookname,...
    'strategyname',strategyname,...
    'riskconfigfilename',riskconfigfilename,...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate',dt1,'replaytodate',dt2);

regressiontestcombo.strategy.load_kelly_intraday('directory',kellytbldir,...
    'filename',kellytblname);

regressiontestcombo.strategy.displaysignalonly_ = false;
regressiontestcombo.mdefut.printflag_ = true;
regressiontestcombo.mdefut.print_timeinterval_ =  displayfreq*60;
regressiontestcombo.ops.printflag_ = true;
regressiontestcombo.ops.print_timeinterval_ = displayfreq*60;
regressiontestcombo.strategy.printflag_ = false;

set(0,'DefaultFigureWindowStyle','docked');

try
    delete(timerfindall);
catch
end

regressiontestcombo.mdefut.start;
regressiontestcombo.ops.start;
regressiontestcombo.strategy.start;

end