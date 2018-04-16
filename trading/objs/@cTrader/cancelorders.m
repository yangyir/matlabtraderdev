function [ret,entrusts] = cancelorders(obj,codestr,book)
%cTrader
    variablenotused(obj);
    if ~ischar(codestr), error('cTrader:cancelorders:invalid code input');end
    if ~isa(book,'cBook'), error('cTrader:cancelorders:invalid book input');end
    
    [~,entrusts] = statsentrust(book.counter_,codestr);
    ret = 0;
    for i = 1:size(entrusts,1)
        e = entrusts{i};
        [ret] = withdrawentrust(book.counter_,e);
    end
    
end