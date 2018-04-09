function flag = isconnect(obj)
    if isempty(obj.ds_)
        flag = false;
    else
        flag = obj.ds_.isconnection;
    end
end
%end of isconnect

