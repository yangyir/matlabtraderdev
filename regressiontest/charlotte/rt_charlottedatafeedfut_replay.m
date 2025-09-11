
codes = {'IM2509'};

%
fut_feed_replay = charlotteDataFeedFut('codes',codes,'mode','replay','replayfrom','2025-09-04','replayto','2025-09-04');

fut_feed_replay.addlistener('MarketClose',@fut_feed_replay.onMarketClose);
fut_feed_replay.addlistener('MarketOpen',@fut_feed_replay.onMarketOpen);
%
fut_processor_replay = charlotteDataProcessorFut(fut_feed_replay);
fut_feed_replay.addlistener('NewDataArrived',@fut_processor_replay.onNewData);
fut_feed_replay.addlistener('MarketClose',@fut_processor_replay.onMarketClose);
%
fut_display_replay = charlotteDataVisualizerFut(codes);
fut_display_replay.loadHistoricalData('code',codes{1},'datefrom','2025-08-27','dateto','2025-09-03');
fut_processor_replay.addlistener('NewBarSetM5', @fut_display_replay.onNewBarSetM5);
fut_processor_replay.addlistener('NewBarSetM30', @fut_display_replay.onNewBarSetM30);

%%
fut_feed_replay.updateinterval_ = 0.01;

% fut_feed_replay