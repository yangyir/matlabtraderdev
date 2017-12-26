%private function to check whether underlier exist
function [flag,idx] = hasunderlier(watcher, underlierstr)
    if ~ischar(underlierstr)
        error('cWatcherOpt:hasunderlier:invalid underlier string input')
    end
    for i = 1:length(watcher.underliers)
        if strcmpi(underlierstr,watcher.underliers{i})
            flag = true;
            idx = i;
            return
        end 
    end
    flag = false;
    idx = 0; 
end