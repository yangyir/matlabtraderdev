timeratio_replay = 5;
counter_replay = CounterCTP.citic_kim_fut;
trader_replay = cTrader;
trader_replay.init('batman');
book_replay = cBook;
book_replay.init('bookrunning_batman',trader_replay.name_,counter_replay);
trader_replay.addbook(book_replay);
ops_replay = cOps;
ops_replay.init('batman_ops',book_replay);
ops_replay.timer_interval_ = 1/timeratio_replay;
ops_replay.mode_ = 'replay';
qms_replay = cQMS;
qms_replay.setdatasource('local');

%%
mdefut_replay = cMDEFut;
mdefut_replay.qms_ = qms_replay;
mdefut_replay.initreplayer('code','rb1810','fn','rb1810_20180502_tick.mat');
mdefut_replay.timer_interval_ = 0.5/timeratio_replay;
mdefut_replay.registerinstrument('rb1810');
%%
stratbatman_replay = cStratFutBatman;
stratbatman_replay.registerinstrument('rb1810');
stratbatman_replay.mode_ = 'replay';
stratbatman_replay.mde_fut_ = mdefut_replay;
stratbatman_replay.trader_ = trader_replay;
ops_replay.mdefut_ = mdefut_replay;
stratbatman_replay.helper_ = ops_replay;
stratbatman_replay.bookrunning_ = book_replay;
stratbatman_replay.bookbase_ = book_replay;
stratbatman_replay.counter_ = counter_replay;
stratbatman_replay.timer_interval_ = 60/timeratio_replay;
%%
stratbatman_replay.setlimittype('rb1810','abs');
stratbatman_replay.setstoptype('rb1810','abs');
stratbatman_replay.setstopamount('rb1810',-inf);
%%
stratbatman_replay.helper_.start;
%%
stratbatman_replay.start;
%%
mdefut_replay.start;
%%
ticks = mdefut_replay.getlasttick('rb1810');
fprintf('last tick time:%s:; trade:%s\n',datestr(ticks(1),'yyyy-mm-dd HH:MM:SS'),num2str(ticks(2)));
%%
stratbatman_replay.longopensingleinstrument('rb1810',100,[],'overrideprice',3635);
%%
stratbatman_replay.shortclosesingleinstrument('rb1810',6,1,[],'overrideprice',3640);
%%
stratbatman_replay.helper_.printpendingentrusts;
%%
stratbatman_replay.helper_.printallentrusts;
%%
stratbatman_replay.bookrunning_.printpositions;
%%
stratbatman_replay.helper_.printrunningpnl('MDEFut',mdefut_replay);
%%
mdefut_replay.replay_count_
mdefut_replay.getlastcandle

%% stop everything
mdefut_replay.stop;
mdefut_replay.replay_count_ = 1;
stratbatman_replay.helper_.stop
stratbatman_replay.stop;
delete(timerfindall)
