login_counter_opt1;
%%
init_mde;
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

%%
strat = cStratManual;
strat.registercounter(c_opt1);
strat.mde_fut_ = mdefut;
%%
strat.registerinstrument(sec);
%%
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
%%
%持仓
strat.bookrunning_.printpositions;
%%
strat.stop
%%
strat.helper_.stop;
%%
mdefut.stop