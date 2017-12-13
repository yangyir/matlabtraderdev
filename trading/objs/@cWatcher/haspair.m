function [flag,idx] = haspair(watcher,pairstr)
    if ~ischar(pairstr)
        error('cWatcher:haspair:invalid pair string input')
    end
    for i = 1:length(watcher.pairs)
        if strcmpi(pairstr,watcher.pairs{i})
            flag = true;
            idx = i;
            return
        end
    end
    flag = false;
    idx = 0;
end
%end of haspairs