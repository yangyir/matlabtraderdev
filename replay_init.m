% define a replay counter
replay_counter = CounterCTP.citic_kim_fut;
% define a replay QMS and MDEFut
replay_qms = cQMS;replay_qms.setdatasource('local');
replay_mdefut = cMDEFut;
replay_mdefut.qms_ = replay_qms;
replay_mdefut.display_ = 1;
replay_mdefut.mode_ = 'replay';
% define a replay trader
replay_trader = cTrader;
replay_trader.init('replay_trader');
% define an empty book and add the book to the trader
replay_book = cBook;
replay_book.init('replay_book',replay_trader.name_,replay_counter);
replay_trader.addbook(replay_book);
% define a replay ops
replay_ops = cOps;
replay_ops.mode_ = 'replay';
replay_ops.init('replay_ops',replay_book);
replay_ops.mdefut_ = replay_mdefut;

