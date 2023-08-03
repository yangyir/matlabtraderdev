function flag = isconnect(obj)
%cTHS function
    if isempty(obj)
        flag = false;
    else
        if isempty(obj.ds_)
            flag = false;
        else
            flag = obj.ds_ == 0 || obj.ds_ == -201;
        end
    end
end