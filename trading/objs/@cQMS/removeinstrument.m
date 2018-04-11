function [] = removeinstrument(qms,instrument)

    if isempty(qms.instruments_)
        return
    end

    if isempty(qms.watcher_)
        return
    end

    qms.instruments_.removeinstrument(instrument);

    qms.watcher_.removesingle(instrument.code_ctp);

end
%end of removeinstrument