function [] = printquotes(watcher)
    watcher.refresh;
    fprintf('\n')
    for i = 1:size(watcher.qs,1), watcher.qs{i}.print; end
end
%end of printquotes