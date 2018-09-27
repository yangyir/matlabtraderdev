classdef cBook < handle
    % cBook class defines a trading book and it shall include the following
    % properties: trader, counter, positions
    
    properties (GetAccess = public, SetAccess = private)
        bookname_@char
        tradername_@char
        countername_@char
        positions_@cell
    end
    
    methods
        function obj = cBook(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    %set methods
    methods
        function [] = setbookname(obj,bookname)
            obj.bookname_ = bookname;
        end
        
        function [] = settradername(obj,tradername)
            obj.tradername_ = tradername;
        end
        
        function [] = setcountername(obj,countername)
            obj.countername_ = countername;
        end
        
        function [] = setpositions(obj,positions)
            obj.positions_ = positions;
        end
        
        function [] = emptybook(obj)
            obj.positions_ = {};
        end
    end
    
    methods
        % rule1: one book can only be associated with one trader and one
        % counter. However, a trader can own more than one books
        
        % rule2:a counter can hold positions across different books
        
        % rule3:local .txt file record positions for only one book and
        % positions across books are STRICKLY FORBIDDEN to be stored in one file 
        % I/O
        [] = loadpositionsfromcounter(obj,varargin)
        [] = loadpositionsfromfile(obj,fn)
        %
        [] = savepositionstofile(obj,fn,varargin);
        
        % note:loadpositionsfromtxt and loadpositionsfromexcel are
        % functions to load inputs of inidividual trades table
        [] = loadtradesfromtxt(obj,fn)
        [] = loadtradesfromexcel(obj,fn,sheetn)
                
        % position
        [bool,idx] = hasposition(obj,argin)
        [bool,idx] = haslongposition(obj,argin)
        [bool,idx] = hasshortposition(obj,argin)
        [] = addpositions(obj,varargin)
        [] = removepositions(obj,varargin)
        [vtotal,vtoday] = getpositions(obj,varargin)
        [] = printpositions(obj)
        [ret] = isemptybook(obj)
    end
    
    methods (Access = private)
        [obj] = init(obj,varargin)
        [ret] = checkpositionfile(obj,fn)
        [ret] = checktradesfile(obj,fn)
        
    end
    
end

