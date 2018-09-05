function [] = clear(obj)
%cStrat
    if ~isempty(obj.instruments_)    
        obj.instruments_.clear;
    end
    
    if ~isempty(obj.underliers_)
        obj.underliers_.clear;
    end
    
    obj.mde_fut_ = [];
    obj.mde_opt_ = [];
    
end