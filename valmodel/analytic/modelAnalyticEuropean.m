function res =  modelAnalyticEuropean(yc,mktdata,vol,european,model)
%valuation of european option with black model
%the model input here is to determine the calcintrinsic flag
%
%1.sanity checks
if ~isa(yc,'cYieldCurve')
    error('modelAnalyticEuropean:yield curve is missing!')
end

if ~isa(mktdata,'cMktData')
    error('modelAnalyticEuropean:mktdata is missing!')
end

if ~(isa(vol,'cVol') && isa(vol,'cMarketVol'))
    error('modelAnalyticEuropean:market vol is missing!')
end

if ~isa(european,'cEuropean')
    error('modelAnalyticEuropean:european option is missing!')
end

if ~isa(model,'cModelAnalytic')
    error('modelAnalyticEuropean:analytic model is missing!')
end

if yc.ValuationDate ~= mktdata.ValuationDate
    error('modelAnalyticEuropean:valuation date of the yield curve and market data shall be the same!')
end

if european.Notional == 0
    res = 0;
    return
end

%2.pricing
Settle = datenum(yc.ValuationDate,'yyyy-mm-dd');
Maturity = datenum(european.ExpiryDate,'yyyy-mm-dd');
if Settle > Maturity
    res = 0;
    return
end
 
Strike = european.Strike;
Fwd = mktdata.MktDataFwd(Maturity,yc);

if Settle == Maturity
    if strcmpi(european.OptionType,'Call')
        res = max(Fwd-Strike,0);
    elseif strcmpi(european.OptionTypt,'Put')
        res = max(Strike-Fwd,0);
    end
    res = res*european.Notional;
    return
end

if model.CalcIntrinsic == 1
    df = yc.DiscFact(Maturity);
    if strcmpi(european.OptionType,'Call')
        res = df*max(Fwd-Strike,0);
    elseif strcmpi(european.OptionTypt,'Put')
        res = df*max(Strike-Fwd,0);
    end
    res = res*european.Notional;
    return
end

Sigma = vol.getVol(Strike,Maturity,Fwd);
r = yc.ZeroRate(Maturity);

%define the RateSpec and StockSpec
RateSpec = intenvset('ValuationDate',Settle,'StartDates',Settle,...
    'EndDates',Maturity,'Rates',r,'Compounding',-1,...
    'Basis',basis2num(yc.DiscountBasis));

StockSpec = stockspec(Sigma,Fwd);

%define the option
OptSpec = {european.OptionType};

res = optstockbyblk(RateSpec,StockSpec,Settle,Maturity,OptSpec,Strike);
res = res*european.Notional;

end