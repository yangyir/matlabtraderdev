% the replay template is used for check whether the strategy code works
% properly, i.e. are there any errors within the code. please note that
% replay itself is not back testing as it is much slower and it checks all
% the codes relates to the trading part.
%%
% init qms for replay. as we know that we only use the local '.txt' file
% for replay
if ~(exist('qms_replay','var') && isa(qms_replay,'cQMS'))
    qms_replay = cQMS;
    qms_replay.setdatasource('local');
end
%%
% init the instrument(s) used in replay and register instrument(s) with the
% qms
instrument_replay = cFutures('ni1801');
instrument_replay.loadinfo('ni1801_info.txt');
qms_replay.registerinstrument(instrument_replay);
%%
% define the replay strategy and register the instrument with the strategy
strat_replay = cStratFutSingleSyntheticOpt;
strat_replay.registerinstrument(instrument_replay);
%%
% strategy definition part, this shall vary across different strategies
strat_replay.addoptleg('c',1,'2017-12-15',5e6,0.24/sqrt(252));
%%
% define the replay period 
replayperiodstart = '2017-09-14';
replayperiodend = '2017-09-15';
%%
% init the trading system for replay
ts_replay = cTradingSystem;
ts_replay.registerinstrument(instrument_replay);
ts_replay.qms_ = qms_replay;
ts_replay.strat_ = strat_replay;
ts_replay.switch2relaymode;
ts_replay.loadrelaytimevec(replayperiodstart,replayperiodend);
%%
ts_replay.autotrade;
%%
ts_replay.stop;
