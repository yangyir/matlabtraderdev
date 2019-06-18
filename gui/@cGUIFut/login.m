function [ret] = login(obj,varargin)
%cGUIFut
    try
        ret = obj.mdefut_.login('connection','ctp','countername',obj.countername_);
    catch
        fprintf('embedded mdefut failed to login');
        ret = 0;
    end
end