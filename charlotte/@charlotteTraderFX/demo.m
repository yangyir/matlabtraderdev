clc;

symbols = {'XAUUSD'};
freqs = {'h4'};
replay1 = '2026-08-19';
replay2 = '2026-08-21';
fx_feed_replay = charlotteDataFeedFX('symbol',symbols,...
    'mode','replay',...
    'replaydatefrom',replay1,...
    'replaydateto',replay2);

% fx_feed_replay.addlistener('CandleUpdated_H1',@fx_feed_replay.OnCandleUpdated_H1);
fx_feed_replay.addlistener('ErrorOccurred',@fx_feed_replay.OnError);
%

fx_trader_replay = charlotteTraderFX('codes',symbols,'freqs',freqs);

fx_signalgenerator_replay = charlotteSignalGeneratorFX('codes',symbols,...
    'freqs',freqs,...
    'datafeed',fx_feed_replay);
fx_feed_replay.addlistener('CandleUpdated_H4',@fx_signalgenerator_replay.OnNewCandle_H4);
fx_signalgenerator_replay.addlistener('NewSignalGenerated',@fx_trader_replay.OnNewSignal);
fx_feed_replay.addlistener('CandleUpdated_M30',@fx_trader_replay.OnNewBar_M30);
fx_feed_replay.addlistener('CandleUpdated_H4',@fx_trader_replay.OnNewBar_H4);
%%
fx_feed_replay.start;
%%
fx_trader_replay.showMeTheBook;


