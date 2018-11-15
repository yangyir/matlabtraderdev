%%
cd([getenv('HOME'),'regressiontest\cstrat\wlpr']);
configfile = [getenv('HOME'),'regressiontest\cstrat\wlpr\wlprconfig_regressiontest.txt'];
% genconfigfile('wlpr',configfile,'instruments',{'ni1809'});
%
%user inputs:
clear;clc;delete(timerfindall);
bookname = 'replay_wlpr';
strategyname = 'wlpr';
riskconfigfilename = 'wlprconfig_regressiontest.txt';
% numofperiod	144
% overbought	0
% oversold	-100
% executiontype	fixed
% name	cStratConfigWR
% codectp	ni1809
% samplefreq	15m
% pnlstoptype	ABS
% pnlstop	-9.99
% pnllimittype	ABS
% pnllimit	-9.99
% bidopenspread	0
% bidclosespread	0
% askopenspread	0
% askclosespread	0
% baseunits	1
% maxunits	10
% autotrade	1
% maxexecutionperbucket	1
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',riskconfigfilename);
% replay
fprintf('nruning regressiontest_wlpr_singleday_nickel...\n');
fprintf('switch mode to replay...\n');
if ~isempty(combos.mdefut), combos.mdefut.mode_ = 'replay';end
if ~isempty(combos.mdeopt), combos.mdeopt.mode_ = 'replay';end
if ~isempty(combos.ops), combos.ops.mode_ = 'replay';end
if ~isempty(combos.strategy), combos.strategy.mode_ = 'replay';end
%
availablefund = 1e6;
combos.strategy.setavailablefund(availablefund,'firstset',true);
%
replayspeed = 50;
fprintf('set replay speed to %s...\n',num2str(replayspeed));
if ~isempty(combos.mdefut),combos.mdefut.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.mdeopt),combos.mdeopt.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.ops),combos.ops.settimerinterval(1/replayspeed);end
if ~isempty(combos.strategy),combos.strategy.settimerinterval(1/replayspeed);end
%
fprintf('load replay tick data....\n');
replaydt1 = '2018-06-19';
replaydt2 = '2018-06-19';
replaydts = gendates('fromdate',replaydt1,'todate',replaydt2);
try
    instruments = combos.strategy.getinstruments;
    ninstruments = size(instruments,1);
    for i = 1:ninstruments
        code = instruments{i}.code_ctp;
        filenames = cell(size(replaydts,1),1);
        for j = 1:size(replaydts,1)
            filenames{j} = [code,'_',datestr(replaydts(j),'yyyymmdd'),'_tick.mat'];
        end
        combos.mdefut.initreplayer('code',code,'filenames',filenames);
    end
catch err
    fprintf('Error:%s\n',err.message);
end
fprintf('load historical candle data...\n');
combos.strategy.initdata;
combos.strategy.printinfo;
combos.mdefut.printflag_ = false;
combos.ops.printflag_ = true;
% combos.ops.print_timeinterval_ = 60*15;
fprintf('replay ready...\n');
%%
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
%%
combos.mdefut.stop
%%
combos.ops.printrunningpnl('MDEFut',combos.mdefut)
