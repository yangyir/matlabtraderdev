function [] = setcalcsignalflag(obj,instrument,calcflag)
    if ~isnumeric(calcflag), error('cStrat:setcalcsignalflag:invalid calcflag input');end
    if ~(calcflag == 0 || calcflag == 1),error('cStrat:setcalcsignalflag:invalid calcflag input');end

    [flag,idx] = obj.instruments_.hasinstrument(instrument);

    if ~flag
        error('cStrat:setcalcsignalflag:instrument not found')
    end

    obj.calcsignal_(idx) = calcflag;

end