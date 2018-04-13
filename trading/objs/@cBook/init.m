function [] = init(obj,bookname,trader,counter)
%cBook
    if ~ischar(bookname), error('cBook:invalid bookname input');end
    obj.bookname_ = bookname;
    if ~ischar(trader), error('cBook:invalid trader input');end
    obj.trader_ = trader;
    if ~isa(counter,'CounterCTP'), error('cBook:invalid counter input');end
    obj.counter_ = counter;
end