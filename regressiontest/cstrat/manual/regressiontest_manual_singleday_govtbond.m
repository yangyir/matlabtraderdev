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