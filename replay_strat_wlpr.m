timeratio_replay = 5;
counter_replay = CounterCTP.citic_kim_fut;
trader_replay = cTrader;
trader_replay.init('wlpr');
book_replay = cBook;
book_replay.init('bookrunning_wlpr',trader_replay.name_,counter_replay);
trader_replay.addbook(book_replay);
ops_replay = cOps;
ops_replay.init('wlpr_ops',book_replay);
ops_replay.timer_interval_ = 1/timeratio_replay;
ops_replay.mode_ = 'replay';
qms_replay = cQMS;qms_replay.setdatasource('local');

%%
mdefut_replay = cMDEFut;
mdefut_replay.qms_ = qms_replay;
mdefut_replay.initreplayer('code','rb1810','fn','rb1810_20180502_tick.mat');
mdefut_replay.timer_interval_ = 0.5/timeratio_replay;
mdefut_replay.registerinstrument('rb1810');
%%
stratwlpr_replay = cStratFutMultiWR;
stratwlpr_replay.registerinstrument('rb1810');
stratwlpr_replay.mode_ = 'replay';
stratwlpr_replay.mde_fut_ = mdefut_replay;
stratwlpr_replay.trader_ = trader_replay;
ops_replay.mdefut_ = mdefut_replay;
stratwlpr_replay.helper_ = ops_replay;
stratwlpr_replay.bookrunning_ = book_replay;
stratwlpr_replay.bookbase_ = book_replay;
stratwlpr_replay.counter_ = counter_replay;
stratwlpr_replay.timer_interval_ = 60/timeratio_replay;
%%
stratwlpr_replay.setlimittype('rb1810','abs');
stratwlpr_replay.setstoptype('rb1810','abs');
stratwlpr_replay.setstopamount('rb1810',-inf);
%%
stratwlpr_replay.helper_.start;
%%
stratwlpr_replay.start;
%%
mdefut_replay.start;
%%
ticks = mdefut_replay.getlasttick('rb1810');
fprintf('last tick time:%s:; trade:%s\n',datestr(ticks(1),'yyyy-mm-dd HH:MM:SS'),num2str(ticks(2)));
%%
% stratwlpr_replay.longopensingleinstrument('rb1810',100,[],'overrideprice',3640);
% %%
% stratwlpr_replay.shortclosesingleinstrument('rb1810',99,1,[],'overrideprice',3650);
%%
stratwlpr_replay.helper_.printpendingentrusts;
%%
stratwlpr_replay.helper_.printallentrusts;
%%
stratwlpr_replay.bookrunning_.printpositions;
%%
stratwlpr_replay.helper_.printrunningpnl('MDEFut',mdefut_replay);

%% stop everything
mdefut_replay.stop;
mdefut_replay.replay_count_ = 1;
stratwlpr_replay.helper_.stop
stratwlpr_replay.stop;
delete(timerfindall)
