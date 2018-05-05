classdef cOps < cMyTimerObj
    % des:operation (ops) object who helps the trader object to process
    % entrusts, i.e. 1) update processed entrusts; 2) process pending
    % entrusts
    % and to update positions in book
    % rule: one ops can be only linked to one book
    properties
        book_@cBook
        
        entrusts_@EntrustArray
        entrustspending_@EntrustArray
        entrustsfinished_@EntrustArray
        
        display_@logical = false
        %
        mdefut_@cMDEFut
        mdeopt_@cMDEFut
    end
    
    methods
        [] = init(obj,name,book)
        [] = refresh(obj)
        [] = printpendingentrusts(obj)
        [] = printallentrusts(obj)
        pnl = calcrunningpnl(obj,varargin)
        [] = printrunningpnl(obj,varargin)
    end
    
    methods (Access = private)
        [] = updateentrustsandbook(obj)
    end
end