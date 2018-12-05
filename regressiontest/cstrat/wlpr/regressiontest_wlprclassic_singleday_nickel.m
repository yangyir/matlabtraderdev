%%
clc;
clear;delete(timerfindall);
code = 'ni1809';
startdt = '2018-06-04';
enddt = '2018-06-19';
db = cLocal;
instrument = code2instrument(code);
candle_db_1m = db.intradaybar(instrument,startdt,enddt,1,'trade');
%%
configfile = [getenv('HOME'),'regressiontest\cstrat\wlpr\wlprconfig_regressiontest.txt'];
config = cStratConfigWR;
config.loadfromfile('code',code,'filename',configfile);
[trades] = bkfunc_gentrades_wlpr(code,candle_db_1m,...
    'SampleFrequency',config.samplefreq_,...
    'NPeriod',config.numofperiod_,...
    'AskOpenSpread',config.askopenspread_,...
    'BidOpenSpread',config.bidopenspread_,...
    'WRMode',config.wrmode_,...
    'OverBought',config.overbought_,...
    'OverSold',config.oversold_);
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
configfile = [getenv('HOME'),'regressiontest\cstrat\wlpr\wlprconfig_regressiontest.txt'];
%
%user inputs:
clear;clc;delete(timerfindall);
bookname = 'replay_wlpr';
strategyname = 'wlpr';
riskconfigfilename = 'wlprconfig_regressiontest.txt';
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',riskconfigfilename);
% replay
fprintf('nruning regressiontest_wlpr_singleday_nickel...\n');
fprintf('switch mode to replay...\n');
if ~isempty(combos.mdefut), combos.mdefut.mode_ = 'replay';end
if ~isempty(combos.mdeopt), combos.mdeopt.mode_ = 'replay';end
if ~isempty(combos.ops), combos.ops.mode_ = 'replay';end
if ~isempty(combos.strategy), combos.strategy.mode_ = 'replay';end
%
availablefund = 1e6;
combos.strategy.setavailablefund(availablefund,'firstset',true);
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
