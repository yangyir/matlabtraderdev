function [] = setdatasource(qms,connstr)
    if ~(strcmpi(connstr,'bloomberg') || ...
            strcmpi(connstr,'wind') || ...
            strcmpi(connstr,'ctp') || ...
            strcmpi(connstr,'local')) 
        error('cQMS:setdatasource:invalid datasource string')
    end

    if isempty(qms.watcher_)
        qms.watcher_ = cWatcher;
    end
    qms.watcher_.conn = connstr;

end
%end of setdatasource