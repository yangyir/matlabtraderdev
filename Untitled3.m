login_counter_opt1;
%%
init_mde;
%%
strat = cStratManual;
strat.registercounter(c_opt1);
strat.mde_fut_ = mdefut;
%%
codes = {'ni1807';'rb1810';'TF1806';'T1806';'cu1807';'zn1807'};
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
%%
candles = mdefut.getlastcandle;
fprintf('candle:\n');
for i = 1:size(candles,1)
    if isempty(candles{i}), continue;end
    fprintf('\tinstrument:%12s open:%6s high:%6s low:%6s close:%6s time:%12s\n',...
        strat.instruments_.getinstrument{i}.code_ctp,...
        num2str(candles{i}(2)),num2str(candles{i}(3)),num2str(candles{i}(4)),num2str(candles{i}(5)),...
        datestr(candles{i}(1),'yy-mm-dd HH:MM'));
end

%% long open positions
sec_long_open = 'cu1807';
lots_long_open = 1;
spreads_long_open = 5;
px = 50880;
strat.longopensingleinstrument(sec_long_open,lots_long_open,spreads_long_open,'overrideprice',px);

%% short close positions
sec_short_close = 'ni1807';
lots_short_close = 1;
closetoday = 0;
spreads_short_close = 1;
strat.shortclosesingleinstrument(sec_short_close,lots_short_close,closetoday,spreads_short_close);

%% short open positions
sec_short_open = 'ni1807';
lots_short_open = 1;
spreads_short_open = 8;
px = 109000;
strat.shortopensingleinstrument(sec_short_open,lots_short_open,spreads_short_open,'overrideprice',px);

%% withdraw pending entrusts
strat.withdrawentrusts('ni1807');

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
