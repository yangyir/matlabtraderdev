function [] = init(obj,ds_)
    if isa(ds_,'cBloomberg')
        obj.init_bbg(ds_.ds_);
    else
        info = class(ds_);
        error(['cOption:init:not implemented for class ',info])
    end          
end
%end of init

