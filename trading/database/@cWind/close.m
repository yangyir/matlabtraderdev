function [] = close(obj)
    if isempty(obj.ds_)
        return
    else
        obj.ds_.close;
    end
end