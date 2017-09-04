function [premium,delta,gamma,vega,theta] = valstraddle(price,strike,rate,t,vol,yield,notional)
[cPremium,pPremium] = blsprice(price,strike,rate,t,vol*sqrt(252),yield);
premium = (cPremium+pPremium)*notional/price;

[cDelta,pDelta] = blsdelta(price,strike,rate,t,vol*sqrt(252),yield);
delta = (cDelta+pDelta)*notional;

gamma = blsgamma(price,strike,rate,t,vol*sqrt(252),yield);
gamma = 2.0*gamma*price*notional;

vega = blsvega(price,strike,rate,t,vol*sqrt(252),yield);
vega = 2.0*vega*0.01/price*notional;

[cTheta,pTheta] = blstheta(price,strike,rate,t,vol*sqrt(252),yield);
theta = (cTheta+pTheta)/252/price*notional;

end