function [] = clear(obj)
    if ~obj.isvalid, return; end
    obj.list_ = {};
end
%end of clear