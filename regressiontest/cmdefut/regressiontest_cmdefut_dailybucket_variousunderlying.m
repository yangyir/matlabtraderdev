clc;clear;delete(timerfindall);
mdefut = cMDEFut;
mdefut.settimerinterval(0.005);
% codes = {'IH2307';'T2309';'lh2309';'rb2310';'cu2308';'ag2308'};
codes = {'T2309''};
instr = cell(length(codes),1);
for i = 1:length(codes)
    instr{i} = code2instrument(codes{i});
    mdefut.registerinstrument(instr{i});
    mdefut.setcandlefreq(1440,instr{i});
end
%%
replay_startdt = '2023-06-30';
replay_enddt = '2023-07-04';
replay_dates = gendates('fromdate',replay_startdt,'todate',replay_enddt);
ndates = size(replay_dates,1);
replay_filenames = cell(length(codes),1);
for i = 1:length(codes)
    addpath([getenv('DATAPATH'),'ticks\',codes{i},'\']);
    filenames = cell(ndates,1);
    for j = 1:size(replay_dates,1)
        filenames{j,1} = [codes{i},'_',datestr(replay_dates(j),'yyyymmdd'),'_tick.txt'];
    end
    replay_filenames{i,1} = filenames;
    mdefut.initreplayer('code',codes{i},'filenames',replay_filenames{i,1});
end

%%
mdefut.initcandles;
%%
mdefut.printflag_ = true;
mdefut.print_timeinterval_ = 30*60;
mdefut.start;
%%
