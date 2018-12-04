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
configfile = [getenv('HOME'),'regressiontest\cstrat\wlpr\wlprreverse1config_regressiontest.txt'];
config = cStratConfigWR;
config.loadfromfile('code',code,'filename',configfile);
candle_used = timeseries_compress(candle_db_1m,...
        'frequency',config.samplefreq_,...
        'tradinghours',instrument.trading_hours,...
        'tradingbreak',instrument.trading_break);
nperiod = config.numofperiod_;

includelastcandle = config.includelastcandle_;
if includelastcandle, error('includelastcandle shall be 0');end

bidopenspread = config.bidopenspread_;
askopenspread = config.askopenspread_;
ticksize = instrument.tick_size;

startdtnum = datenum([enddt,' 09:00:00'],'yyyy-mm-dd HH:MM:SS');
if strcmpi(config.wrmode_,'reverse1')
    ntrade = 0;
    for i = nperiod+1:size(candle_used,1)
        t = candle_used(i,1);
        if t < startdtnum, continue;end
        pxmax = max(candle_used(i-nperiod:i-1,3));
        pxmin = min(candle_used(i-nperiod:i-1,4));
        pxhigh = candle_used(i,3);
        pxlow = candle_used(i,4);
        if pxhigh > pxmax + bidopenspread*ticksize
            ntrade = ntrade + 1;
            fprintf('id:%2d,openbucket:%s,direction:%2d,price:%s,max:%s,min:%s\n',...
                ntrade,datestr(t,'yyyy-mm-dd HH:MM'),-1,...
                num2str(pxmax + bidopenspread*ticksize),...
                num2str(pxmax),num2str(pxmin));
        end
        if pxlow < pxmin - askopenspread*ticksize
            ntrade = ntrade + 1;
            fprintf('id:%2d,openbucket:%s,direction:%2d,price:%s,max:%s,min:%s\n',...
                ntrade,datestr(t,'yyyy-mm-dd HH:MM'),1,...
                num2str(pxmin - askopenspread*ticksize),...
                num2str(pxmax),num2str(pxmin));
        end
    end
end
% id: 1,openbucket:2018-06-19 09:00,direction: 1,price:114090,max:117650,min:114090
% id: 2,openbucket:2018-06-19 09:05,direction: 1,price:113860,max:117630,min:113860
% id: 3,openbucket:2018-06-19 14:10,direction: 1,price:113400,max:116450,min:113400
% id: 4,openbucket:2018-06-19 14:15,direction: 1,price:113260,max:116450,min:113260
% id: 5,openbucket:2018-06-19 14:20,direction: 1,price:113050,max:116450,min:113050
% id: 6,openbucket:2018-06-19 14:25,direction: 1,price:113010,max:116450,min:113010
% id: 7,openbucket:2018-06-19 14:30,direction: 1,price:112890,max:116450,min:112890
% id: 8,openbucket:2018-06-19 14:35,direction: 1,price:112810,max:116450,min:112810
% id: 9,openbucket:2018-06-19 21:00,direction: 1,price:112420,max:116450,min:112420

%%
cd([getenv('HOME'),'regressiontest\cstrat\wlpr']);
%
%user inputs:
bookname = 'replay_wlprreverse1';
strategyname = 'wlpr';
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',configfile);
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
