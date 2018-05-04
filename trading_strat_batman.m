%% login CTP counter
login_counter_fut;
%% init MDE, i.e. market data engine
init_mde;
%% init batman strategy
strat_batman = cStratFutBatman;
strat_batman.registercounter(c_fut);
strat_batman.mde_fut_ = mdefut;
%% register MDE and strategy with futures of interest
codes = {'ni1807';'rb1810';'TF1806';'T1806';'zn1807';'cu1807';'i1809'};
secs = cell(size(codes));
for i = 1:size(codes,1)
    secs{i} = cFutures(codes{i});secs{i}.loadinfo([codes{i},'_info.txt']);
    mdefut.registerinstrument(secs{i});
    strat_batman.registerinstrument(secs{i});
end
%% set stop/loss and limit for one futures to trade
strat_batman.setlimittype('rb1810','abs');strat_batman.setlimitamount('rb1810',10000);
strat_batman.setstoptype('rb1810','abs');strat_batman.setstopamount('rb1810',-1000);
%% load existing positions from CTP counter
strat_batman.loadbookfromcounter('FutList','all');
%% print positions
strat_batman.bookrunning_.printpositions;

%% start mdefut
mdefut.timer_interval_ = 0.5;
mdefut.start
%% start the strategy
strat_batman.start
%% display market quotes
candles = mdefut.getlastcandle;
fprintf('candle:\n');
for i = 1:size(candles,1)
    if isempty(candles{i}), continue;end
    fprintf('\tinstrument:%12s open:%6s high:%6s low:%6s close:%6s time:%12s\n',...
        strat_batman.instruments_.getinstrument{i}.code_ctp,...
        num2str(candles{i}(2)),num2str(candles{i}(3)),num2str(candles{i}(4)),num2str(candles{i}(5)),...
        datestr(candles{i}(1),'yy-mm-dd HH:MM'));
end
%% print positions and real-time running pnl
strat_batman.helper_.printrunningpnl('MDEFut',mdefut);
%% long open positions
sec_lo = 'T1806';
lots_lo = 1;
spd_lo = 5;
% place entrust with spreads to the market quotes
strat_batman.longopensingleinstrument(sec_lo,lots_lo,spd_lo);
% place entrust with specified price
overridepx = 94.51;
strat_batman.longopensingleinstrument(sec_lo,lots_lo,[],'overrideprice',overridepx);

%% short close positions
sec_sc = 'ni1807';
lots_sc = 1;
closetoday_sc = 1;
spd_sc = 1;
strat_batman.shortclosesingleinstrument(sec_sc,lots_sc,closetoday_sc,spd_sc);

%% short open positions
sec_so = 'rb1810';
lots_so = 1;
spd_so = 8;
strat_batman.shortopensingleinstrument(sec_so,lots_so,spd_so);

%% long close positions
sec_lc = 'rb1810';
lots_lc = 1;
closetoday_lc = 1;
spd_lc = 1;
strat_batman.shortclosesingleinstrument(sec_lc,lots_lc,closetoday_lc,spd_lc);

%% withdraw pending entrusts
strat_batman.withdrawentrusts('ni1807');

%% display pending entrusts
strat_batman.helper_.printpendingentrusts;

%% display all entrusts with their detailed info
strat_batman.helper_.printallentrusts;

%% stop strategy
strat_batman.helper_.stop;
strat_batman.stop
%% stop mde
mdefut.stop
%% logoff CTP counter
c_fut.logout;
%% delete timer
try
    delete(timerfindall);
catch
end

