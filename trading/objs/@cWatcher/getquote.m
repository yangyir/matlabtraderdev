function quote = getquote(watcher,codestr)
    n = size(watcher.qs,1);
    for i = 1:n
        if strcmpi(codestr,watcher.qs{i}.code_ctp)
            quote = watcher.qs{i};
            return
        end
    end
    quote = {};
end
%end of getquote