clc;
clear;delete(timerfindall);
mdefut = cMDEFut;
mdefut.settimerinterval(0.005);
%%
codes = {'T1809';'rb1810'};
ncodes = size(codes,1);
instrs = cell(ncodes,1);
for i = 1:ncodes
    instrs{i} = code2instrument(codes{i});
    mdefut.registerinstrument(instrs{i});
end

%%
checkdt = '2018-06-19';
replay_filenames = cell(ncodes,1);
for i = 1:ncodes
    replay_filenames{i} = [codes{i},'_',datestr(checkdt,'yyyymmdd'),'_tick.mat'];
    mdefut.initreplayer('code',codes{i},'fn',replay_filenames{i});
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
fn_mdefut = cell(ncodes,1);
fn_db = cell(ncodes,1);
candles_mdefut = cell(ncodes,1);
candles_db = cell(ncodes,1);
results = zeros(ncodes,1);

for i = 1:ncodes
    if isempty(mdefut.savedir_)
        dir_mdefut{i} = ['C:\yangyiran\mdefut\save\intradaybar\',codes{i},'\'];
    else
        dir_mdefut{i} = [mdefut.savedir_,'intradaybar\',codes{i},'\'];
    end
    dir_db{i} = [getenv('DATAPATH'),'intradaybar\',codes{i},'\'];
    fn_mdefut{i} = [dir_mdefut{i},codes{i},'_',datestr(checkdt,'yyyymmdd'),'_1m.txt'];
    fn_db{i} = [dir_db{i},codes{i},'_',datestr(checkdt,'yyyymmdd'),'_1m.txt'];
    %
    candles_mdefut{i} = cDataFileIO.loadDataFromTxtFile(fn_mdefut{i});
    candles_db{i} = cDataFileIO.loadDataFromTxtFile(fn_db{i});
    [~,idxA,idxB] = intersect(candles_db{i}(:,1),candles_mdefut{i}(:,1));
    results(i) = sum(sum (candles_db{i}(idxA,:) - candles_mdefut{i}(idxB,:)));
    %
    if results(i) ~= 0
        checkLh = candles_db{i}(idxA,:);
        checkRh = candles_mdefut{i}(idxB,:);
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
end


if sum(results) == 0
    fprintf('well done:no error is found!\n');
end

% results =
% 
%      0
%      0    