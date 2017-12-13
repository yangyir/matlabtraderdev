function [] = removesingles(watcher,singlearray)
    if nargin == 1
        watcher.singles = {};
        watcher.singles_ctp = {};
        watcher.singles_w = {};
        watcher.singles_b = {};
    else
        if ischar(singlearray)
            singlearray = regexp(singlearray,',','split');
        end
        for i = 1:length(singlearray)
            watcher.removesingle(singlearray{i});
        end
    end

end
%end of removesingles