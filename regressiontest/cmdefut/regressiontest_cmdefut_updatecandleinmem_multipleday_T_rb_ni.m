clc;
clear;delete(timerfindall);
mdefut = cMDEFut;
mdefut.settimerinterval(0.005);
%%
codes = {'T1809';'rb1810';'ni1809'};
ncodes = size(codes,1);
instrs = cell(ncodes,1);
for i = 1:ncodes
    instrs{i} = code2instrument(codes{i});
    mdefut.registerinstrument(instrs{i});
end

%%
replay_startdt = '2018-06-19';
replay_enddt = '2018-06-20';
replay_dates = gendates('fromdate',replay_startdt,'todate',replay_enddt);
ndates = size(replay_dates,1);
replay_filenames = cell(ncodes,1);
for i = 1:ncodes
    filenames = cell(ndates,1);
    for j = 1:size(replay_dates,1)
        filenames{j,1} = [codes{i},'_',datestr(replay_dates(j),'yyyymmdd'),'_tick.mat'];
    end
    replay_filenames{i,1} = filenames;
    mdefut.initreplayer('code',codes{i},'filenames',replay_filenames{i,1});
end

%% start the trading (replay) process
mdefut.start;
isrunning = strcmpi(mdefut.timer_.running,'on');
while isrunning
    isrunning = strcmpi(mdefut.timer_.running,'on');
    pause(1);
end

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
dir_mdefut = cell(ncodes,1);
dir_db = cell(ncodes,1);
fn_mdefut = cell(ncodes,ndates);
fn_db = cell(ncodes,ndates);
candles_mdefut = cell(ncodes,ndates);
candles_db = cell(ncodes,ndates);
results = zeros(ncodes,ndates);

for i = 1:ncodes
    if isempty(mdefut.savedir_)
        dir_mdefut{i} = ['C:\yangyiran\mdefut\save\intradaybar\',codes{i},'\'];
    else
        dir_mdefut{i} = [mdefut.savedir_,'intradaybar\',codes{i},'\'];
    end
    dir_db{i} = [getenv('DATAPATH'),'intradaybar\',codes{i},'\'];
    for j = 1:ndates
        fn_mdefut{i,j} = [dir_mdefut{i},codes{i},'_',datestr(replay_dates(j),'yyyymmdd'),'_1m.txt'];
        fn_db{i,j} = [dir_db{i},codes{i},'_',datestr(replay_dates(j),'yyyymmdd'),'_1m.txt'];
        %
        candles_mdefut{i,j} = cDataFileIO.loadDataFromTxtFile(fn_mdefut{i,j});
        candles_db{i,j} = cDataFileIO.loadDataFromTxtFile(fn_db{i,j});
        [~,idxA,idxB] = intersect(candles_db{i,j}(:,1),candles_mdefut{i,j}(:,1));
        results(i,j) = sum(sum (candles_db{i,j}(idxA,:) - candles_mdefut{i,j}(idxB,:)));
        %
        if results(i,j) ~= 0
            checkLh = candles_db{i,j}(idxA,:);
            checkRh = candles_mdefut{i,j}(idxB,:);
            nrecords = size(checkLh,1);
            for k = 1:nrecords
                if sum(checkLh(k,:) - checkRh(k,:)) ~= 0
                    fprintf('difference found:%s,open:%s(%s);high:%s(%s);low:%s(%s);close:%s(%s)\n',...
                        datestr(checkLh(k,1),'yyyymmdd HH:MM:SS'),num2str(checkLh(k,2)),num2str(checkRh(k,2)),...
                        num2str(checkLh(k,3)),num2str(checkRh(k,3)),...
                        num2str(checkLh(k,4)),num2str(checkRh(k,4)),...
                        num2str(checkLh(k,5)),num2str(checkRh(k,5)));
                end
            end
        end
    end
end


if sum(results) == 0
    fprintf('well done:no error is found!\n');
end

% results =
% 
%      0
%      0    