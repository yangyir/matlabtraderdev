function [ret] = logoff(obj)
%cMDEFut
    if strcmpi(obj.mode_,'replay'), return; end
    try
        connstr = obj.qms_.watcher_.conn;
    catch
        connstr = '';
    end
    
    ret = 0;
    
    if strcmpi(connstr,'ctp')
        ret = obj.qms_.ctplogoff;
    else
        error('cMDEFut:logoff:%s connection not implemented',connstr)
    end
    
end