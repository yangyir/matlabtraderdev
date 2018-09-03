classdef cOps < cMyTimerObj
    % des:operation (ops) object who helps the trader object to process
    % entrusts, i.e. 1) update processed entrusts; 2) process pending
    % entrusts
    % and to update positions in book
    % rule: one ops can be only linked to one book
    properties
        book_@cBook
        %
        entrusts_@EntrustArray
        entrustspending_@EntrustArray
        entrustsfinished_@EntrustArray
        %
        mdefut_@cMDEFut
        mdeopt_@cMDEFut
        %
        trades_@cTradeOpenArray
    end
    
    methods
        function obj = cOps(varargin)
%             obj.name_ = 'myops';
%             obj.timer_interval_ = 0.5;
            obj = init(obj,varargin{:});
        end
    end
    
    methods
%         [] = init(obj,name,book)
        %
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = savemktdata(obj,varargin)
        [] = savetrades(obj,varargin)
        [] = loadmktdata(obj,varargin)
        [] = loadtrades(obj,varargin)
        [t] = getreplaytime(obj,varargin)
        %
        [] = printpendingentrusts(obj)
        [] = printallentrusts(obj)
        pnl = calcrunningpnl(obj,varargin)
        [] = printrunningpnl(obj,varargin)
        %
    end
    
    methods (Access = private)
        [obj] = init(obj,varargin)
        [] = updateentrustsandbook(obj)
        %note:yangyiran-20180810
        %func 'updateentrustsandbook2' differs from 'updateentrustsandbook'
        %as it update the book from trades directly
        [] = updateentrustsandbook2(obj)
        %
    end
end