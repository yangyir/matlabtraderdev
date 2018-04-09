function flag = isconnect(obj)
    if isempty(obj.ds_)
        flag = false;
    else
        flag = true;
    end
end
%end of isconnect

