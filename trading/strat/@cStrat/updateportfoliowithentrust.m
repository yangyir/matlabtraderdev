function pnl = updateportfoliowithentrust(strategy,e)
    pnl = 0;
    if isempty(strategy.counter_), return; end
    if ~isa(e,'Entrust'), return; end

    f0 = strategy.counter_.queryEntrust(e);
    f1 = e.is_entrust_closed;
    f2 = e.dealVolume > 0;
    [f3,idx] = strategy.instruments_.hasinstrument(e.instrumentCode);
    if f0&&f1&&f2&&f3
        instrument = strategy.instruments_.getinstrument{idx};
        t = cTransaction;
        t.instrument_ = instrument;
        t.price_ = e.dealAmount./e.dealVolume;
        t.volume_ = e.dealVolume;
        t.direction_ = e.direction;
        t.offset_ = e.offsetFlag;
        t.datetime1_ = e.time;
        pnl = strategy.portfolio_.updateportfolio(t);
        strategy.pnl_close_(idx) = strategy.pnl_close_(idx) + pnl;
    end
    
    if f1
        n = strategy.entrustspending_.latest;
        for i = n:-1:1
            if strategy.entrustspending_.node(i).entrustNo == e.entrustNo
                rmidx = i;
                strategy.entrustspending_.removeByIndex(rmidx);
                break
            end
        end
        strategy.entrustsfinished_.push(e);
    end

end
%end of updateportfoliowithentrust