clear;
code1 = 'TF1906';
code2 = 'T1906';
firstdate = '18-Feb-2019';
lookbackperiod = 240;
reblanceperiod = 180;
%
code = {code1;code2};
configfile = [getenv('HOME'),'regressiontest\cstrat\pair\regressiontest_cstrat_paircoint_govtbond.txt'];
genconfigfile('manual',configfile,'instruments',code);
propnames = {'samplefreq';'autotrade'};
propvalues = {'1m';1};
modconfigfile(configfile,'code',code{1},'propnames',propnames,'propvalues',propvalues);
modconfigfile(configfile,'code',code{2},'propnames',propnames,'propvalues',propvalues);
%
cd([getenv('HOME'),'regressiontest\cstrat\pair']);
%
%user inputs:
clc;delete(timerfindall);
bookname = 'regressiontest_govtbondpair';
strategyname = 'pair';
availablefund = 1e6;
combos = rtt_setup('bookname',bookname,'strategyname',strategyname,'riskconfigfilename',configfile,...
    'initialfundlevel',availablefund,'usehistoricaldata',false);
%
replaydt1 = '2019-04-24';
replaydt2 = '2019-04-29';
% replay
if ~isempty(combos.mdefut), combos.mdefut.mode_ = 'replay';end
if ~isempty(combos.ops), combos.ops.mode_ = 'replay';end
if ~isempty(combos.strategy), combos.strategy.mode_ = 'replay';end
%
replayspeed = 50;
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
combos.strategy.lookbackperiod_ = lookbackperiod;
combos.strategy.rebalanceperiod_ = reblanceperiod;
combos.strategy.referencelegindex_ = 2;
combos.strategy.lastrebalancedatetime1_ = getlastrebalance(replaydt1,code2,firstdate,lookbackperiod,reblanceperiod);
combos.strategy.initdata;
combos.mdefut.printflag_ = false;
combos.ops.printflag_ = true;
combos.strategy.printflag_ = false;
fprintf('regression test ready...\n');
fprintf('last prarms:\n');
disp(combos.strategy.cointegrationparams_.coeff);
fprintf('last:%s\n',combos.strategy.lastrebalancedatetime2_);
fprintf('next:%s\n',combos.strategy.nextrebalancedatetime2_);
%%
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
%%
combos.mdefut.stop

%%
delete(timerfindall);
clear
%%
dir_ = [combos.ops.savedir_,combos.ops.book_.bookname_];
fns = dir(dir_);
for i = 1:length(fns)
    fn = fns(i).name;
    pnl = 0;
    if ~isempty(strfind(fn,'regressiontest'))
        trades = cTradeOpenArray;
        trades.fromtxt(fn);
        for j = 1:trades.latest_
            if strcmpi(trades.node_(j).status_,'closed')
                pnl = pnl + trades.node_(j).closepnl_;
            end
        end
        fprintf('pnl:%5f\n',pnl);
        
        
    end
end

