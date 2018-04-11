function [] = refresh(qms,timestr)
    if nargin <= 1
        qms.watcher_.refresh;
    else
        qms.watcher_.refresh(timestr);
    end
end
%end of refresh