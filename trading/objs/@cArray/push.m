function [obj] = push(obj, node_)
    lat = obj.latest_;
    lat = lat + 1;
    try
        if lat == 1 % obj was empty and to push the first element
            obj.node_ = node_;
        else
            obj.node_(lat) = node_;
        end
        obj.latest_ = lat;
    catch e
        fprintf('cArray:push:%s\n', e.message);
    end

end