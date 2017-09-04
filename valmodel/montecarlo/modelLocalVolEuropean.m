function res =  modelLocalVolEuropean(yc,mktdata,vol,european,model)
%valuation of european option with MC local vol model
%
%1.santity check
if ~isa(yc,'cYieldCurve')
    error('modelLocalVolEuropean:yield curve is missing!')
end

if ~isa(mktdata,'cMktData')
    error('modelLocalVolEuropean:mktdata is missing!')
end

if ~(isa(vol,'cVol') && isa(vol,'cLocalVol'))
    error('modelLocalVolEuropean:localvol is missing!')
end

if ~isa(european,'cEuropean')
    error('modelLocalVolEuropean:european option is missing!')
end

if ~isa(model,'cModelX')
    error('modelLocalVolEuropean:modelX is missing!')
end

if yc.ValuationDate ~= mktdata.ValuationDate
    error('modelLocalVolEuropean:valuation date of the yield curve and mktdata shall be the same!')
end

if european.Notional == 0
    res = 0;
    return
end

%2.pricing
settle = datenum(yc.ValuationDate,'yyyy-mm-dd');
maturity = datenum(european.ExpiryDate,'yyyy-mm-dd');
if settle > maturity
    res = 0;
    return
end

strike = european.Strike;
fwd = mktdata.MktDataFwd(maturity,yc);

if settle == maturity
    if strcmpi(european.OptionType,'call')
        res = max(fwd-strike,0);
    elseif strcmpi(european.OptionType,'put')
        res = max(strike-fwd,0);
    end
    res = res*european.Notional;
    return
end

if model.CalcIntrinsic == 1
    df = yc.DiscFact(maturity);
    if strcmpi(european.OptionType,'call')
        res = df*max(fwd-strike,0);
    elseif strcmpi(european.OptionType,'put')
        res = df*max(strike-fwd,0);
    end
    res = res*european.Notional;
    return
end

paths = modelLocalVolSimulation(yc,mktdata,vol,european,model);

nruns = model.NumRuns;
premium = zeros(nruns,1);
for i = 1:nruns
    if strcmpi(european.OptionType,'call')
        payoff = max(paths{i}(end,:)-strike,0);
    else
        payoff = max(strike-paths{i}(end,:),0);
    end
    df = yc.DiscFact(maturity);
    premium(i) = df*mean(payoff);
end

res = mean(premium)*european.Notional;




end