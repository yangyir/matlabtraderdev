login_counter_opt2;
%%
init_mde;
%%
strat = cStratManual;
strat.registercounter(c_opt2);
strat.mde_fut_ = mdefut;
%%
codes = {'ni1807';'rb1810';'TF1806';'T1806';'i1809';'zn1807';'cu1807';'al1807';'TF1809';'T1809'};
secs = cell(size(codes));
for i = 1:size(codes,1)
    secs{i} = cFutures(codes{i});secs{i}.loadinfo([codes{i},'_info.txt']);
    mdefut.registerinstrument(secs{i});
    strat.registerinstrument(secs{i});
end

%% start mdefut
mdefut.timer_interval_ = 0.5;
mdefut.start
%%
strat.loadbookfromcounter('FutList','all');
%% print positions
strat.bookrunning_.printpositions;
%% print positions and real-time running pnl
strat.helper_.printrunningpnl('MDEFut',mdefut);
%%
strat.start
%% print implied yield info
q05y = mdefut.qms_.getquote('TF1809');
q10y = mdefut.qms_.getquote('T1809');
fprintf('5y yld:%4.2f;10y yld:%4.2f:sread:%4.2f\n',q05y.yield_last_trade,q10y.yield_last_trade,(q10y.yield_last_trade-q05y.yield_last_trade)*100);

%% long TF and short T
%
sec_long_open = 'rb1810';
lots_long_open = 1;
spreads_long_open = 1;
strat.longopensingleinstrument(sec_long_open,lots_long_open,spreads_long_open);
%
%%
sec_short_open = 'T1809';
lots_short_open = 1;
spreads_short_open = 3;
strat.shortopensingleinstrument(sec_short_open,lots_short_open,spreads_short_open);

%% withdraw pending entrusts
strat.withdrawentrusts('TF1809');
strat.withdrawentrusts('T1809');

%% display pending entrusts
strat.helper_.printpendingentrusts;

%% display all entrusts with their detailed info
strat.helper_.printallentrusts;

%% stop strategy
strat.helper_.stop;
strat.stop
%% stop mde
mdefut.stop
%% logoff counters
c_opt1.logout;
