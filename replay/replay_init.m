% define a replay counter
replay_counter = CounterCTP.citic_kim_fut;
% define a replay QMS and MDEFut
replay_qms = cQMS;replay_qms.setdatasource('local');
replay_mdefut = cMDEFut;
replay_mdefut.qms_ = replay_qms;
replay_mdefut.mode_ = 'replay';
% define a replay trader
replay_trader = cTrader;
replay_trader.init('replay_trader');
% define an empty book and add the book to the trader
replay_book = cBook('BookName','replay_book',...
    'TraderName',replay_trader.name_,...
    'CounterName',replay_counter.char);
% replay_book.init('replay_book',replay_trader.name_,replay_counter);
replay_trader.addbook(replay_book);
% define a replay ops
replay_ops = cOps('Name','replay_ops');
replay_ops.registerbook(replay_book);
replay_ops.registercounter(replay_counter);
replay_ops.registermdefut(replay_mdefut);
replay_ops.mode_ = 'replay';


