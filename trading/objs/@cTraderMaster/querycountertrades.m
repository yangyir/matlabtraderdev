function ret = querycountertrades(obj,querystr)
    if nargin < 2, querystr = '111';end
    isfut = strcmpi(querystr(1),'1');
    isopt1 = strcmpi(querystr(2),'1');
    isopt2 = strcmpi(querystr(3),'1');
    if isfut
        obj.querytrades('fut');
    end
    if isopt1
        obj.querytrades('opt1')
    end
    if isopt2
        obj.querytrades('opt2')
    end
    ret = 1;
end