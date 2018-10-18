function [] = registerhelper(strategy,helper)
%cStrat
    if ~isa(helper,'cOps'), error('cStrat:registerhelper:invalid ops input');end
    strategy.helper_ = helper;
    
    try
        counter = helper.getcounter;
    catch e
        fprintf('cStrat:registerhelper:%s\n',e.message)
        return
    end
    
    book = helper.book_;
    tradername = book.tradername_;
    trader = cTrader;trader.init(tradername);
    trader.addbook(book);
    strategy.trader_ = trader;
    %
    
end
%end of registercounter