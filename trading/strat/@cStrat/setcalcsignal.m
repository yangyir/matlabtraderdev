function [] = setcalcsignal(strategy,instrument,calcflag)
%cStrat
    if ~isnumeric(calcflag), error('cStrat:setcalcsignal:invalid calcflag data type input');end
    if ~(calcflag == 0 || calcflag == 1),error('cStrat:setcalcsignal:invalid calcflag input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.calcsignal_)
            strategy.calcsignal_ = calcflag*ones(strategy.count,1);
        else
            if size(strategy.calcsignal_,1) < strategy.count
                strategy.calcsignal_ = [strategy.calcsignal_;calcflag];
            end
        end
    else
        strategy.calcsignal_(idx) = calcflag;
    end

end