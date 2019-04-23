code = {'TF1906';'T1906'};
configfile = [getenv('HOME'),'demotrading\pair\config_demotrading_govtbondpair.txt'];
genconfigfile('manual',configfile,'instruments',code);
propnames = {'samplefreq';'autotrade'};
propvalues = {'1m';1};
modconfigfile(configfile,'code',code{1},'propnames',propnames,'propvalues',propvalues);
modconfigfile(configfile,'code',code{2},'propnames',propnames,'propvalues',propvalues);
%
cd([getenv('HOME'),'demotrading\pair']);
%
%user inputs:
clc;delete(timerfindall);
bookname = 'demotrading_govtbondpair';
strategyname = 'pair';
availablefund = 1e6;
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',configfile,...
    'initialfundlevel',availablefund,'usehistoricaldata',false);
%
replaydt1 = '2019-04-23';
replaydt2 = '2019-04-23';
% replay
fprintf('runing demotrading for govtbond pair in replay mode...\n');
if ~isempty(combos.mdefut), combos.mdefut.mode_ = 'replay';end
if ~isempty(combos.ops), combos.ops.mode_ = 'replay';end
if ~isempty(combos.strategy), combos.strategy.mode_ = 'replay';end
%
replayspeed = 10;
fprintf('set replay speed to %s...\n',num2str(replayspeed));
if ~isempty(combos.mdefut),combos.mdefut.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.ops),combos.ops.settimerinterval(0.5/replayspeed);end
if ~isempty(combos.strategy),combos.strategy.settimerinterval(0.5/replayspeed);end
%
fprintf('load replay tick data....\n');
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
combos.strategy.lookbackperiod_ = 240;
combos.strategy.rebalanceperiod_ = 180;
combos.strategy.referencelegindex_ = 2;
combos.strategy.lastrebalancedatetime1_ = datenum('2019-04-22 14:44','yyyy-mm-dd HH:MM');
combos.strategy.initdata;
combos.mdefut.printflag_ = false;
combos.ops.printflag_ = true;
combos.strategy.printflag_ = false;
fprintf('demo trading ready...\n');
%%
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
%%
combos.mdefut.stop
%%
delete(timerfindall);
clear
