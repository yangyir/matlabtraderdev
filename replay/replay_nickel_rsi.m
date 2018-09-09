%%
replay_init;
%%
code_ctp_instruments = {'ni1801'};

%%
n = size(code_ctp_instruments,1);
instruments_replay = cell(n,1);
for i = 1:n
    instruments_replay{i} = cFutures(code_ctp_instruments{i});
    instruments_replay{i}.loadinfo([code_ctp_instruments{i},'_info.txt']);
    qms_replay.registerinstrument(instruments_replay{i});
end

%%
strat_replay = cStratFutSingleRSI;
for i = 1:n
    strat_replay.registerinstrument(instruments_replay{i});
end

%%
replayperiodstart = '2017-09-14';
replayperiodend = '2017-09-15';
%%
% init the trading system for replay
ts_replay = cTradingSystem;
for i = 1:n
    ts_replay.registerinstrument(instruments_replay{i});
end
ts_replay.qms_ = qms_replay;
ts_replay.strat_ = strat_replay;
ts_replay.switch2relaymode;
ts_replay.loadrelaytimevec(replayperiodstart,replayperiodend);
%%
ts_replay.autotrade;
%%
ts_replay.stop;
