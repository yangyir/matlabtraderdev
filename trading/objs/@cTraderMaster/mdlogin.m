function ret = mdlogin(obj)
    if ~obj.qms_.isconnect, obj.qms_.qms.watcher_.ds.login;end
    ret = 1;
end