function [] = close(obj)
%cTHS function
    if isempty(obj.ds_)
        return
    else
        THS_iFinDLogout;
    end
end