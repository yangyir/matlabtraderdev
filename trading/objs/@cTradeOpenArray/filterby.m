function [new] = filterby(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('CounterName','',@ischar);
    p.addParameter('BookName','',@ischar);
    p.addParameter('Code','',@ischar);
    p.addParameter('Status','all',@ischar);
    p.parse(varargin{:});
    counterName = p.Results.CounterName;
    bookName = p.Results.BookName;
    code = p.Results.Code;
    status = p.Results.Status;
    
    if ~(strcmpi(status,'live') || strcmpi(status,'closed') || strcmpi(status,'all'))
        error('cTradeOpenArray:filterby:invalid status input, shall be live, closed or all only');
    end
    
    if isempty(counterName), useCounterName = 0; else useCounterName = 1;end
    if isempty(bookName), useBookName = 0; else useBookName = 1;end
    if isempty(code), useCode = 0; else useCode = 1;end
    if strcmpi(status,'all'), useStatus = 0; else useStatus = 1;end
    
    n = obj.count;
    new = feval(class(obj));
    for i = 1:n
        trade_i = obj.node_(i);
        useFlag = 1;
        if useFlag && useCounterName && ~strcmpi(trade_i.countername_,counterName), useFlag = 0;end
        if useFlag && useBookName && ~strcmpi(trade_i.bookname_,bookName),useFlag = 0;end
        if useFlag && useCode && ~strcmpi(trade_i.code_,code),useFlag = 0;end
        if useFlag && useStatus
            if strcmpi(status,'live')
                if strcmpi(trade_i.status_,'closed')
                    useFlag = 0;
                else
                    useFlag = 1;
                end
            else
                if ~strcmpi(trade_i.status_,'closed')
                    useFlag = 0;
                else
                    useFlag = 1;
                end
            end
        end
        if useFlag, new.push(trade_i);end
            
    end
    
end