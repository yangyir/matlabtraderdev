clear;delete(timerfindall);clc;
replay_speed = 5;
replay_strat = replay_setstrat('manual','replayspeed',replay_speed);
availablefund = 1e6;
replay_strat.setavailablefund(availablefund,'firstset',true);
replay_strat.loadriskcontrolconfigfromfile('filename','manualconfig_regression.txt');
replay_filename = 'C:\yangyiran\regressiondata\T1809_20180619_tick.mat';
replay_strat.mde_fut_.initreplayer('code','T1809','fn',replay_filename);
replay_strat.mde_fut_.printflag_ = false;
replay_strat.printflag_ = false;
display(replay_strat.riskcontrols_.node_(1))
% bidopenspread_: 1
% bidclosespread_: 0
% askopenspread_: 1
% askclosespread_: 0
%%
close all;
tickdata = replay_strat.mde_fut_.replayer_.tickdata_{1};
plot(tickdata(:,2));grid on;
%%
replay_strat.mde_fut_.start;
replay_strat.helper_.start;
replay_strat.start;
%%
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
