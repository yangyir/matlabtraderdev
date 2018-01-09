function [flag,idx] = hassingle(watcher,singlestr)
    if ~ischar(singlestr)
        error('cWatcher:hassingle:invalid single string input')
    end
    for i = 1:length(watcher.singles)
        if strcmpi(singlestr,watcher.singles{i})
            flag = true;
            idx = i;
            return
        end
    end
    flag = false;
    idx = 0;
end
%end of hassingle