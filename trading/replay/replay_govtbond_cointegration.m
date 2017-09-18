%%
% init qms for replay. as we know that we only use the local '.txt' file
% for replay
qms_replay = cQMS;
qms_replay.setdatasource('local');
%%
% init the instrument(s) used in replay and register instrument(s) with the
% qms
instrument1_replay = cFutures('TF1712');
instrument1_replay.loadinfo('TF1712_info.txt');
%
instrument2_replay = cFutures('T1712');
instrument2_replay.loadinfo('T1712_info.txt');
%
qms_replay.registerinstrument(instrument1_replay);
qms_replay.registerinstrument(instrument2_replay);
%%
% define the replay strategy and register the instrument with the strategy
strat_replay = cStratFutPairCointegration;
strat_replay.registerinstrument(instrument1_replay);
strat_replay.registerinstrument(instrument2_replay);
%%
% strategy definition part, this shall vary across different strategies
initdataperiodstart = '2017-09-14';
initdataperiodend = '2017-09-14';
strat_replay.initdata(initdataperiodstart,initdataperiodstart);
%%
% define the replay period 
replayperiodstart = '2017-09-15';
replayperiodend = '2017-09-15';
%%
% init the trading system for replay
ts_replay = cTradingSystem;
ts_replay.registerinstrument(instrument1_replay);
ts_replay.registerinstrument(instrument2_replay);
ts_replay.qms_ = qms_replay;
ts_replay.strat_ = strat_replay;
ts_replay.switch2relaymode;
ts_replay.loadrelaytimevec(replayperiodstart,replayperiodend);
%%
ts_replay.autotrade;
%%
ts_replay.stop;
%%
ts_replay.replaysimtradeonce;
