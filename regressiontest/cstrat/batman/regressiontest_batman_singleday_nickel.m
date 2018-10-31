%user inputs:
clear;clc;delete(timerfindall);
bookname = 'replay_batman';
strategyname = 'batman';
riskconfigfilename = 'batmanconfig_regressiontest.txt';
% Name	cStratConfigBatman
% CodeCTP	ni1809
% SampleFreq	3m
% PnLStopType	ABS
% PnLStop	50000
% PnLLimitType	ABS
% PnLLimit	50000
% BidOpenSpread	0
% BidCloseSpread	0
% AskOpenSpread	0
% AskCloseSpread	0
% BaseUnits	1
% MaxUnits	100
% AutoTrade	1
% ExecutionPerBucket	1
% MaxExecutionPerBucket	1
% BandwidthMin	0.333333
% BandwidthMax	0.5
% BandStopLoss	0.01
% BandTarget	0.02
% BandType	0
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',riskconfigfilename);
% replay
fprintf('\nruning regressiontest_batman_singleday_nickel');
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
fprintf('load replay data....\n');
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
fprintf('replay ready...\n');

%%
close all;
ticks = combos.mdefut.replayer_.tickdata_{1};
timeseries_plot(ticks(:,1:2),'dateformat','HH:MM');
%%
clc;
combos.mdefut.start;
combos.ops.start; 
combos.strategy.start;

%%
price = 114300;
target = price-500;
stoploss = price+500;
combos.strategy.placeentrust(code,'buysell','s','price',price,'volume',1,'target',target,'stoploss',stoploss);

%%
try
    combos.mdefut.stop;
    delete(timerfindall);
catch
    clear all;
    fprintf('all deleted\n');
end
