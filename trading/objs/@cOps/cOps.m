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
        %
        trades_@cTradeOpenArray
    end
    
    properties (Access = private)
        minute_count_@double = 0
    end
    
    methods
        function obj = cOps(varargin)
            obj.name_ = 'myops';
            obj.timer_interval_ = 0.5;
            obj.display_ = true;
        end
    end
    
    methods
        [] = init(obj,name,book)
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = printpendingentrusts(obj)
        [] = printallentrusts(obj)
        pnl = calcrunningpnl(obj,varargin)
        [] = printrunningpnl(obj,varargin)
        %
        [ret] = savetradestofile(obj,varargin)
        [ret] = loadtradesfromfile(obj,varargin)
    end
    
    methods (Access = private)
        [] = updateentrustsandbook(obj)
        %note:yangyiran-20180810
        %func 'updateentrustsandbook2' differs from 'updateentrustsandbook'
        %as it update the book from trades directly
        [] = updateentrustsandbook2(obj)
        %
        [ret] = displayinfo(obj,time,varargin)
    end
end