function [] = addstructs(watcher,structarray)
    if ischar(structarray)
        structarray = regexp(structarray,';','split');
    end
    for i = 1:length(structarray)
        addstruct(watcher,structarray{i});
    end
end
%end of addstructs