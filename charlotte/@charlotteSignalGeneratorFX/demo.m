symbols = {'EURUSD';'USDJPY'};

replay1 = '2026-07-17';
replay2 = '2026-07-18';
%
fx_feed_replay = charlotteDataFeedFX('symbol',symbols,...
    'mode','replay',...
    'replaydatefrom',replay1,...
    'replaydateto',replay2);

fx_feed_replay.addlistener('CandleUpdated_H1',@fx_feed_replay.OnCandleUpdated_H1);
fx_feed_replay.addlistener('ErrorOccurred',@fx_feed_replay.OnError);
%%
fx_signalgenerator_replay = charlotteSignalGeneratorFX('codes',symbols,...
    'freqs',{'h1';'h1'},...
    'datafeed',fx_feed_replay);
fx_feed_replay.addlistener('CandleUpdated_H1',@fx_signalgenerator_replay.OnNewCandle_H1);


%%
fx_feed_replay.start;
%%
fprintf('last  h1 candle time:%s\n',fx_feed_replay.getLastBarTime(symbols{1},'h1'));  % last h1 candle time:20260717 21:00
fprintf('last  h4 candle time:%s\n',fx_feed_replay.getLastBarTime(symbols{1},'H4'));  % last h4 candle time:20260717 20:00
