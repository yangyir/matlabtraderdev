function [] = setreplaceconditionalsignal(strategy,instrument,signalflag)
%cStrat
    if ~isnumeric(signalflag), error('cStrat:setreplaceconditionalsignal:invalid calcflag data type input');end
    if ~(signalflag == 0 || signalflag == 1),error('cStrat:setreplaceconditionalsignal:invalid calcflag input');end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        if isempty(strategy.replaceconditionalsignal_)
            strategy.replaceconditionalsignal_ = signalflag*ones(strategy.count,1);
        else
            if size(strategy.replaceconditionalsignal_,1) < strategy.count
                strategy.replaceconditionalsignal_ = [strategy.calcsignal_;signalflag];
            end
        end
    else
        strategy.replaceconditionalsignal_(idx) = signalflag;
    end

end