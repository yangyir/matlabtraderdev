function [] = setriskvalue(stratopt,instrument,riskname,value)
    if ~isnumeric(value)
        error('cStratOptMultiShortVol:setriskvalue:invalid value input')
    end

    isopt = false;
    isunderlier = false;

    [flag,idx] = stratopt.instruments_.hasinstrument(instrument);
    if flag
        isopt = true;
    else
        [isunderlier,idx] = stratopt.underliers_.hasinstrument(instrument);
        if ~isunderlier
            error('cStratOptMultiShortVol:setriskvalue:instrument not found')
        end
    end

    if isopt
        if strcmpi(riskname,'delta')
            if isempty(stratopt.delta_), stratopt.delta_ = zeros(stratopt.count,1);end
            stratopt.delta_(idx,1) = value;
        elseif strcmpi(riskname,'gamma')
            if isempty(stratopt.gamma_), stratopt.gamma_ = zeros(stratopt.count,1);end
            stratopt.gamma_(idx,1) = value;
        elseif strcmpi(riskname,'vega')
            if isempty(stratopt.vega_), stratopt.vega_ = zeros(stratopt.count,1);end
            stratopt.vega_(idx,1) = value;
        elseif strcmpi(riskname,'theta')
            if isempty(stratopt.theta_), stratopt.theta_ = zeros(stratopt.count,1);end
            stratopt.theta_(idx,1) = value;
        elseif strcmpi(riskname,'impvol')
            if isempty(stratopt.impvol_), stratopt.impvol_ = zeros(stratopt.count,1);end
            stratopt.impvol_(idx,1) = value;    
        elseif strcmpi(riskname,'deltacarry')
            if isempty(stratopt.deltacarry_), stratopt.deltacarry_ = zeros(stratopt.count,1);end
            stratopt.deltacarry_(idx,1) = value;
        elseif strcmpi(riskname,'gammacarry')
            if isempty(stratopt.gammacarry_), stratopt.gammacarry_ = zeros(stratopt.count,1);end
            stratopt.gammacarry_(idx,1) = value;
        elseif strcmpi(riskname,'vegacarry')
            if isempty(stratopt.vegacarry_), stratopt.vegacarry_ = zeros(stratopt.count,1);end
            stratopt.vegacarry_(idx,1) = value;
        elseif strcmpi(riskname,'thetacarry')
            if isempty(stratopt.thetacarry_), stratopt.thetacarry_ = zeros(stratopt.count,1);end
            stratopt.thetacarry_(idx,1) = value;
        elseif strcmpi(riskname,'deltacarryyesterday')
            if isempty(stratopt.deltacarryyesterday_), stratopt.deltacarryyesterday_ = zeros(stratopt.count,1);end
            stratopt.deltacarryyesterday_(idx,1) = value;
        elseif strcmpi(riskname,'gammacarryyesterday')
            if isempty(stratopt.gammacarryyesterday_), stratopt.gammacarryyesterday_ = zeros(stratopt.count,1);end
            stratopt.gammacarryyesterday_(idx,1) = value;
        elseif strcmpi(riskname,'vegacarryyesterday')
            if isempty(stratopt.vegacarryyesterday_), stratopt.vegacarryyesterday_ = zeros(stratopt.count,1);end
            stratopt.vegacarryyesterday_(idx,1) = value;
        elseif strcmpi(riskname,'thetacarryyesterday')
            if isempty(stratopt.thetacarryyesterday_), stratopt.thetacarryyesterday_ = zeros(stratopt.count,1);end
            stratopt.thetacarryyesterday_(idx,1) = value;
        elseif strcmpi(riskname,'impvolcarryyesterday')
            if isempty(stratopt.impvolcarryyesterday_), stratopt.impvolcarryyesterday_ = zeros(stratopt.count,1);end
            stratopt.impvolcarryyesterday_(idx,1) = value;
        elseif strcmpi(riskname,'pvcarryyesterday')
            if isempty(stratopt.pvcarryyesterday_), stratopt.pvcarryyesterday_ = zeros(stratopt.count,1);end
            stratopt.pvcarryyesterday_(idx,1) = value;
        else
            error('cStratOptMultiShortVol:invalid risk name input for option')
        end
    end

    if isunderlier
        if strcmpi(riskname,'delta') || strcmpi(riskname,'deltacarry')
            if isempty(stratopt.delta_underlier_), stratopt.delta_underlier_ = zeros(stratopt.countunderliers,1);end
            stratopt.delta_underlier_(idx,1) = value;
        else
            error('cStratOptMultiShortVol:invalid risk name input for underlier')
        end
    end

end
%end of setriskvalue