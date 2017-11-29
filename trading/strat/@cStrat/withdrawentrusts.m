function [] = withdrawentrusts(strategy,instrument)
    if ischar(instrument)
        code_ctp = instrument;
    elseif isa(instrument,'cInstrument')
        code_ctp = instrument.code_ctp;
    else
        error('cStrat:withdrawentrusts:invalid instrument input')
    end

    for i = 1:strategy.entrusts_.count
        e = strategy.entrusts_.node(i);
        if strcmpi(e.instrumentCode,code_ctp)
            if ~e.is_entrust_filled || ~e.is_entrust_closed
                ret = withdrawentrust(strategy.counter_,e);
                if ret
                    %the code will execute once the entrust is
                    %successfully withdrawn
                    if e.dealVolume > 0
                        %we need to update the portfolio in case
                        %the entrust is partially filled
                        [~,idx] = strategy.instruments_.hasinstrument(e.instrumentCode);
                        instrument = strategy.instruments_.getinstrument{idx};
                        t = cTransaction;
                        t.instrument_ = instrument;
                        t.price_ = e.dealAmount./e.dealVolume;
                        t.volume_ = e.dealVolume;
                        t.direction_ = e.direction;
                        t.offset_ = e.offsetFlag;
                        t.datetime1_ = e.time;
                        strategy.portfolio_.updateportfolio(t);
                    end
                end
            end
        end
    end
end
%end of withdrawentrusts
