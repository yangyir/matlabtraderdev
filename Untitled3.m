login_counter_opt1;
%%
init_mde;
%%
strat = cStratManual;
strat.registercounter(c_opt1);
strat.mde_fut_ = mdefut;
%%
sec = cFutures('ni1807');
sec.loadinfo('ni1807_info.txt');
mdefut.registerinstrument(sec);
strat.registerinstrument(sec);
%% register new contract
sec_add = cFutures('rb1810');
sec_add.loadinfo('rb1810_info.txt');
mdefut.registerinstrument(sec_add);
strat.registerinstrument(sec_add);
%% start mdefut
mdefut.timer_interval_ = 0.5;
mdefut.start
%%
%check the latest candle of selected futures
sec_select = sec;
candles = mdefut.getlastcandle;
fprintf('candle:\n');
for i = 1:size(candles,1)
fprintf('\tinstrument:%12s open:%6s high:%6s low:%6s close:%6s time:%12s\n',...
    strat.instruments_.getinstrument{i}.code_ctp,...
    num2str(candles{i}(2)),num2str(candles{i}(3)),num2str(candles{i}(4)),num2str(candles{i}(5)),...
    datestr(candles{i}(1),'yy-mm-dd HH:MM'));
end

%%
strat.loadbookfromcounter('futlist','all');
%%
strat.bookrunning_.printpositions;
%%
strat.start
%% long open positions
sec_long_open = 'ni1807';
lots_long_open = 1;
spreads_long_open = 50;
strat.longopensingleinstrument(sec_long_open,lots_long_open,spreads_long_open);

%% short close positions
sec_short_close = 'ni1807';
lots_short_close = 1;
closetoday = 0;
spreads_short_close = 1;
strat.shortclosesingleinstrument(sec_short_close,lots_short_close,closetoday,spreads_short_close);

%% short open positions
sec_short_open = 'rb1810';
lots_short_open = 1;
spreads_short_open = 8;
strat.shortopensingleinstrument(sec_short_open,lots_short_open,spreads_short_open);

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
%%
delete(timerfindall)
%%
strat.helper_.entrustspending_.latest
