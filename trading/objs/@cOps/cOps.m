classdef cOps < cMyTimerObj
    % des:operation (ops) object who helps the trader object to process
    % entrusts, i.e. 1) update processed entrusts; 2) process pending
    % entrusts
    % and to update positions in book
    % rule: one ops can be only linked to one book
    properties
        name_@char
%         trader_@cTrader
        book_@cBook
        
        entrusts_@EntrustArray
        entrustspending_@EntrustArray
        entrustsfinished_@EntrustArray
    end
    
    methods
%         [] = init(obj,name,trader,book)
        [] = init(obj,name,book)
        [] = refresh(obj)
    end
    
    methods (Access = private)
        [] = updateentrustsandbook(obj)
    end
end