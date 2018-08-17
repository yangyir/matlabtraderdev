function [] = close(obj)
    if obj.isconnected_
        mdlogout;
    end
end