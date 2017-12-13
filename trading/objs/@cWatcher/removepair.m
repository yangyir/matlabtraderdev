function [] = removepair(watcher,pairstr,keepsingle)
    if nargin < 3
        keepsingle = false;
    end

    if ~ischar(pairstr)
        error('cWatcher:removepair:invalid pair string input')
    end
    [flag,idx] = watcher.haspair(pairstr);
    if flag
        %here we also remove the pair legs from the singles
        %container
        if ~keepsingle
            legs = regexp(pairstr,',','split');
            if watcher.hassingle(legs{1}), watcher.removesingle(legs{1});end
            if watcher.hassingle(legs{2}), watcher.removesingle(legs{2});end
        end
        n = length(watcher.pairs);
        if n == 1
            watcher.pairs = {};
            watcher.pairs_ctp = {};
            watcher.pairs_w = {};
            watcher.pairs_b = {};
        else
            p = cell(n-1,1);
            p_ctp = cell(n-1,1);
            p_w = cell(n-1,1);
            p_b = cell(n-1,1);
            count = 1;
            for i = 1:n
                if i == idx
                    continue;
                else
                    p{count} = watcher.pairs{i};
                    p_ctp{count,1} = watcher.pairs_ctp{i,1};
                    p_ctp{count,2} = watcher.pairs_ctp{i,2};
                    p_w{count,1} = watcher.pairs_w{i,1};
                    p_w{count,2} = watcher.pairs_w{i,2};
                    p_b{count,1} = watcher.pairs_b{i,1};
                    p_b{count,2} = watcher.pairs_b{i,2};
                    count = count + 1;
                end
            end
            watcher.pairs = p;
            watcher.pairs_ctp = p_ctp;
            watcher.pairs_w = p_w;
            watcher.pairs_b = p_b;
        end
    else
        warning(['cWatcher:removepair:pair ',pairstr,' not found']);
    end
end
%end of removepair