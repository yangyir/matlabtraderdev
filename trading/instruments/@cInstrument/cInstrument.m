classdef (Abstract) cInstrument < handle
    properties (Abstract)
        code_ctp@char
        code_wind@char
        code_bbg@char
        code_H5@char
    end
    
    
    methods
        function delete(obj)
            variablenotused(obj);
            clear obj;
        end
        
        [] = saveinfo(obj,fn_)
        [] = loadinfo(obj,fn_)
        [] = dispinfo(obj)
        [] = init(obj,ds_)
        
    end
    
    methods (Abstract)
        [] = init_bbg(obj,ds_)
        [] = init_wind(obj,ds_)
        [assetname,exch] = getexchangestr(obj)
    end
end