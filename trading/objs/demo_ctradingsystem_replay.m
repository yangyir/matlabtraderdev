clear;
clc;

%%
instrument = cFutures('T1712');
instrument.loadinfo('T1712_info.txt');

qms_demo = cQMS;
qms_demo.setdatasource('local');
qms_demo.registerinstrument(instrument);

qms_demo.refresh('2017-09-11 15:55:00');

quote_demo = qms_demo.getquote(instrument);

quote_demo.print;

%%
strat_demo = cStratFutSingleSyntheticOpt;
strat_demo.registerinstrument(instrument);
strat_demo.addoptleg('c',1,'2017-12-15',1e8,0.02/sqrt(252));

%%
ts_demo = cTradingSystem;
ts_demo.registerinstrument(instrument);
ts_demo.qms_ = qms_demo;
ts_demo.strat_ = strat_demo;
ts_demo.switch2relaymode;
fromdate = '2017-09-08';
todate = '2017-09-11';
ts_demo.loadrelaytimevec(fromdate,todate);
ts_demo.autotrade;

%%
ts_demo.manualtrade


%%
ts_demo.stop;