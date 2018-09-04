function [ret] = ctplogoff(obj,varargin)
%cQMS
    if ~strcmpi(obj.watcher_.conn,'ctp')
        ret = 0;
        return
    end
    
    try
        obj.watcher_.ds.logoff;
        ret = 1;
    catch
        ret = 0;
    end
    
    if ret == 1
        fprintf('CTP counter "%s" successfully logoff!!!\n',obj.watcher_.ds.char);
    end

end