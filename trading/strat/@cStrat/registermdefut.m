function [] = registermdefut(obj,mdefut)
%cStrat
    if ~isa(mdefut,'cMDEFut')
        error('cStrat:registermdefut:invalid mdefut input')
    end
    
    obj.mde_fut_ = mdefut;
    
end