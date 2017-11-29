function pnl = updateportfoliowithentrust(strategy,e)
    pnl = 0;
    if isempty(strategy.counter_), return; end
    if ~isa(e,'Entrust'), return; end

    ret = strategy.counter_.queryEntrust(e);
    if ret
        f1 = e.is_entrust_closed;
        if f1
            %insert into entrustsfinished in case the entrust is closed
            strategy.entrustsfinished_.push(e);
        end
        f2 = e.dealVolume > 0;
        [f3,idx] = strategy.instruments_.hasinstrument(e.instrumentCode);
        if f1&&f2&&f3
            instrument = strategy.instruments_.getinstrument{idx};
            t = cTransaction;
            t.instrument_ = instrument;
            t.price_ = e.dealAmount./e.dealVolume;
            t.volume_ = e.dealVolume;
            t.direction_ = e.direction;
            t.offset_ = e.offsetFlag;
            t.datetime1_ = e.time;
            pnl = strategy.portfolio_.updateportfolio(t);
        end
    end
end
%end of updateportfoliowithentrust