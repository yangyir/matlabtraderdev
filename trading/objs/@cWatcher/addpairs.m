function [] = addpairs(watcher,pairarray)
    if ischar(pairarray)
        pairarray = regexp(pairarray,';','split');
    end
    for i = 1:length(pairarray)
        addpair(watcher,pairarray{i});
    end
end
%end of addpairs