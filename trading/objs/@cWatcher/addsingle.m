function [] = addsingle(watcher,singlestr)
    if ~ischar(singlestr)
        error('cWatcher:addsingle:invalid single string input')
    end

    [flag,~,~,underlierstr] = isoptchar(singlestr);

    if ~watcher.hassingle(singlestr)
        n = length(watcher.singles);
        n = n + 1;
        s = cell(n,1);
        s_w = cell(n,1);
        s_b = cell(n,1);
        s_ctp = cell(n,1);
        s{n} = singlestr;
        isstock = false;
        try
            s_ctp{n} = str2ctp(singlestr);
            s_w{n} = ctp2wind(s_ctp{n});
            s_b{n} = ctp2bbg(s_ctp{n});
        catch
            s_ctp{n} = singlestr;
            if ~isempty(strfind(singlestr,'.SH')) || ...
                    ~isempty(strfind(singlestr,'.SZ')) || ...
                    ~isempty(strfind(singlestr,'.HK')) 
                s_w{n} = singlestr;
            else
                if length(singlestr) == 6
                    if strcmpi(singlestr(1),'5') || strcmpi(singlestr(1),'6')
                        s_w{n} = [singlestr,'.SH'];
                    elseif strcmpi(singlestr(1),'0') || strcmpi(singlestr(1),'3')
                        s_w{n} = [singlestr,'.SZ'];
                    end
                elseif length(singlestr) == 4
                    s_w{n} = [singlestr,'.HK'];
                end
                s_b{n} = singlestr;
                isstock = true;
            end
        end
        if n > 1
            for i = 1:n-1
                s{i} = watcher.singles{i};
                s_ctp{i} = watcher.singles_ctp{i};
                s_w{i} = watcher.singles_w{i};
                s_b{i} = watcher.singles_b{i};
            end
        end
        watcher.singles = s;
        watcher.singles_ctp = s_ctp;
        watcher.singles_w = s_w;
        watcher.singles_b = s_b;

        types_ = cell(n,1);
        if flag
            types_{n} = 'option';
        else
            if ~isstock
                types_{n} = 'futures';
            else
                types_{n} = 'stock';
            end
        end
        if n > 1
            for i = 1:n-1
                types_{i} = watcher.types{i};
            end
        end
        watcher.types = types_;

        if flag
            watcher.addunderlier(underlierstr);
        end

    end
end
%end of addsingle