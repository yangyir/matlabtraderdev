function n = countsingles(watcher)
    if isempty(watcher), n = 0; return
    n = length(watcher.singles);
end
%end of countsingles