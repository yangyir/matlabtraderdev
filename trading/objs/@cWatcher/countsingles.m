function n = countsingles(watcher)
    if isempty(watcher), 
        n = 0;
    else
        n = length(watcher.singles);
    end
end
%end of countsingles