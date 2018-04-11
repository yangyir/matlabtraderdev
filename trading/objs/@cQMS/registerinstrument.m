function [] = registerinstrument(qms,instrument)

    if isempty(qms.instruments_)
        qms.instruments_ = cInstrumentArray;
    end

    if isempty(qms.watcher_)
        qms.watcher_ = cWatcher;
    end

    qms.instruments_.addinstrument(instrument);

    qms.watcher_.addsingle(instrument.code_ctp);

end
%end of registerinstrument