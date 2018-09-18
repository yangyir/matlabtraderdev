classdef cOps < cMyTimerObj
    % des:operation (ops) object who helps the trader object to process
    % entrusts, i.e. 1) update processed entrusts; 2) process pending
    % entrusts
    % and to update positions in book
    % rule: one ops can be only linked to one book
    properties (SetAccess = private, GetAccess = public)
        book_@cBook
        %
        entrusts_@EntrustArray
        entrustspending_@EntrustArray
        entrustsfinished_@EntrustArray
        %
        trades_@cTradeOpenArray
    end
    
    properties (Access = private, Hidden = true)
        %
        mdefut_@cMDEFut
        mdeopt_@cMDEFut
        counterCTP_@CounterCTP
        counterHSO32_@CounterHSO32
        counterRH_@cCounterRH
    end
    
    properties (Dependent = true)
        countertype_@char
        isbookcountercompatible_@logical
    end
    
    methods
        function obj = cOps(varargin)
            obj = init(obj,varargin{:});
        end
        
        function [] = registerbook(obj,bookin)
            if ~isa(bookin,'cBook')
                error('cOps:registerbook:invalid book input')
            end
            obj.book_ = bookin;
            if ~obj.isbookcountercompatible_
                obj.book_ = [];
                error('cOps:registerbook:incompatible book with counter registered!')
            end
        end
        %end of registerbook
        
        function [] = registermdefut(obj,mdefut)
            if ~isa(mdefut,'cMDEFut')
                error('cOps:registermdefut:invalid mdefut input')
            end
            obj.mdefut_ = mdefut;
        end
        %end of registermdefut
        
        function [] = registermdeopt(obj,mdeopt)
            if ~isa(mdeopt,'cMDEOpt')
                error('cOps:registermdeopt:invalid mdeopt input')
            end
            obj.mdeopt_ = mdeopt;
        end
        %end of registermdeopt
        
        function [] = registercounter(obj,counter)
            if isa(counter,'CounterCTP')
                obj.counterCTP_ = counter;
                if ~obj.isbookcountercompatible_
                    obj.counterCTP_ = [];
                    error('cOps:registercounter:incompatible counter with book registered!')
                end
            elseif isa(counter,'CounterHSO32')
                obj.counterHSO32_ = counter;
                if ~obj.isbookcountercompatible_
                    obj.counterHSO32_ = [];
                    error('cOps:registercounter:incompatible counter with book registered!')
                end
            elseif isa(counter,'cCounterRH')
                obj.counterRH_ = counter;
                if ~obj.isbookcountercompatible_
                    obj.counterRH_ = [];
                    error('cOps:registercounter:incompatible counter with book registered!')
                end
            else
                error('cOps:registercounter:invalid counter input')
            end
        end
        %end of registercounter
        
        function [] = registerpasttrades(obj,trades)
            if isa(trades,'cTradeOpenArray')
                %we only register trades that are not closed
                livetrades = trades.filterby('status','live');
                obj.trades_ = livetrades;
            else
                error('cOps:registerpasttrades:invalid trades input')
            end
        end
        %end of registerpasttrades
        
        function countertype = get.countertype_(obj)
            if isempty(obj.counterCTP_) && isempty(obj.counterHSO32_) && isempty(obj.counterRH_)
                countertype = 'unknown';
            elseif ~isempty(obj.counterCTP_) && isempty(obj.counterHSO32_) && isempty(obj.counterRH_)
                countertype = 'ctp';
            elseif isempty(obj.counterCTP_) && ~isempty(obj.counterHSO32_) && isempty(obj.counterRH_)
                countertype = 'o32';
            elseif isempty(obj.counterCTP_) && isempty(obj.counterHSO32_) && ~isempty(obj.counterRH_)
                countertype = 'rh';
            else
                error('cOps:countertype_:unique type required')
            end
        end
        
        function iscompatible = get.isbookcountercompatible_(obj)
            if strcmpi(obj.countertype_,'unknown')
                iscompatible = true;
            elseif strcmpi(obj.countertype_,'ctp')
                if isempty(obj.book_)
                    iscompatible = true;
                else
                    if isempty(obj.book_.countername_)
                        iscompatible = true;
                        obj.book_.setcountername(obj.counterCTP_.char);
                    else
                        if strcmpi(obj.book_.countername_,obj.counterCTP_.char)
                            iscompatible = true;
                        else
                            iscompatible = false;
                            fprintf('cOps:isbookcountercompatible_:book countername %s and countername %s are incompatible\n',...
                                obj.book_,countername_,obj.counterCTP_.char);
                        end
                    end
                end
            elseif strcmpi(obj.countertype_,'rh')
                if isempty(obj.book_)
                    iscompatible = true;
                else
                    if isempty(obj.book_.countername_)
                        iscompatible = true;
                        obj.book_.setcountername(obj.counterRH_.char);
                    else
                        if strcmpi(obj.book_.countername_,obj.counterRH_.char)
                            iscompatible = true;
                        else
                            iscompatible = false;
                            fprintf('cOps:isbookcountercompatible_:book countername %s and countername %s are incompatible\n',...
                                obj.book_,countername_,obj.counterCTP_.char);
                        end
                    end
                end
            elseif strcmpi(obj.countertype_,'o32')
                error('cOps:isbookcountercompatible_:not implemented for O32')
            else
                iscompatible = false;
            end
        end 
        %end of get.isbookcountercompatible_
        
        function [ret] = iseveningrequired(obj)
            try
                ret = obj.mdefut_.iseveningrequired_;
            catch
                ret = 0;
            end
        end
        
    end
    
    methods
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
        counter = getcounter(obj)
        %
        [n] = numberofentrusts(obj,varargin)
                
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