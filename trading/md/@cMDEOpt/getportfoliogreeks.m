function res = getportfoliogreeks(obj,instruments,weights)
%cMDEOpt
    ninstruments = size(instruments,1);
    nweights = size(weights,1);
    if ninstruments ~= nweights
        error('cMDEOpt:getportfoliogreeks:mismatch between size of instruments and weights')
    end
    
    delta = 0;
    gamma = 0;
    vega = 0;
    theta = 0;
    deltacarry = 0;
    gammacarry = 0;
    vegacarry = 0;
    deltacarryyesterday = 0;
    gammacarryyesterday = 0;
    vegacarryyesterday = 0;
    thetacarryyesterday = 0;
    optpremium = 0;
    optpremimyesterday = 0;
        
    for i = 1:ninstruments
        instrument = instruments{i};
        if ischar(instrument), instrument = code2instrument(instrument);end
        greeks = obj.getgreeks(instrument);
        if isempty(greeks)
            res = {};
            fprintf('cMDEOpt:getportfoliogreeks:%s not registered!!!\n',instrument.code_ctp);
            return
        end
        
        if isa(instrument,'cOption')
            qopt = obj.qms_.getquote(instrument);
            if weights(i) > 0
                optpremium = optpremium + qopt.ask1*instrument.contract_size*weights(i);
            else
                optpremium = optpremium + qopt.bid1*instrument.contract_size*weights(i);
            end
        end
        
        delta = delta + greeks.delta * weights(i);
        gamma = gamma + greeks.gamma * weights(i);
        vega = vega + greeks.vega * weights(i);
        theta = theta + greeks.theta * weights(i);
        %
        deltacarry = deltacarry + greeks.deltacarry * weights(i);
        gammacarry = gammacarry + greeks.gammacarry * weights(i);
        vegacarry = vegacarry + greeks.vegacarry * weights(i);
        %
        deltacarryyesterday = deltacarryyesterday + greeks.deltacarryyesterday * weights(i);
        gammacarryyesterday = gammacarryyesterday + greeks.gammacarryyesterday * weights(i);
        vegacarryyesterday = vegacarryyesterday + greeks.vegacarryyesterday * weights(i);
        thetacarryyesterday = thetacarryyesterday + greeks.thetacarryyesterday * weights(i);
        optpremimyesterday = optpremimyesterday + greeks.pvcarryyesterday * weights(i);

    end
        
    res = struct('delta',delta,...
        'gamma',gamma,...
        'vega',vega,...
        'theta',theta,...
        'deltacarry',deltacarry,...
        'gammacarry',gammacarry,...
        'vegacarry',vegacarry,...
        'deltacarryyesterday',deltacarryyesterday,...
        'gammacarryyesterday',gammacarryyesterday,...
        'vegacarryyesterday',vegacarryyesterday,...
        'thetacarryyesterday',thetacarryyesterday,...
        'premium',optpremium,...
        'pvcarryyesterday',optpremimyesterday);
    
end