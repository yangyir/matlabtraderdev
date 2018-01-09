function [] = removestructs(watcher,structarray)
    if nargin == 1
        watcher.structs = {};
        watcher.structs_ctp = {};
        watcher.structs_w = {};
        watcher.structs_b = {};
    else
        if ischar(structarray)
            structarray = regexp(structarray,';','split');
        end
        for i = 1:length(structarray)
            watcher = watcher.removestruct(structarray{i});
        end
    end
end
%end of removestructs