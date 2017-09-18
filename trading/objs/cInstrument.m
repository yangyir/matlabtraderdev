classdef (Abstract) cInstrument < handle
    properties (Abstract)
        code_ctp@char
        code_wind@char
        code_bbg@char
    end
    
    methods (Abstract)
        init(obj,ds_)
        saveinfo(obj,fn_)
        obj = loadinfo(obj,fn_)
        dispinfo(obj)
    end
end