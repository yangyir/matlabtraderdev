login_counter_opt1;
%%
init_mde;
<<<<<<< HEAD
%%
sec = cFutures('ni1807');
sec.loadinfo('ni1807_info.txt');
%%
mdefut.registerinstrument(sec);
%%
mdefut.timer_interval_ = 0.5;
mdefut.start
%%
candle = mdefut.getlastcandle(sec);
fprintf('candlestick time:%s\topen:%4.0f\thigh:%4.0f\tlow:%4.0f\tclose:%4.0f\n',...
    datestr(candle{1}(1),'yy-mm-dd HH:MM'),candle{1}(2),candle{1}(3),candle{1}(4),candle{1}(5));

=======
>>>>>>> ab07e710ca75563f6c15d7ec6070dc984d2cb2fc
%%
strat = cStratManual;
strat.registercounter(c_opt1);
strat.mde_fut_ = mdefut;
%%
<<<<<<< HEAD
=======
sec = cFutures('ni1807');
sec.loadinfo('ni1807_info.txt');
mdefut.registerinstrument(sec);
>>>>>>> ab07e710ca75563f6c15d7ec6070dc984d2cb2fc
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
<<<<<<< HEAD
strat.loadbookfromcounter('FutList','all');
%%
%检查持仓
strat.bookrunning_.printpositions;
%%
strat.start
%%
%买开仓
strat.longopensingleinstrument(sec.code_ctp,1,3);
%%
%卖平(今）仓
strat.shortclosesingleinstrument(sec.code_ctp,1,1,2);
%%
%卖开仓
strat.shortopensingleinstrument(sec.code_ctp,1,2);
%%
%买平(今）仓
strat.longclosesingleinstrument(sec.code_ctp,1,1,3);
%%
%撤单
strat.withdrawentrusts(sec.code_ctp);
%%
%显示未成交挂单
strat.helper_.printpendingentrusts;
%%
%显示所有委托单
strat.helper_.printallentrusts;
=======
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
>>>>>>> ab07e710ca75563f6c15d7ec6070dc984d2cb2fc
%%
%持仓
strat.bookrunning_.printpositions;
%%
<<<<<<< HEAD
strat.stop
%%
strat.helper_.stop;
%%
mdefut.stop
=======
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
strat.helper_.entrustspending_.latest
>>>>>>> ab07e710ca75563f6c15d7ec6070dc984d2cb2fc
