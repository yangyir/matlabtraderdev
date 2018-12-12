%%
clc;
clear;delete(timerfindall);
codes = {'ni1809';'rb1810';'T1809'};
startdt = '2018-06-04';
enddt = '2018-06-19';
db = cLocal;
instruments = cell(size(codes));
candle_db_1m = cell(size(codes));
for i = 1:size(codes,1), instruments{i} = code2instrument(codes{i});end
for i = 1:size(codes,1), candle_db_1m{i} = db.intradaybar(instruments{i},startdt,enddt,1,'trade');end
%%
clc
configfile = [getenv('HOME'),'regressiontest\cstrat\wlpr\config_wlprflash_batman_regressiontest_multi.txt'];
configs = cell(size(codes));
trades = cell(size(codes));
candle_used = cell(size(codes));
wr = cell(size(codes));
for i = 1:size(codes,1)
    configs{i} = cStratConfigWR;
    configs{i}.loadfromfile('code',codes{i},'filename',configfile);
    [trades{i},candle_used{i}] = bkfunc_gentrades_wlpr(codes{i},candle_db_1m{i},...
        'SampleFrequency',configs{i}.samplefreq_,...
        'NPeriod',configs{i}.numofperiod_,...
        'AskOpenSpread',configs{i}.askopenspread_,...
        'BidOpenSpread',configs{i}.bidopenspread_,...
        'WRMode',configs{i}.wrmode_,...
        'OverBought',configs{i}.overbought_,...
        'OverSold',configs{i}.oversold_);
    wr{i} = willpctr(candle_used{i}(:,3),candle_used{i}(:,4),candle_used{i}(:,5),configs{i}.numofperiod_);
    figure(i)
    subplot(211);
    idx = find(candle_used{i}(:,1) >=  datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS'),1,'first');
    candle(candle_used{i}(idx:end,3),candle_used{i}(idx:end,4),candle_used{i}(idx:end,5),candle_used{i}(idx:end,2));
    grid on;
    subplot(212);
    plot(wr{i}(idx:end));grid on;
end
%
for i = 1:size(codes,1)
    count = 0;
    for j = 1:trades{i}.latest_
        if trades{i}.node_(j).opendatetime1_ > datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS')
            count = count + 1;
            fprintf('id:%2d,openbucket:%s,direction:%2d,price:%s\n',...
                    count,trades{i}.node_(j).opendatetime2_,trades{i}.node_(j).opendirection_,...
                    num2str(trades{i}.node_(j).openprice_));
        end
    end
    fprintf('\n');
end
% id: 1,openbucket:2018-06-19 09:10:01,direction: 1,price:114290
% id: 2,openbucket:2018-06-19 14:40:01,direction: 1,price:112880
% id: 3,openbucket:2018-06-19 21:05:01,direction: 1,price:112870
% %
% id: 1,openbucket:2018-06-19 09:10:01,direction: 1,price:3868
% id: 2,openbucket:2018-06-19 10:05:01,direction: 1,price:3802
% id: 3,openbucket:2018-06-19 10:30:01,direction: 1,price:3804
% id: 4,openbucket:2018-06-19 10:35:01,direction: 1,price:3805
% id: 5,openbucket:2018-06-19 11:25:01,direction: 1,price:3782
% id: 6,openbucket:2018-06-19 14:00:01,direction: 1,price:3755
% id: 7,openbucket:2018-06-19 14:20:01,direction: 1,price:3752
% id: 8,openbucket:2018-06-19 14:40:01,direction: 1,price:3747
%
% id: 1,openbucket:2018-06-19 09:35:01,direction:-1,price:95.16
% id: 2,openbucket:2018-06-19 13:35:01,direction:-1,price:95.39
% id: 3,openbucket:2018-06-19 14:25:01,direction:-1,price:95.42
% id: 4,openbucket:2018-06-19 14:40:01,direction:-1,price:95.495
%%
cd([getenv('HOME'),'regressiontest\cstrat\wlpr']);
%
%user inputs:
bookname = 'replay_wlprflashbatman_multi';
strategyname = 'wlpr';
availablefund = 1e6;
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',configfile,...
    'initialfundlevel',availablefund,'usehistoricaldata',false);
% replay
fprintf('nruning regressiontest_wlpr_singleday_nickel...\n');
fprintf('switch mode to replay...\n');
if ~isempty(combos.mdefut), combos.mdefut.mode_ = 'replay';end
if ~isempty(combos.mdeopt), combos.mdeopt.mode_ = 'replay';end
if ~isempty(combos.ops), combos.ops.mode_ = 'replay';end
if ~isempty(combos.strategy), combos.strategy.mode_ = 'replay';end
%
replayspeed = 50;
fprintf('set replay speed to %s...\n',num2str(replayspeed));
if ~isempty(combos.mdefut),combos.mdefut.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.mdeopt),combos.mdeopt.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.ops),combos.ops.settimerinterval(1/replayspeed);end
if ~isempty(combos.strategy),combos.strategy.settimerinterval(1/replayspeed);end
%
fprintf('load replay tick data....\n');
replaydt1 = '2018-06-19';
replaydt2 = '2018-06-19';
replaydts = gendates('fromdate',replaydt1,'todate',replaydt2);
try
    instruments = combos.strategy.getinstruments;
    ninstruments = size(instruments,1);
    for i = 1:ninstruments
        code = instruments{i}.code_ctp;
        filenames = cell(size(replaydts,1),1);
        for j = 1:size(replaydts,1)
            filenames{j} = [code,'_',datestr(replaydts(j),'yyyymmdd'),'_tick.mat'];
        end
        combos.mdefut.initreplayer('code',code,'filenames',filenames);
    end
catch err
    fprintf('Error:%s\n',err.message);
end
fprintf('load historical candle data...\n');
combos.strategy.initdata;
combos.strategy.printinfo;
combos.mdefut.printflag_ = false;
combos.ops.printflag_ = true;
% combos.ops.print_timeinterval_ = 60*15;
for i = 1:size(codes,1)
    disp(combos.strategy.riskcontrols_.node_(i));
end
fprintf('replay ready...\n');
%%
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
%%
combos.mdefut.stop
%%
%%
fprintf('\ntrades info from replay......\n')
for j = 1:combos.ops.trades_.latest_
    trade_j = combos.ops.trades_.node_(j);
    fprintf('id:%2d,opentime:%s,direction:%2d,price:%s\n',...
        j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
        num2str(trade_j.openprice_));
end
% %
% id: 1,opentime: 09:10:54,direction: 1,price:114290
% id: 2,opentime: 14:40:57,direction: 1,price:112880
% id: 3,opentime: 21:05:13,direction: 1,price:112870
