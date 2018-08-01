function quote = getquote(qms,instrument)
    if nargin < 2
        if isempty(qms.watcher_)
            quote = {};
            return
        end
        quote = qms.watcher_.qs;
        return
    end

    idx = 0;
    for i = 1:size(qms.watcher_.qs,1)
        if ischar(instrument)
            if strcmpi(instrument,qms.watcher_.qs{i}.code_ctp)
                idx = i;
                break
            end
        else
            if strcmpi(instrument.code_ctp,qms.watcher_.qs{i}.code_ctp)
                idx = i;
                break
            end
        end
    end

%             [flag, idx] = self.watcher_.hassingle(instrument.code_ctp);
    if idx == 0
        quote = {};
    else
        quote = qms.watcher_.qs{idx};
    end
end
%end of getquote