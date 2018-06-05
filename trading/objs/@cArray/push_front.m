function [obj] = push_front(obj, node_s)
    L = length(node_s);
    lat = obj.latest_;
    try
        if lat == 0
            obj.node_ = node_s;
        else
            obj.node_ = [node_s, obj.node_];
        end
        obj.latest_ = lat + L;
    catch e
        fprintf('cArray:push_front:%s\n', e.message);
    end
end