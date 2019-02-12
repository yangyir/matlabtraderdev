%%
clc;
clear;delete(timerfindall);close all;
code = 'cu1903';
startdt = '2019-01-30';
enddt = '2019-02-01';
db = cLocal;
instrument = code2instrument(code);
candle_db_1m = db.intradaybar(instrument,startdt,enddt,1,'trade');
%% generate config file
configfile = [getenv('HOME'),'regressiontest\cstrat\wlpr\config_wlprclassic_wrstep_regressiontest.txt'];
genconfigfile('wlpr',configfile,'instruments',{code});

propnames = {'overbought';'oversold';'wrmode';'samplefreq';'riskmanagername';...
    'stoptypepertrade';'stopamountpertrade';...
    'baseunits';'maxunits'};
propvalues = {-0;-100;'classic';'5m';'wrstep';...
    'opt';-0.3;...
    1;1};
modconfigfile(configfile,'code',code,...
    'propnames',propnames,...
    'propvalues',propvalues);

%%
config = cStratConfigWR;
config.loadfromfile('code',code,'filename',configfile);
[trades,candle_used] = bkfunc_gentrades_wlpr(code,candle_db_1m,...
    'SampleFrequency',config.samplefreq_,...
    'NPeriod',config.numofperiod_,...
    'AskOpenSpread',config.askopenspread_,...
    'BidOpenSpread',config.bidopenspread_,...
    'WRMode',config.wrmode_,...
    'OverBought',config.overbought_,...
    'OverSold',config.oversold_);
wr = willpctr(candle_used(:,3),candle_used(:,4),candle_used(:,5),config.numofperiod_);
figure(1)
subplot(211);
idx = find(candle_used(:,1) >=  datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS'),1,'first');
candle(candle_used(idx:end,3),candle_used(idx:end,4),candle_used(idx:end,5),candle_used(idx:end,2));
grid on;
subplot(212);
plot(wr(idx:end));grid on;
%
count = 0;
clc;
for i = 1:trades.latest_
    if trades.node_(i).opendatetime1_ > datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS')
        count = count + 1;
        fprintf('id:%2d,openbucket:%s,direction:%2d,price:%s\n',...
                count,trades.node_(i).opendatetime2_,trades.node_(i).opendirection_,...
                num2str(trades.node_(i).openprice_));
    end
end
% id: 1,openbucket:2018-06-19 14:15:01,direction: 1,price:113260
% id: 2,openbucket:2018-06-19 14:20:01,direction: 1,price:113060
% id: 3,openbucket:2018-06-19 14:30:01,direction: 1,price:112900
%%
cd([getenv('HOME'),'regressiontest\cstrat\wlpr']);
%
%user inputs:
clc;delete(timerfindall);
bookname = 'replay_wlprclassicbatman';
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
disp(combos.strategy.riskcontrols_.node_(1));
fprintf('replay ready...\n');
%%
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
%%
combos.mdefut.stop
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
