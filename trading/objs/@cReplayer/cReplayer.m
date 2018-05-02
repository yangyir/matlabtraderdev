classdef cReplayer < handle
    properties
        instruments_@cInstrumentArray
        tickdata_@cell
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        [] = removeinstrument(obj,instrument)
        [] = inittickdata(obj,varargin)
        [] = loadtickdata(obj,varargin)
    end
    
    methods (Static = true)
        [] = demo(~)
    end
end