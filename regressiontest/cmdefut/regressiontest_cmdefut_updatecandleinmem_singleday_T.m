clc;
clear;delete(timerfindall);
mdefut = cMDEFut;
mdefut.settimerinterval(0.005);
%%
code = 'T1809';
instr = code2instrument(code);
mdefut.registerinstrument(instr);

%%
checkdt = '2018-06-19';
replay_filename = ['C:\yangyiran\regressiondata\',code,'_',datestr(checkdt,'yyyymmdd'),'_tick.mat'];
mdefut.initreplayer('code',code,'fn',replay_filename);

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
if isempty(mdefut.savedir_)
    dir_mdefut = ['C:\yangyiran\mdefut\save\intradaybar\',code,'\'];
else
    dir_mdefut = [mdefut.savedir_,'intradaybar\',code,'\'];
end

dir_db = [getenv('DATAPATH'),'intradaybar\',code,'\'];


fn_mdefut = [dir_mdefut,code,'_',datestr(checkdt,'yyyymmdd'),'_1m.txt'];
fn_db = [dir_db,code,'_',datestr(checkdt,'yyyymmdd'),'_1m.txt'];
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

if result_i == 0
    fprintf('well done:no error is found!\n');
end

% results =
% 
%      0
%      0    