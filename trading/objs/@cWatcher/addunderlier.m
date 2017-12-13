%private function to add underlier for option single
function [] = addunderlier(watcher,underlierstr)
    if ~ischar(underlierstr)
        error('cWatcher:addunderlier:invalid underlier string input')
    end
    if ~watcher.hasunderlier(underlierstr)
        n = length(watcher.underliers);
        n = n + 1;
        u = cell(n,1);
        u_w = cell(n,1);
        u_b = cell(n,1);
        u_ctp = cell(n,1);
        u{n} = underlierstr;
        u_ctp{n} = str2ctp(underlierstr);
        u_w{n} = ctp2wind(u_ctp{n});
        u_b{n} = ctp2bbg(u_ctp{n});
        if n > 1
            for i = 1:n-1
                u{i} = watcher.underliers{i};
                u_ctp{i} = watcher.underliers_ctp{i};
                u_w{i} = watcher.underliers_w{i};
                u_b{i} = watcher.underliers_b{i};
            end
        end
        watcher.underliers = u;
        watcher.underliers_ctp = u_ctp;
        watcher.underliers_w = u_w;
        watcher.underliers_b = u_b;
    end
end