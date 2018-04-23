login_counter_opt1;
%%
qms_fut = cQMS;
qms_fut.setdatasource('ctp');
mde_fut = cMDEFut;
mde_fut.qms_ = qms_fut;
%%
sec = cFutures('ni1807');
sec.loadinfo('ni1807_info.txt');
%%
mde_fut.registerinstrument(sec);
%%
mde_fut.timer_interval_ = 0.5;
mde_fut.start
%%
candle = mde_fut.getlastcandle(sec);
fprintf('K线时间:%s\t开:%4.0f\t高:%4.0f\t低:%4.0f\t收:%4.0f\n',...
    datestr(candle{1}(1),'yy-mm-dd HH:MM'),candle{1}(2),candle{1}(3),candle{1}(4),candle{1}(5));
%%
mde_fut.stop
%%
strat = cStratManual;
%%
strat.registercounter(c_opt1);
%%
strat.mde_fut_ = mde_fut;
strat.registerinstrument(sec);
%%
strat.start
%%
strat.longopensingleinstrument(sec.code_ctp,1,10);
%%
strat.withdrawentrusts(sec.code_ctp);
%%
n = strat.helper_.entrustspending_.count;
fprintf('未成交单:\n')
if n == 0
    fprintf('无未成交单\n');
end
for i = 1:n
    fprintf('\t报单编号:%d 合约:%s 报单价格:%4.0f 报单手数:%d 成交手数:%d\n',...
        strat.helper_.entrustspending_.node(i).entrustNo,...
        strat.helper_.entrustspending_.node(i).instrumentCode,...
        strat.helper_.entrustspending_.node(i).price,...
        strat.helper_.entrustspending_.node(i).volume,...
        strat.helper_.entrustspending_.node(i).dealVolume)
end
%%
strat.bookrunning_.printpositions;
%%
strat.stop