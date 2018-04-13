classdef cTrader < handle
    % trader object
    % rule1: a named trader can have more than one book
    % rule2: a named trader can run more than one strategy
    properties
        name_@char
        books_@cell
        strats_@cell
    end
    
    methods
        [] = init(obj,name)
        [] = addbook(obj,book)
        [] = addstrat(obj,strat)
        
    end
    
    methods
        % note: think about what a trader can do and should do 
        % 1. a trader can execute trades manually
        [ret,entrust] = placeorder(obj,codestr,bsflag,ocflag,px,lots,book)
        [ret,entrusts] = cancelorders(obj,codestr,book)
        % 2. a trader can run automated strategies
        [] = runstrategy(obj,stratname)
    end
    
    methods
        [bool,idx] = hasbook(obj,book)
    end
end