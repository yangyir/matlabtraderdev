%%
cd([getenv('HOME'),'demotrading\wlpr']);
clc;
clear;delete(timerfindall);close all;
code = 'ru1905';
tradedt = '2019-02-19';
db = cLocal;
instrument = code2instrument(code);
% generate config file
configfile = [getenv('HOME'),'demotrading\wlpr\config_demotrading_t.txt'];
genconfigfile('wlpr',configfile,'instruments',{code});
propnames = {'numofperiod';'overbought';'oversold';...
    'wrmode';'samplefreq';'riskmanagername';...
    'stoptypepertrade';'stopamountpertrade';...
    'limittypepertrade';'limitamountpertrade';...
    'baseunits';'maxunits';'autotrade'};
propvalues = {144;-0;-100;...
    'flash';'5m';'batman';...
    'rel';-0.05;...
    'rel';0.2;...
    1;1;1};
modconfigfile(configfile,'code',code,...
    'propnames',propnames,...
    'propvalues',propvalues);
%
bookname = 'replay_wlprfollowbatman';
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

%%
combos.mdefut.stop
