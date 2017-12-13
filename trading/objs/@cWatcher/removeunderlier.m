%private function to remove underliers
function [] = removeunderlier(watcher,underlierstr)
    if ~ischar(underlierstr)
        error('cWatcherOpt:removeunderlier:invalid underlier string input')
    end
    [flag,idx] = watcher.hasunderlier(underlierstr);
    if flag
        n = watcher.countunderliers;
        if n == 1
            watcher.underliers = {};
            watcher.underliers_ctp = {};
            watcher.underliers_w = {};
            watcher.underliers_b = {};
        else
            u = cell(n-1,1);
            u_ctp = cell(n-1,1);
            u_w = cell(n-1,1);
            u_b = cell(n-1,1);
            count = 1;
            for i = 1:n
                if i == idx
                    continue;
                else
                    u{count} = watcher.underliers{i};
                    u_ctp{count} = watcher.underliers_ctp{i};
                    u_w{count} = watcher.underliers_w{i};
                    u_b{count} = watcher.underliers_b{i};
                    count = count + 1;
                end
            end
            watcher.underliers = u;
            watcher.underliers_ctp = u_ctp;
            watcher.underliers_w = u_w;
            watcher.underliers_b = u_b;
        end
    else
        warning(['cWatcher:removeunderlier:underlier ',underlierstr,' not found']);
    end
end