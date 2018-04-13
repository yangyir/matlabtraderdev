classdef cBook < handle
    % cBook class defines a trading book and it shall include the following
    % properties: trader, counter, positions
    
    properties
        bookname_@char
        trader_@char
        counter_@CounterCTP
        positions_@cell
    end
    
    methods
        % rule1: one book can only be associated with one trader and one
        % counter. However, a trader can own more than one books
        [] = init(obj,bookname,trader,counter)
        
        % rule2:a counter can hold positions across different books
        % rule3:local .txt file record positions for only one book and
        % positions across books are STRICKLY FORBIDDEN to be stored in one file 
        % I/O
        [] = loadpositionsfromcounter(obj,varargin)
        [] = loadpositionsfromfile(obj,fn,datein)
        [] = savepositionstofile(obj,fn);
        
        % position
        [bool,idx] = hasposition(obj,argin)
        [] = addpositions(obj,varargin)
        [] = removepositions(obj,varargin)
        [] = printpositions(obj)
        [ret] = isemptybook(obj)
    end
    
end

