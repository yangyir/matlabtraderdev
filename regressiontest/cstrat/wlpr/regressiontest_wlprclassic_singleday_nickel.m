%%
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
candle_used = timeseries_compress(candle_db_1m,...
        'frequency',config.samplefreq_,...
        'tradinghours',instrument.trading_hours,...
        'tradingbreak',instrument.trading_break);
nperiod = config.numofperiod_;

if strcmpi(config.wrmode_,'classic')
    overbought = config.overbought_;
    oversold = config.oversold_;
    wr = willpctr(candle_used(:,3),candle_used(:,4),candle_used(:,5),nperiod);
    tidx = candle_used(:,1) >= datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS');
    wrused = [candle_used(tidx,1),wr(tidx),candle_used(tidx,2)];
    wridx = wrused(:,2) <= oversold | wrused(:,2) >= overbought;
    ntrades = sum(wridx);
    tradingbucket = zeros(ntrades,1);
    tradingopenprice = zeros(ntrades,1);
    tradingdirection = zeros(ntrades,1);
    tradingprice = zeros(ntrades,1);
    count = 0;
    for i = 1:size(wridx,1)
        if wridx(i)
            count = count + 1;
            tradingbucket(count,1) = wrused(i+1,1);
            tradingprice(count,1) = wrused(i+1,3);
            if wrused(i,2) <= oversold
                tradingdirection(count) = 1;
            else
                tradingdirection(count) = -1;
            end
            fprintf('id:%2d,openbucket:%s,direction:%2d,price:%s\n',...
                count,datestr(tradingbucket(count),'yyyy-mm-dd HH:MM'),tradingdirection(count),...
                num2str(tradingprice(count)));
        end
    end
end
% id: 1,openbucket:2018-06-19 14:15,direction: 1,price:113260
% id: 2,openbucket:2018-06-19 14:20,direction: 1,price:113060
% id: 3,openbucket:2018-06-19 14:30,direction: 1,price:112900

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
combos.ops.printrunningpnl('MDEFut',combos.mdefut)
