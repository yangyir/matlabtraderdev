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
configfile = [getenv('HOME'),'regressiontest\cstrat\manual\config_manual_regressiontest.txt'];
configs = cell(size(codes));
candle_used = cell(size(codes));
wr = cell(size(codes));
for i = 1:size(codes,1)
    configs{i} = cStratConfig;
    configs{i}.loadfromfile('code',codes{i},'filename',configfile);
    [~,candle_used{i}] = bkfunc_gentrades_wlpr(codes{i},candle_db_1m{i},...
        'SampleFrequency',configs{i}.samplefreq_,...
        'NPeriod',144,...
        'AskOpenSpread',configs{i}.askopenspread_,...
        'BidOpenSpread',configs{i}.bidopenspread_,...
        'WRMode','classic',...
        'OverBought',-0,...
        'OverSold',-100);
    wr{i} = willpctr(candle_used{i}(:,3),candle_used{i}(:,4),candle_used{i}(:,5),144);
    figure(i)
    subplot(211);
    idx = find(candle_used{i}(:,1) >=  datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS'),1,'first');
    candle(candle_used{i}(idx:end,3),candle_used{i}(idx:end,4),candle_used{i}(idx:end,5),candle_used{i}(idx:end,2));
    grid on;
    subplot(212);
    plot(wr{i}(idx:end));grid on;
end
%
%%
cd([getenv('HOME'),'regressiontest\cstrat\manual']);
%
%user inputs:
clc;delete(timerfindall);
bookname = 'replay_manual';
strategyname = 'manual';
availablefund = 1e6;
usehistdata = false;
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',configfile,...
    'initialfundlevel',availablefund,'usehistoricaldata',usehistdata);
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
combos.mdefut.printflag_ = true;
combos.ops.printflag_ = true;
% combos.ops.print_timeinterval_ = 60*15;
disp(combos.strategy.riskcontrols_.node_(1));
fprintf('replay ready...\n');
%%
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
%%
combos.mdefut.stop
%%
combos.strategy.placeentrust('ni1809','buysell','b','price',112800,'volume',1,...
    'limit',113500,'stop',112000,'riskmanagername','standard');
%%
combos.strategy.placeentrust('T1809','buysell','b','price',95.19,'volume',1,...
    'limit',96,'stop',95,'riskmanagername','standard');

%%
fprintf('\ntrades info from replay......\n')
for j = 1:combos.ops.trades_.latest_
    trade_j = combos.ops.trades_.node_(j);
    fprintf('id:%2d,opentime:%s,direction:%2d,price:%s\n',...
        j,trade_j.opendatetime2_(end-8:end),trade_j.opendirection_,...
        num2str(trade_j.openprice_));
end
% trades info from replay......
% id: 1,opentime: 14:15:01,direction: 1,price:113260
% id: 2,opentime: 14:20:01,direction: 1,price:113060
% id: 3,opentime: 14:30:00,direction: 1,price:112900
