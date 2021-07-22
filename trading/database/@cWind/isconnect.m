function flag = isconnect(obj)
    if isempty(obj)
        flag = false;
    else
        if isempty(obj.ds_)
            flag = false;
        else
            flag = obj.ds_.isconnected;
        end
    end
end