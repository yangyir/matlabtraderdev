function [ret] = logoff(obj)
%cGUIFut
    try
        ret = obj.mdefut_.logoff;
    catch
        ret = 0;
        fprintf('embedded mdefut failed to login');
    end
end