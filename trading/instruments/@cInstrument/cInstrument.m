classdef (Abstract) cInstrument < handle
    properties (Abstract)
        code_ctp
        code_wind
        code_bbg
        code_H5
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