function [] = delete(obj)
    n = obj.count;
    for i = 1:n
        obj.list_{i}.delete;
    end
    obj.list_ = {};
end