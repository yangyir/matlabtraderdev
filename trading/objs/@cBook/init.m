function [] = init(obj,trader,counter)
%cBook
    if ~ischar(trader), error('cBook:invalid trader input');end
    obj.trader_ = trader;
    if ~isa(counter,'CounterCTP'), error('cBook:invalid counter input');end
    obj.counter_ = counter;
end