%%
homedir = getenv('HOME');
filedir = [getenv('DATAPATH'),'activefutures\'];
futfilename = ['activefutures_',datestr(getlastbusinessdate,'yyyymmdd'),'.txt'];
configfilename = 'config_manual_ccbly_ctp.txt'; 
futs = cDataFileIO.loadDataFromTxtFile([filedir,futfilename]);
genconfigfile(stratname,[homedir,'/demotrading/',configfilename],...
    'instruments',futs);
cd([homedir,'/demotrading/']);
% user inputs:
countername = 'ccb_ly_fut';
stratname = 'manual';
bookname = 'manual-ccbly-ctp';
stratfund = 1e6;
%%
combos = rtt_setup('CounterName',countername,...
    'BookName',bookname,...
    'StrategyName',stratname,...
    'RiskConfigFileName',configfilename);
combos.strategy.setavailablefund(stratfund,'firstset',true);
combos.mdefut.login('Connection','ctp','countername',countername);
fprintf('\ncombos successfully created...\n');
%%
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
combos.ops.printflag_ = false;
%% print the lastest market quotes
combos.mdefut.printmarket;
%% print real-time pnl
combos.ops.printrunningpnl;
%% print all entrusts
combos.ops.printallentrusts;
%% print pending entrusts
combos.ops.printpendingentrusts;
%% open long position
code = 'T1812';
lots = 1;
px = 96.53;
combos.strategy.shortopen(code,lots,'overrideprice',px);
%%
code1 = 'rb1901';inst1 = code2instrument(code1);
code2 = 'i1901';inst2 = code2instrument(code2);
q1 = combos.mdefut.qms_.getquote(code1);
q2 = combos.mdefut.qms_.getquote(code2);
%short code1 and long code2
ratio = q1.bid1*inst1.contract_size/q2.ask1/inst2.contract_size
lots1 = 10;
lots2 = lots1*ratio
q1.bid1*lots1*inst1.contract_size
q2.ask1*lots2*inst2.contract_size







