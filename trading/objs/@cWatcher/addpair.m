function [] = addpair(watcher,pairstr)
    if ~ischar(pairstr)
        error('cWatcher:addpairs:invalid pair string input')
    end
    if ~watcher.haspair(pairstr)
        legs = regexp(pairstr,',','split');
        if length(legs) ~= 2
            error('cWatcher:addpair:invalid pairstr input')
        end

        %we add the legs to singles container
        watcher.addsingle(legs{1});
        watcher.addsingle(legs{2});

        n = length(watcher.pairs);
        n = n + 1;
        p = cell(n,1);
        p_ctp = cell(n,2);
        p_w = cell(n,2);
        p_b = cell(n,2);
        p{n} = pairstr;

        p_ctp{n,1} = str2ctp(legs{1});
        p_ctp{n,2} = str2ctp(legs{2});
        p_w{n,1} = ctp2wind(p_ctp{n,1});
        p_w{n,2} = ctp2wind(p_ctp{n,2});
        p_b{n,1} = ctp2bbg(p_ctp{n,1});
        p_b{n,2} = ctp2bbg(p_ctp{n,2});

        if n > 1
            for i = 1:n-1
                p{i} = watcher.pairs{i};
                p_ctp{i,1} = watcher.pairs_ctp{i,1};
                p_ctp{i,2} = watcher.pairs_ctp{i,2};
                p_w{i,1} = watcher.pairs_w{i,1};
                p_w{i,2} = watcher.pairs_w{i,2};
                p_b{i,1} = watcher.pairs_b{i,1};
                p_b{i,2} = watcher.pairs_b{i,2};
            end
        end
        watcher.pairs = p;
        watcher.pairs_ctp = p_ctp;
        watcher.pairs_w = p_w;
        watcher.pairs_b = p_b;
    end
end
%end of addpairs