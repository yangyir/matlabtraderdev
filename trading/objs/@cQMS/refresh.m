function [] = refresh(qms,timestr)
    try
        if nargin <= 1
            qms.watcher_.refresh;
        else
            qms.watcher_.refresh(timestr);
        end
    catch e
        error('cQMS:refresh:error in cWatcher:refresh:%s',e.message);
    end
        
end
%end of refresh