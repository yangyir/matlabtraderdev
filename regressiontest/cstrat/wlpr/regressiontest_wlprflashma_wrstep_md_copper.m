%%
clc;
clear;delete(timerfindall);close all;
code = 'cu1904';
startdt = '2019-02-28';
enddt = '2019-03-09';
db = cLocal;
instrument = code2instrument(code);
candle_db_1m = db.intradaybar(instrument,startdt,enddt,1,'trade');
%% generate config file
configfile = [getenv('HOME'),'regressiontest\cstrat\wlpr\config_flashma_wrstep_regressiontest.txt'];
genconfigfile('wlpr',configfile,'instruments',{code});
propnames = {'numofperiod';'wrmalead';'wrmalag';'wrmode';'samplefreq';'riskmanagername';...
    'stoptypepertrade';'stopamountpertrade';...
    'baseunits';'maxunits'};
propvalues = {97;6;24;'flashma';'5m';'wrstep';...
    'opt';-1;...
    1;3};
modconfigfile(configfile,'code',code,...
    'propnames',propnames,...
    'propvalues',propvalues);

%%
config = cStratConfigWR;
config.loadfromfile('code',code,'filename',configfile);

[trades,candle_used] = bkfunc_gentrades_wlprma(code,candle_db_1m,...
    'SampleFrequency',config.samplefreq_,...
    'NPeriod',config.numofperiod_,...
    'Lead',config.wrmalead_,...
    'Lag',config.wrmalag_);
%
wr = willpctr(candle_used(:,3),candle_used(:,4),candle_used(:,5),config.numofperiod_);
[short,long] = movavg(wr,config.wrmalead_,config.wrmalag_);
figure(1)
subplot(211);
idx = find(candle_used(:,1) >=  datenum([startdt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS'),1,'first');
candle(candle_used(idx:end,3),candle_used(idx:end,4),candle_used(idx:end,5),candle_used(idx:end,2));
grid on;
subplot(212);
plot(wr(idx:end));grid on;
hold on;
plot(short(idx:end),'g');
plot(long(idx:end),'r');
hold off;
%
count = 0;
clc;
for i = 1:trades.latest_
    if trades.node_(i).opendatetime1_ > datenum([startdt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS')
        count = count + 1;
        fprintf('id:%2d,openbucket:%s,direction:%2d,price:%s\n',...
                count,trades.node_(i).opendatetime2_,trades.node_(i).opendirection_,...
                num2str(trades.node_(i).openprice_));
    end
end
% id: 1,openbucket:2019-03-01 14:00:01,direction: 1,price:50210
% id: 2,openbucket:2019-03-01 23:30:01,direction:-1,price:50550
% id: 3,openbucket:2019-03-04 21:15:01,direction: 1,price:49800
% id: 4,openbucket:2019-03-06 21:20:01,direction: 1,price:49870
% id: 5,openbucket:2019-03-07 09:25:01,direction: 1,price:49790
% id: 6,openbucket:2019-03-07 14:20:01,direction: 1,price:49530
% id: 7,openbucket:2019-03-07 21:10:01,direction: 1,price:49490
% id: 8,openbucket:2019-03-08 00:35:01,direction: 1,price:49450
% id: 9,openbucket:2019-03-08 21:35:01,direction: 1,price:49350
%%
cd([getenv('HOME'),'regressiontest\cstrat\wlpr']);
%
%user inputs:
clc;delete(timerfindall);
bookname = 'replay_wlprflashmawrstep';
strategyname = 'wlpr';
availablefund = 1e6;
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',configfile,...
    'initialfundlevel',availablefund,'usehistoricaldata',false);
% replay
fprintf('nruning regressiontest_wlprclassic_wrstep_sd_copper...\n');
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
if ~isempty(combos.ops),combos.ops.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.strategy),combos.strategy.settimerinterval(0.5/replayspeed);end
%
fprintf('load replay tick data....\n');
replaydt1 = '2019-03-01';
replaydt2 = enddt;
replaydts = gendates('fromdate',replaydt1,'todate',replaydt2);
try
    instruments = combos.strategy.getinstruments;
    ninstruments = size(instruments,1);
    for i = 1:ninstruments
        code = instruments{i}.code_ctp;
        filenames = cell(size(replaydts,1),1);
        for j = 1:size(replaydts,1)
            filenames{j} = [code,'_',datestr(replaydts(j),'yyyymmdd'),'_tick.txt'];
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

