%private function to count underliers
function n = countunderliers(watcher)
    if isempty(watcher)
        n = 0; 
    else
        n = length(watcher.underliers);
    end
end