%user inputs:
clear;clc;
code = 'ni1809';
startdt = '2018-06-14';
enddt = '2018-06-19';
checkdt = '2018-06-19';

%%
delete(timerfindall);
replay_speed = 50;
replay_strat = replay_setstrat('batman','replayspeed',replay_speed);
replay_strat.setavailablefund(1e6,'firstset',true);
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
replay_strat.loadriskcontrolconfigfromfile('filename','batmanconfig_regressiontest.txt');
%
replay_filename = [code,'_',datestr(checkdt,'yyyymmdd'),'_tick.mat'];
replay_strat.mde_fut_.initreplayer('code',code,'fn',replay_filename);
replay_strat.initdata;
replay_strat.mde_fut_.printflag_ = true;
replay_strat.mde_fut_.print_timeinterval_ = 60;%行情1分钟打印一次
replay_strat.helper_.print_timeinterval_ = 60;%持仓盈亏信息1分钟打印一次
clc;
fprintf('replay get ready......\n');
%%
ticks = replay_strat.mde_fut_.replayer_.tickdata_{1};
timeseries_plot(ticks(:,1:2),'dateformat','HH:MM');
%%
clc;
replay_strat.mde_fut_.start;
replay_strat.helper_.start; 
replay_strat.start;

%%
price = 114000;
target = 113500;
stoploss = 114600;
replay_strat.placeentrust(code,'buysell','s','price',price,'volume',3,'target',target,'stoploss',stoploss);

%%
try
    replay_strat.mde_fut_.stop;
    delete(timerfindall);
catch
    clear all;
    fprintf('all deleted\n');
end
