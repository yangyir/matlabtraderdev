function [value] = getriskvalue(stratopt,instrument,riskname)
    isopt = false;
    isunderlier = false;

    [flag,idx] = stratopt.instruments_.hasinstrument(instrument);
    if flag
        isopt = true;
    else
        [isunderlier,idx] = stratopt.underliers_.hasinstrument(instrument);
        if ~isunderlier
            error('cStratOptMultiShortVol:instrument not found')
        end
    end

    if isopt
        if strcmpi(riskname,'delta')
            value = stratopt.delta_(idx,1);
        elseif strcmpi(riskname,'gamma')
            value = stratopt.gamma_(idx,1);
        elseif strcmpi(riskname,'vega')
            value = stratopt.vega_(idx,1);
        elseif strcmpi(riskname,'theta')
            value = stratopt.theta_(idx,1);
        elseif strcmpi(riskname,'impvol')
            value = stratopt.impvol_(idx,1);
        elseif strcmpi(riskname,'deltacarry')
            value = stratopt.deltacarry_(idx,1);
        elseif strcmpi(riskname,'gammacarry')
            value = stratopt.gammacarry_(idx,1);
        elseif strcmpi(riskname,'vegacarry')
            value = stratopt.vegacarry_(idx,1);
        elseif strcmpi(riskname,'thetacarry')
            value = stratopt.thetacarry_(idx,1); 
        elseif strcmpi(riskname,'deltacarryyesterday')
            value = stratopt.deltacarryyesterday_(idx,1);
        elseif strcmpi(riskname,'gammacarryyesterday')
            value = stratopt.gammacarryyesterday_(idx,1);
        elseif strcmpi(riskname,'vegacarryyesterday')
            value = stratopt.vegacarryyesterday_(idx,1);
        elseif strcmpi(riskname,'thetacarryyesterday')
            value = stratopt.thetacarryyesterday_(idx,1);
        elseif strcmpi(riskname,'impvolcarryyesterday')
            value = stratopt.impvolcarryyesterday_(idx,1);
        elseif strcmpi(riskname,'pvcarryyesterday')
            value = stratopt.pvcarryyesterday_(idx,1);
        else
            error('cStratOptMultiShortVol:getriskvalue:invalid risk name input for option')
        end
    end

    if isunderlier
        if strcmpi(riskname,'delta') || strcmpi(riskname,'deltacarry')
            value = stratopt.delta_underlier_(idx,1);
        else
            error('cStratOptMultiShortVol:getriskvalue:invalid risk name input for underlier')
        end
    end
end