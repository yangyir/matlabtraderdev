function flag = isconnect(watcher)
    if isempty(watcher.ds)
        flag = false;
    else
        flag = watcher.ds.isconnect;
    end
end
%end of isconnect