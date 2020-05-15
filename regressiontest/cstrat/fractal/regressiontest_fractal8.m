%% create config file
try
    clear;clc;
    delete(timerfindall);
catch
end
%
code = 'SR009';
path_ = [getenv('HOME'),'\regressiontest\cstrat\fractal\'];
cd(path_);
bookname = ['replaybook-',code];
strategyname = 'fractal';
riskconfigfilename = 'config_replaycomdty.txt';
genconfigfile(strategyname,[path_,riskconfigfilename],'instruments',{code});
modconfigfile([path_,riskconfigfilename],'code',code,...
    'propnames',{'nfractals';'samplefreq';'baseunits';'maxunits';'riskmanagername';'autotrade'},...
    'propvalues',{4;'30m';1;2;'spiderman';1});
%
combo = rtt_setup('countername','ccb_ly_fut',...
    'bookname',bookname,...
    'strategyname',strategyname,...
    'riskconfigfilename',riskconfigfilename,...
    'initialfundlevel',1e6,...
    'mode','replay',...
    'replayfromdate','2020-05-13','replaytodate','2020-05-13');
combo.strategy.displaysignalonly_ = false;
combo.mdefut.printflag_ = false;
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
[~,~,p_code] = combo.mdefut.calc_macd_(code2instrument(code),'includelastcandle',1,'removelimitprice',1);
op_code = tools_technicalplot1(p_code,4,1,'volatilityperiod',0,'tolerance',0.000);
%%
combo.ops.print;
%%
combo.ops.book_.printpositions

