function [] = addsingles(watcher,singlearray)
    if iscell(singlearray)
        for i = 1:length(singlearray)
            addsingle(watcher,singlearray{i});
        end
    elseif ischar(singlearray)
        singlearray = regexp(singlearray,',','split');
        for i = 1:length(singlearray)
            addsingle(watcher,singlearray{i});
        end
    end
end
%end of addsingles