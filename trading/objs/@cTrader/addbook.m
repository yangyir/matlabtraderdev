function [] = addbook(obj,book)
    %cTrader
    if ~isa(book,'cBook'), error('cTrader:invalid book input'); end
    
    n = size(obj.books_,1);
    books = cell(n+1,1);
    for i = 1:n, books{i} = obj.books_{i}; end
    books{n+1} = book;
    obj.books_ = books;
    
end