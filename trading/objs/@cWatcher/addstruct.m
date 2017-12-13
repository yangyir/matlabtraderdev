function [] = addstruct(watcher,structstr,weights)
    if ~ischar(structstr)
        error('cWatcher:addstruct:invalid strcut string input')
    end
    if ~watcher.hasstruct(structstr)
        legs = regexp(structstr,',','split');

        %we add the legs to singles container
        for i = 1:length(legs), watcher.addsingle(legs{i}); end

        n = length(watcher.structs);
        n = n + 1;
        ss = cell(n,1);
        ss_ctp = cell(n,1);
        ss_w = cell(n,1);
        ss_b = cell(n,1);
        ss{n} = structstr;
        %weights
        ws_ = cell(n,1);

        ss_ctp_new = cell(1,length(legs));
        ss_w_new = ss_ctp_new;
        ss_b_new = ss_ctp_new;

        for i = 1:length(legs)
            ss_ctp_new{i} = str2ctp(legs{i});
            ss_w_new{i} = ctp2wind(ss_ctp_new{i});
            ss_b_new{i} = ctp2bbg(ss_ctp_new{i});
        end

        ss_ctp{n,1} = ss_ctp_new;
        ss_w{n,1} = ss_w_new;
        ss_b{n,1} = ss_b_new;
        ws_{n} = weights;

        if n > 1
            for i = 1:n-1
                ss{i} = watcher.structs{i};
                ss_ctp{i} = watcher.structs_ctp{i};
                ss_w{i,1} = watcher.structs_w{i};
                ss_b{i} = watcher.structs_b{i};
                ws_{i} = watcher.ws{i};
            end
        end
        watcher.structs = ss;
        watcher.structs_ctp = ss_ctp;
        watcher.structs_w = ss_w;
        watcher.structs_b = ss_b;
        watcher.ws = ws_;
    end
end
%end of addstruct