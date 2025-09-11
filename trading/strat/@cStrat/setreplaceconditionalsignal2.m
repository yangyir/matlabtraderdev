function [] = setreplaceconditionalsignal2(strategy,underlier,signalflag)
%cStrat
    if ~isnumeric(signalflag), error('cStrat:setreplaceconditionalsignal2:invalid calcflag data type input');end
    if ~(signalflag == 0 || signalflag == 1),error('cStrat:setreplaceconditionalsignal2:invalid calcflag input');end

    [flag,idx] = strategy.hasunderlier(underlier);
    if ~flag
        if isempty(strategy.replaceconditionalsignal_)
            strategy.replaceconditionalsignal_ = signalflag*ones(strategy.countunderlier,1);
        else
            if size(strategy.replaceconditionalsignal_,1) < strategy.countunderlier
                strategy.replaceconditionalsignal_ = [strategy.calcsignal_;signalflag];
            end
        end
    else
        strategy.replaceconditionalsignal_(idx) = signalflag;
    end

end