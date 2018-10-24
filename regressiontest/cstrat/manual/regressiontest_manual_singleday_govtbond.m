clear;delete(timerfindall);clc;
%% general setup
bookname = 'replay_manual';
strategyname = 'manual';
riskconfigfilename = 'manualconfig_regression.txt';
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',riskconfigfilename);
availablefund = 1e6;
combos.strategy.setavailablefund(availablefund,'firstset',true);

%% replay
fprintf('\n');
fprintf('switch mode to replay...\n');
if ~isempty(combos.mdefut), combos.mdefut.mode_ = 'replay';end
if ~isempty(combos.mdeopt), combos.mdeopt.mode_ = 'replay';end
if ~isempty(combos.ops), combos.ops.mode_ = 'replay';end
if ~isempty(combos.strategy), combos.strategy.mode_ = 'replay';end
replayspeed = 5;
fprintf('set replay speed to %s...\n',num2str(replayspeed));
if ~isempty(combos.mdefut),combos.mdefut.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.mdeopt),combos.mdeopt.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.ops),combos.ops.settimerinterval(1/replayspeed);end
if ~isempty(combos.strategy),combos.strategy.settimerinterval(1/replayspeed);end
fprintf('load replay data....\n');
replaydt1 = '2018-06-19';
replaydt2 = '2018-06-22';
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
tickdata = combos.mdefut.replayer_.tickdata_{1};
timeseries_plot(tickdata(:,1:2),'dateformat','HH:MM');grid on;
%%
try
    combos.mdefut.start;
    combos.ops.start;
    combos.strategy.start
catch err
    fprintf('Error:%s\n',err.message);
end
%% ֹͣreplay
replay_strat.mde_fut_.stop;
%%
replay_strat.mde_fut_.printmarket;
%% ��ϵͳ�趨�õĿ���spread����
longvolume1 = 1;
replay_strat.longopen('T1809',longvolume1);
%% �ü۸�-1���мۣ�market)��
longvolume2 = 1;
replay_strat.longopen('T1809',longvolume2,'overrideprice',-1);
%% �õ����г��۵ļ۸񿪵���limited order)
longvolume3 = 2;
replay_strat.longopen('T1809',longvolume3,'overrideprice',95.11);
%% ���Լ�����Ŀ���spread����
longvolume4 = 2;
askopenspread = 5;
replay_strat.longopen('T1809',longvolume3,'spread',askopenspread);
%% ����һ�ֿ�����4�֣�ϵͳӦ�ûᱨ��
longvolume5 = 5;
replay_strat.longopen('T1809',longvolume5);
%cStratManual:failed to place entrust as max allowance of 4 lots per entrust on T1809 breached...

%%
shortvolume1 = 1;
replay_strat.shortopen('T1809',shortvolume1);
%% ����ί��
replay_strat.withdrawentrusts('T1809')
%% ��ӡ�ֲ�
replay_strat.helper_.printrunningpnl('mdefut',replay_strat.mde_fut_)

%% ��ȡĳһ��Ʒ�ֵĳֲ�ӯ�����
[runningpnl,closedpnl] = replay_strat.helper_.calcpnl('code','T1809','mdefut',replay_strat.mde_fut_)
%% ��ӡ�����ʽ���Ϣ
fprintf('\n');
currentmargin = replay_strat.getcurrentmargin;
fprintf('%13s:%8s\n','CurrentMargin',num2str(round(currentmargin)));
%
availablefund = replay_strat.getavailablefund;
fprintf('%13s:%8s\n','AvailableFund',num2str(round(availablefund)));
%
frozenmargin = replay_strat.getfrozenmargin;
fprintf('%13s:%8s\n','FrozenMargin',num2str(round(frozenmargin)));
%
[runningpnl,closedpnl] = replay_strat.helper_.calcpnl('mdefut',replay_strat.mde_fut_);
fprintf('%13s:%8s\n','RunningPnL',num2str(sum(runningpnl)));
fprintf('%13s:%8s\n','ClosedPnL',num2str(sum(closedpnl)));
