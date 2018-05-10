function [] = setmultidaymode(obj,fns)
    if ~iscell(fns)
        error('cReplayer:setmultidaymode:invalid file names input')
    end
    
    obj.mode_ = 'multiday';
    obj.multidayfiles_ = fns;
    obj.multidayidx_ = 1;
end