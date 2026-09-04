classdef cInstrumentArray < handle
    properties (Access = private)
       list_ = {}
    end
    
    methods
        [] = delete(obj)
        [bool,idx] = hasinstrument(obj,instrument)
        n = count(obj)
        [] = addinstrument(obj,instrument)
        [] = removeinstrument(obj,instrument)
        [] = clear(obj)
        list = getinstrument(obj,codestr)
        
    end
        
end