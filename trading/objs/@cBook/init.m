function [obj] = init(obj,varargin)
%cBook
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('BookName','',@ischar);
    p.addParameter('TraderName','',@ischar);
    p.addParameter('CounterName','',@ischar);
    p.parse(varargin{:});
    bookname = p.Results.BookName;
    tradername = p.Results.TraderName;
    countername = p.Results.CounterName;
    obj.bookname_ = bookname;
    obj.tradername_ = tradername;
    obj.countername_ = countername;
    
    obj.positions_ = {};
    
end