function ret = counterlogin(obj,loginstr)
    if nargin < 2, loginstr = '111'; end
    f1 = strcmpi(loginstr(1),'1');
    f2 = strcmpi(loginstr(2),'1');
    f3 = strcmpi(loginstr(3),'1');
    if f1 && ~obj.counterfut_.is_Counter_Login
        obj.counterfut_.login;
    end
    if f2 && ~obj.counteropt1_.is_Counter_Login
        obj.counteropt1_.login;
    end
    if f3 && ~obj.counteropt2_.is_Counter_Login
        obj.counteropt2_.login;
    end
    ret = 1;
end

