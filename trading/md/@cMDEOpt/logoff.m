function [ret] = logoff(obj)
%cMDEOpt
    ret = 0;
    if strcmpi(obj.mode_,'replay'), return; end
    if strcmpi(obj.mode_,'demo'), return;end
    try
        connstr = obj.qms_.watcher_.conn;
    catch
        connstr = '';
    end
    
    
    
    if strcmpi(connstr,'ctp')
        ret = obj.qms_.ctplogoff;
    else
        error('cMDEOpt:logoff:%s connection not implemented',connstr)
    end
    
end