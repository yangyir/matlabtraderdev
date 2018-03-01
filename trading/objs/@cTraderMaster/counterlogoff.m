function ret = counterlogoff(obj,logoffstr)
    if nargin < 2, logoffstr = '111'; end
    f1 = strcmpi(logoffstr(1),'1');
    f2 = strcmpi(logoffstr(2),'1');
    f3 = strcmpi(logoffstr(3),'1');
    if f1 && obj.counterfut_.is_Counter_Login
        obj.counterfut_.logout;
    end
    if f2 && obj.counteropt1_.is_Counter_Login
        obj.counteropt1_.logout;
    end
    if f3 && obj.counteropt2_.is_Counter_Login
        obj.counteropt2_.logout;
    end
    ret = 1;

end