%% note: only for one business date
clear;clc;
% user_inputs
lastbd = getlastbusinessdate;
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
filename = ['activefutures_',datestr(lastbd,'yyyymmdd'),'.txt'];
codes = cDataFileIO.loadDataFromTxtFile([activefuturesdir,filename]);
checkdt = lastbd;
%%
codes = {'cu1902'};
checkdt = datenum('2018-12-19','yyyy-mm-dd');
%%
enddt = datestr(checkdt,'yyyy-mm-dd');
strategyname = 'wlpr';
fn = 'config_wlprflash_replay.txt';
dir_ = [getenv('HOME'),'replay\',strategyname,'\'];
genconfigfile(strategyname,[dir_,fn],'instruments',codes);
%modify risk configurations
for i = 1:size(codes,1),modconfigfile([dir_,fn],'code',codes{i},...
    'PropNames',{'numofperiod';'samplefreq';'wrmode';'riskmanagername'},...
    'PropValues',{144;'15m';'flash';'batman'});
end

%%
db = cLocal;
instruments = cell(size(codes));
candle_db_1m = cell(size(codes));
configfile =[dir_,fn];
configs = cell(size(codes));

for i = 1:size(codes,1), instruments{i} = code2instrument(codes{i});end

for i = 1:size(codes,1)
    configs{i} = cStratConfigWR;
    configs{i}.loadfromfile('code',codes{i},'filename',configfile);
    if strcmpi(configs{i}.samplefreq_,'1m')
        startdt = datestr(dateadd(checkdt,'-1d'),'yyyy-mm-dd');
    elseif strcmpi(configs{i}.samplefreq_,'3m')
        startdt = datestr(dateadd(checkdt,'-3d'),'yyyy-mm-dd');
    elseif strcmpi(configs{i}.samplefreq_,'5m')
        startdt = datestr(dateadd(checkdt,'-5d'),'yyyy-mm-dd');
    elseif strcmpi(configs{i}.samplefreq_,'15m')
        startdt = datestr(dateadd(checkdt,'-10d'),'yyyy-mm-dd');
    else
        startdt = datestr(dateadd(checkdt,'-10d'),'yyyy-mm-dd');
    end
    data = db.intradaybar(instruments{i},startdt,enddt,1,'trade');
    idx = find(data(:,1) >= datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS'),1,'first');
    multiplier = str2double(configs{i}.samplefreq_(1:end-1));
    candle_db_1m{i} = data(idx-multiplier*configs{i}.numofperiod_:end,:);
end

trades = cell(size(codes));
candle_used = cell(size(codes));
wr = cell(size(codes));
for i = 1:size(codes,1)
    [trades{i},candle_used{i}] = bkfunc_gentrades_wlpr(codes{i},candle_db_1m{i},...
        'SampleFrequency',configs{i}.samplefreq_,...
        'NPeriod',configs{i}.numofperiod_,...
        'AskOpenSpread',configs{i}.askopenspread_,...
        'BidOpenSpread',configs{i}.bidopenspread_,...
        'WRMode',configs{i}.wrmode_,...
        'OverBought',configs{i}.overbought_,...
        'OverSold',configs{i}.oversold_);
    wr{i} = willpctr(candle_used{i}(:,3),candle_used{i}(:,4),candle_used{i}(:,5),configs{i}.numofperiod_);
end
%
clc;
for i = 1:size(codes,1)
    count = 0;
    for j = 1:trades{i}.latest_
        if trades{i}.node_(j).opendatetime1_ > datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS')
            count = count + 1;
            fprintf('id:%2d,%s,openbucket:%s,direction:%2d,price:%s\n',...
                    count,codes{i},trades{i}.node_(j).opendatetime2_,trades{i}.node_(j).opendirection_,...
                    num2str(trades{i}.node_(j).openprice_));
        end
    end
    fprintf('\n');
end

%%
code = 'm1905';
idxfut = strcmpi(codes,code);
figure(idxfut)
subplot(211);
idx = find(candle_used{idxfut}(:,1) >=  datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS'),1,'first');

for i = 1:trades{idxfut}.latest_
    tradei = trades{idxfut}.node_(i);
    opentime = tradei.opendatetime1_;
    idxtrade = find(candle_used{idxfut}(:,1) > opentime,1,'first');
    plot(idxtrade-idx,tradei.openprice_,'marker','o','color','r','markersize',10,'linewidth',3,'markerfacecolor','r');
    hold on;
end

candle(candle_used{idxfut}(idx:end,3),candle_used{idxfut}(idx:end,4),candle_used{idxfut}(idx:end,5),candle_used{idxfut}(idx:end,2));
grid on;
hold off;
subplot(212);
plot(wr{idxfut}(idx:end));grid on;
