clc;
clear;
mdefut = cMDEFut;
mdefut.timer_interval_ = 0.005;
mdefut.display_ = 1;
mdefut.candlesaveflag_ = true;
%%
code = 'T1809';
instr = code2instrument(code);
mdefut.registerinstrument(instr);

%%
replay_startdt = '2018-06-05';
replay_enddt = '2018-06-06';
replay_dates = gendates('fromdate',replay_startdt,'todate',replay_enddt);
replay_filenames = cell(size(replay_dates));
for i = 1:size(replay_dates,1)
    replay_filenames{i} = [code,'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
end
mdefut.initreplayer('code',code,'filenames',replay_filenames);
% mdefut.initreplayer('code',code,'fn',replay_filenames{1});

%% start the trading (replay) process
mdefut.start;
%% check when the mdefut is running 
lasttick = mdefut.getlasttick(code);
fprintf('time:%s; trade:%s\n',datestr(lasttick(1)),num2str(lasttick(4)));
%% delete all in a safe way
try
    mdefut.stop;
    delete(timerfindall);
catch
    clear all;
    fprintf('all deleted\n');
end
%% compare the mdefut saved candle with the one downloaded from database directly
clc;
dir_mdefut = [getenv('HOME'),'trading\objs\@cReplayer\'];
dir_db = [getenv('DATAPATH'),'intradaybar\',code,'\'];
results = zeros(size(replay_dates,1),1);

for i = 1:size(replay_dates,1)
    fn_mdefut = [dir_mdefut,code,'_',datestr(replay_dates(i),'yyyymmdd'),'_1m.txt'];
    fn_db = [dir_db,code,'_',datestr(replay_dates(i),'yyyymmdd'),'_1m.txt'];
    candles_mdefut = cDataFileIO.loadDataFromTxtFile(fn_mdefut);
    candles_db = cDataFileIO.loadDataFromTxtFile(fn_db);
    [~,idxA,idxB] = intersect(candles_db(:,1),candles_mdefut(:,1));
    result_i = sum(sum (candles_db(idxA,:) - candles_mdefut(idxB,:)));
    if result_i ~= 0
        checkLh = candles_db(idxA,:);
        checkRh = candles_mdefut(idxB,:);
        nrecords = size(checkLh,1);
        for j = 1:nrecords
            if sum(checkLh(j,:) - checkRh(j,:)) ~= 0
                fprintf('difference found:%s,open:%s(%s);high:%s(%s);low:%s(%s);close:%s(%s)\n',...
                    datestr(checkLh(j,1),'yyyymmdd HH:MM:SS'),num2str(checkLh(j,2)),num2str(checkRh(j,2)),...
                    num2str(checkLh(j,3)),num2str(checkRh(j,3)),...
                    num2str(checkLh(j,4)),num2str(checkRh(j,4)),...
                    num2str(checkLh(j,5)),num2str(checkRh(j,5)));
            end
        end
    end
    results(i) = result_i;
end

if sum(results) == 0
    fprintf('well done:no error is found!\n');
end

% results =
% 
%      0
%      0    