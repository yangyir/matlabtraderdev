function [] = removepairs(watcher,pairarray)
    if nargin == 1
        watcher.pairs = {};
        watcher.pairs_ctp = {};
        watcher.pairs_w = {};
        watcher.pairs_b = {};
    else
        if ischar(pairarray)
            pairarray = regexp(pairarray,';','split');
        end
        for i = 1:length(pairarray)
            watcher = watcher.removepair(pairarray{i});
        end
    end
end
%end of removepairs