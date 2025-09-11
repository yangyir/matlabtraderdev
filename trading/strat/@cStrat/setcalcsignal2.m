function [] = setcalcsignal2(strategy,underlier,calcflag)
%cStrat
    if ~isnumeric(calcflag), error('cStrat:setcalcsignal2:invalid calcflag data type input');end
    if ~(calcflag == 0 || calcflag == 1),error('cStrat:setcalcsignal2:invalid calcflag input');end

    [flag,idx] = strategy.hasunderlier(underlier);
    if ~flag
        if isempty(strategy.calcsignal_)
            strategy.calcsignal_ = calcflag*ones(strategy.countunderlier,1);
        else
            if size(strategy.calcsignal_,1) < strategy.countunderlier
                strategy.calcsignal_ = [strategy.calcsignal_;calcflag];
            end
        end
    else
        strategy.calcsignal_(idx) = calcflag;
    end

end