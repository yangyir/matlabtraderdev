function flag = isconnect(qms)
    if isempty(qms.watcher_)
        flag = false;
    else
        flag = qms.watcher_.isconnect;
    end
end
%end of isconnect