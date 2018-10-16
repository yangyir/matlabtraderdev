clear;delete(timerfindall);clc;
replay_speed = 1;
replay_strat = replay_setstrat('manual','replayspeed',replay_speed);
availablefund = 1e6;
replay_strat.setavailablefund(availablefund,'firstset',true);
replay_strat.loadriskcontrolconfigfromfile('filename','manualconfig_regression.txt');
replay_filename = 'C:\yangyiran\regressiondata\T1809_20180619_tick.mat';
replay_strat.mde_fut_.initreplayer('code','T1809','fn',replay_filename);
replay_strat.mde_fut_.printflag_ = false;
replay_strat.printflag_ = false;
display(replay_strat.riskcontrols_.node_(1))
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
%%
longvolume1 = 1;
replay_strat.longopen('T1809',longvolume1);
%%
shortvolume1 = 1;
replay_strat.shortopen('T1809',shortvolume1);
%%
replay_strat.helper_.printrunningpnl('mdefut',replay_strat.mde_fut_)
%%
pnl = replay_strat.helper_.calcpnl('mdefut',replay_strat.mde_fut_)
%%
pnl = replay_strat.helper_.calcpnl('code','T1809','mdefut',replay_strat.mde_fut_)