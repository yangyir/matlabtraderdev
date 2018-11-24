clear all;clc;delete(timerfindall);dir_ = getenv('TRADINGDIR'); cd(dir_);
%
countername = 'ccb_ly_fut';
bookname = 'book-demotrading-wlprbatman';
strategyname = 'wlprbatman';
riskconfigfilename = 'wrbatmanconfig_demotrading.txt';
% tradesfilename = 'C:\yangyiran\ops\save\citic_kim_fut-book-demotrading-wlprbatman\citic_kim_fut-book-demotrading-wlprbatman_trades_20181115.txt';
tradesfilename = '';
combos = rtt_setup('CounterName',countername,...
    'BookName',bookname,...
    'StrategyName',strategyname,...
    'RiskConfigFileName',riskconfigfilename,...
    'TradesFileName',tradesfilename);
%%
availablefund = 1e6;
combos.strategy.setavailablefund(availablefund,'firstset',true);
fprintf('\ncombos strategy init historical data...\n');
combos.strategy.initdata;
fprintf('\ncombos successfully created...\n');
%%
combos.ops.book_.printpositions;
%%
combos.strategy.printinfo

%%
fprintf('\ncombos mdefut ctp login...\n');
combos.mdefut.login('Connection','CTP','CounterName',countername);
%%
c = combos.ops.getcounter;
if ~c.is_Counter_Login;c.login;end
%%
%start mdefut to receive live market quotes
combos.mdefut.start
combos.ops.start;
%%
combos.strategy.start;

%%
instruments = combos.strategy.getinstruments;
combos.strategy.withdrawentrusts(instruments{1});
%%
combos.mdefut.stop
%%
warning('on');
c.logout
%%
combos.mdefut.logoff
%% unwind particular trade
idx = 3;
closespread = 0;
trade2unwind = combos.ops.trades_.node_(idx);
if trade2unwind.opendirection_ == 1 && ~strcmpi(trade2unwind.status_,'closed')
    q = combos.mdefut.qms_.getquote(trade2unwind.code_);
    ret = obj.shortclose(trade2unwind.code_,...
        trade2unwind.openvolume_,...
        closetodayFlag,...
        'time',now,...
        'overrideprice',q.bid1+closespread,...
        'tradeid',trade2unwind.id_);
elseif trade2unwind.opendirection_ == -1 && ~strcmpi(trade2unwind.status_,'closed')
    q = combos.mdefut.qms_.getquote(trade2unwind.code_);
    ret = obj.longclose(trade2unwind.code_,...
        trade2unwind.openvolume_,...
        closetodayFlag,...
        'time',now,...
        'overrideprice',q.ask1-closespread,...
        'tradeid',trade2unwind.id_);
end
%%
timers = timerfindall;
for i = 1:size(timers,2)
    fprintf('%s:running:%s\n',timers(i).tag,timers(i).Running);
end
%%
if strcmpi(countername,'ccb_ly_fut')
    tradesoutputdir = [getenv('ONEDRIVE'),'\trading\ccblyfut\'];
elseif strcmpi(countername,'citic_kim_fut')
    tradesoutputdir = [getenv('ONEDRIVE'),'\trading\citickimfut\'];
end
tradesoutputdir = [tradesoutputdir,strategyname,'\',bookname,'\'];
if isempty(dir(tradesoutputdir)),mkdir(tradesoutputdir);end

filename = ['trades_',datestr(getlastbusinessdate,'yyyymmdd'),'.txt'];
combos.ops.trades_.totxt([tradesoutputdir,filename]);

