%%
cd([getenv('HOME'),'demotrading\wlpr']);
clc;
clear;delete(timerfindall);close all;
code = 'T1903';
tradedt = '2019-02-01';
db = cLocal;
instrument = code2instrument(code);
% generate config file
configfile = [getenv('HOME'),'demotrading\wlpr\config_demotrading_t.txt'];
genconfigfile('wlpr',configfile,'instruments',{code});
propnames = {'numofperiod';'overbought';'oversold';'wrmode';'samplefreq';'riskmanagername';...
    'stoptypepertrade';'stopamountpertrade';...
    'baseunits';'maxunits';'autotrade'};
propvalues = {100;-0;-100;'classic';'5m';'wrstep';...
    'opt';-1;...
    1;3;0};
modconfigfile(configfile,'code',code,...
    'propnames',propnames,...
    'propvalues',propvalues);

%
bookname = 'demotrading_t';
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
if ~isempty(combos.ops),combos.ops.settimerinterval(1/replayspeed);end
if ~isempty(combos.strategy),combos.strategy.settimerinterval(1/replayspeed);end
%
fprintf('load replay tick data....\n');
replaydt1 = tradedt;
replaydt2 = tradedt;
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
combos.mdefut.printflag_ = true;
combos.mdefut.print_timeinterval_ = 60;
combos.ops.printflag_ = true;
samplefreqstr = combos.strategy.riskcontrols_.getconfigvalue('code',code,'propname','samplefreq');
combos.ops.print_timeinterval_ = 60*str2double(samplefreqstr(1:end-1));
disp(combos.strategy.riskcontrols_.node_(1));
fprintf('replay ready...\n');
%%
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
%% buy open
combos.strategy.placeentrust(code,'buysell','b','offset','open',...
    'price',97.93,...
    'volume',combos.strategy.riskcontrols_.getconfigvalue('code',code,'propname','baseunits'),...
    'limit',-9.99,...
    'stop',-9.99,...
    'riskmanagername','standard');
%%
combos.strategy.placeentrust(code,'buysell','s','offset','close',...
    'price',-1,...
    'volume',combos.strategy.riskcontrols_.getconfigvalue('code',code,'propname','baseunits'));
%%
combos.mdefut.stop
%%
combos.ops.savetrades;
%%
foldername = [getenv('DATAPATH'),'\realtimetrading\citickim\demotrading_t\'];
combos.ops.loadtrades('filename',[foldername,'demotrading_t_trades_20190201.txt'],...
    'time',datenum('2019-02-11 08:50:00'));

