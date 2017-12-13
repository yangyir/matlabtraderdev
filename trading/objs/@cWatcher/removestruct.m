function [] = removestruct(watcher,structstr,keepsingle)
    if nargin < 3
        keepsingle = false;
    end

    if ~ischar(structstr)
        error('cWatcherFut:removestruct:invalid pair string input')
    end
    [flag,idx] = watcher.hasstruct(structstr);
    if flag
        %here we also remove the pair legs from the singles
        %container
        if ~keepsingle
            legs = regexp(structstr,',','split');
            for i = 1:length(legs)
                if watcher.hassingle(legs{i}), watcher.removesingle(legs{i});end
            end
        end
        n = length(watcher.structs);
        if n == 1
            watcher.structs = {};
            watcher.structs_ctp = {};
            watcher.structs_w = {};
            watcher.structs_b = {};
        else
            ss = cell(n-1,1);
            ss_ctp = cell(n-1,1);
            ss_w = cell(n-1,1);
            ss_b = cell(n-1,1);
            ws_ = cell(n-1,1);
            count = 1;
            for i = 1:n
                if i == idx
                    continue;
                else
                    ss{count} = watcher.structs{i};
                    ss_ctp{count} = watcher.structs_ctp{i};
                    ss_w{count} = watcher.structs_w{i};
                    ss_b{count} = watcher.structs_b{i};
                    ws_{count} = watcher.ws{i};
                    count = count + 1;
                end
            end
            watcher.structs = ss;
            watcher.structs_ctp = ss_ctp;
            watcher.structs_w = ss_w;
            watcher.structs_b = ss_b;
            watcher.ws = ws_;
        end
    else
        warning(['cWatcherFut:removestruct:struct ',structstr,' not found']);
    end
end
%end of removstruct