function [] = removesingle(watcher,singlestr)
    if ~ischar(singlestr)
        error('cWatcher:removesingle:invalid single string input')
    end

    [optflag,~,~,underlierstr] = isoptchar(singlestr);
    [flag,idx] = watcher.hassingle(singlestr);

    if optflag
        flag_removeunderlier = true;
        ns = watcher.countsingles;
        for i = 1:ns
            if i ~= idx
                [~,~,~,underlierstr_i] = isoptchar(watcher.singles{i});
                if strcmpi(underlierstr,underlierstr_i)
                    %the underlier is shared by other legs
                    flag_removeunderlier = false;
                    break
                end
            end
        end
    else
        flag_removeunderlier = false;
    end

    if flag_removeunderlier
        watcher.removeunderlier(underlierstr);
    end

    if flag
        n = length(watcher.singles);
        if n == 1
            watcher.singles = {};
            watcher.singles_ctp = {};
            watcher.singles_w = {};
            watcher.singles_b = {};
            watcher.types = {};
        else
            s = cell(n-1,1);
            s_ctp = cell(n-1,1);
            s_w = cell(n-1,1);
            s_b = cell(n-1,1);
            types_ = cell(n-1,1);
            count = 1;
            for i = 1:n
                if i == idx
                    continue;
                else
                    s{count} = watcher.singles{i};
                    s_ctp{count} = watcher.singles_ctp{i};
                    s_w{count} = watcher.singles_w{i};
                    s_b{count} = watcher.singles_b{i};
                    types_{count} = watcher.types{i};
                    count = count + 1;
                end
            end
            watcher.singles = s;
            watcher.singles_ctp = s_ctp;
            watcher.singles_w = s_w;
            watcher.singles_b = s_b;
            watcher.types = types_;
        end
    else
        warning(['cWatcher:removesingle:single ',singlestr,' not found']);
    end
end
%end of removesingle