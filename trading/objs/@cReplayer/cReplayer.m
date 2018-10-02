classdef cReplayer < handle
    properties
        instruments_@cInstrumentArray
        tickdata_@cell
        ticktimevec_@cell
        %note:normally we have a cReplayer only records tick data for a
        %sinlge trading date. However, we can still record tick data for
        %several trading dates
        mode_@char = 'singleday'
        multidayfiles_@cell
    end
    
    properties (Hidden = true)
        multidayidx_@double = 0
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        [] = removeinstrument(obj,instrument)
        [] = inittickdata(obj,varargin)
        [] = loadtickdata(obj,varargin)
        %
        tick = gettickdata(obj,varargin)
        %
        [] = setmultidaymode(obj,fns)
        
    end
    
    methods (Static = true)
        [] = demo(~)
    end
end