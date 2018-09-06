function [] = registermdeopt(obj,mdeopt)
%cStrat
    if ~isa(mdeopt,'cMDEOpt')
        error('cStrat:registermdefut:invalid mdeopt input')
    end
    
    obj.mde_opt_ = mdeopt;
    
end