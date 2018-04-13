function [] = init(obj,name,trader,book)
%cOps
    if ~ischar(name), error('cOps:init invalid name input');end
    if ~isa(trader,'cTrader'), error('cOps:init:invalid trader input');end
    if ~isa(book,'cBook'), error('cOps:init:invalid book input');end
    obj.name_ = name;
    obj.trader_ = trader;
    obj.book_ = book;
    
    obj.entrusts_ = EntrustArray;
    obj.entrustspending_ = EntrustArray;
    obj.entrustsfinished_ = EntrustArray;
end