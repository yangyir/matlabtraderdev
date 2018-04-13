function [bool,idx] = hasbook(obj,book)
%cTrader
    bool = false;
    idx = 0;
    if ~isa(book,'cBook'),error('cTrader:hasbook:invalid book input');end
    n = size(obj.books_,1);
    for i = 1:n
        if strcmpi(book.bookname_,obj.books_{i}.bookname_)
            bool = true;
            idx = i;
            break
        end
    end
end