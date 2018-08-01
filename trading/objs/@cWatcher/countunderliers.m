%private function to count underliers
function n = countunderliers(watcher)
    if isempty(watcher), n = 0; return
    n = length(watcher.underliers);
end