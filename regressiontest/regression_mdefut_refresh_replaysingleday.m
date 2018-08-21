clc;clear;
mdefut = cMDEFut;
mdefut.timer_interval_ = 0.005;
%%
code = 'ni1809';
instr = code2instrument(code);
mdefut.registerinstrument(instr);

%%
data_dir_ = 'C:\yangyiran\regressiondata\';
replay_startdt = '2018-06-19';
replay_enddt = '2018-06-22';
replay_dates = gendates('fromdate',replay_startdt,'todate',replay_enddt);
replay_filenames = cell(size(replay_dates));
for i = 1:size(replay_dates,1)
    replay_filenames{i} = [data_dir_,code,'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.mat'];
end
mdefut.initreplayer('code',code,'fn',replay_filenames{1});

%% start the trading (replay) process
mdefut.start;

%% delete all in a safe way
try
    mdefut.stop;
    delete(timerfindall);
catch
    clear all;
    fprintf('all deleted\n');
end