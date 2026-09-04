symbols = {'EURUSD';'USDJPY'};

replay1 = '2026-07-17';
replay2 = '2026-07-18';
%
fx_feed_replay = charlotteDataFeedFX('symbol',symbols,...
    'mode','replay',...
    'replaydatefrom',replay1,...
    'replaydateto',replay2);

fx_feed_replay.addlistener('CandleUpdated_M15',@fx_feed_replay.OnCandleUpdated_M15);
fx_feed_replay.addlistener('CandleUpdated_M30',@fx_feed_replay.OnCandleUpdated_M30);
fx_feed_replay.addlistener('CandleUpdated_H1',@fx_feed_replay.OnCandleUpdated_H1);
fx_feed_replay.addlistener('CandleUpdated_H4',@fx_feed_replay.OnCandleUpdated_H4);

fprintf('last m15 candle time:%s\n',fx_feed_replay.getLastBarTime(symbols{1},'m15')); % last m15 candle time:20260716 23:50
fprintf('last m30 candle time:%s\n',fx_feed_replay.getLastBarTime(symbols{1},'m30')); % last m30 candle time:20260716 23:35
fprintf('last  h1 candle time:%s\n',fx_feed_replay.getLastBarTime(symbols{1},'H1'));  % last  h1 candle time:20260716 23:05
fprintf('last  h4 candle time:%s\n',fx_feed_replay.getLastBarTime(symbols{1},'H4'));  % last  h4 candle time:20260716 20:05
fprintf('\n');

fx_feed_replay.addlistener('ErrorOccurred',@fx_feed_replay.OnError);


%%
fx_feed_replay.start;
%%
fprintf('last  h1 candle time:%s\n',fx_feed_replay.getLastBarTime(symbols{1},'h1'));  % last h1 candle time:20260717 21:00
fprintf('last  h4 candle time:%s\n',fx_feed_replay.getLastBarTime(symbols{1},'H4'));  % last h4 candle time:20260717 20:00
