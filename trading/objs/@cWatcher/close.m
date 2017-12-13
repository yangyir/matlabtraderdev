function [] = close(watcher)
    try
        watcher.ds.close;
    catch
    end
    watcher.conn = '';
    watcher.removeall;
    watcher.qs = {};
    watcher.qp = {};
    watcher.qt = {};
    watcher.ws = {};
end
%end of close