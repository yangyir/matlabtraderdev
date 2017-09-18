clear;
clc;

%%
instrument1 = cFutures('TF1712');
instrument1.loadinfo('TF1712_info.txt');
instrument2 = cFutures('T1712');
instrument2.loadinfo('T1712_info.txt');

qms_demo_cointegration = cQMS;
qms_demo_cointegration.setdatasource('local');
qms_demo_cointegration.registerinstrument(instrument1);
qms_demo_cointegration.registerinstrument(instrument2);

qms_demo_cointegration.refresh('2017-09-11 15:55:00');

quote1_demo_cointegration = qms_demo_cointegration.getquote(instrument1);
quote1_demo_cointegration.print;

quote2_demo_cointegration = qms_demo_cointegration.getquote(instrument1);
quote2_demo_cointegration.print;

%%
strat_demo_cointegration = cStratFutPairCointegration;
strat_demo_cointegration.registerinstrument(instrument1);
strat_demo_cointegration.registerinstrument(instrument2);

%%
ts_demo_cointegration = cTradingSystem;
ts_demo_cointegration.registerinstrument(instrument);
ts_demo_cointegration.qms_ = qms_demo_cointegration;
ts_demo_cointegration.strat_ = strat_demo;
ts_demo_cointegration.switch2relaymode;
fromdate = '2017-09-08';
todate = '2017-09-11';
ts_demo_cointegration.loadrelaytimevec(fromdate,todate);
ts_demo_cointegration.autotrade;

%%
ts_demo_cointegration.manualtrade


%%
ts_demo_cointegration.stop;