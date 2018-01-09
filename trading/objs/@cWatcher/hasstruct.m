function [flag,idx] = hasstruct(watcher,structstr)
    if ~ischar(structstr)
        error('cWatcher:hasstruct:invalid struct string input')
    end
    for i = 1:length(watcher.structs)
        if strcmpi(structstr,watcher.structs{i})
            flag = true;
            idx = i;
            return
        end
    end
    flag = false;
    idx = 0;
end
%end of hasstruct