classdef cMDEOpt < cMyTimerObj
    %Note: the class of Market Data Engine for listed options
    properties
        options_@cInstrumentArray
        underliers_@cInstrumentArray
        qms_@cQMS    
        display_@double = 1

    end
    
    properties (Access = private)
        quotes_@cell
        pivottable_@cell
    end
    
    methods
        [] = loadoptions(obj,code_ctp_underlier,numstrikes)
        [] = registerinstrument(obj,instrument)
        [] = refresh(obj)
        tbl = voltable(obj)
    end
    
    methods (Access = private)
        [] = savequotes2mem(obj) 
        tbl = genpivottable(obj)
        tbl = displaypivottable(obj)
    end
    
    
    
end