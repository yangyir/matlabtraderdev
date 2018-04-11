classdef cBook < handle
    % cBook class defines a trading book and it shall include the following
    % properties: trader, counter, positions
    
    properties
        trader_@char
        counter_@CounterCTP
        positions_@cell
    end
    
    methods
        % rule: one book can only be associated with one trader and one
        % counter. However, a trader can own more than one books
        [] = init(obj,trader,counter)
        %position related
        [bool,idx] = hasposition(obj,argin)
        [] = loadpositionsfromcounter(obj,varargin)
        [] = addpositions(obj,varargin)
        [] = removepositions(obj,varargin)
        [] = printpositions(obj)
        [ret] = calcpositions(obj)
    end
    
end

