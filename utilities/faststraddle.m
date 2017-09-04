function straddle = faststraddle(spot,strike,timeToMaturity,sigma,varargin)
if isempty(varargin)
    r = 0;
else
    r = varargin{1};
end

s = spot;
k = strike;
t = timeToMaturity;

vol = sigma;

%use Black model rather than Black-Scholes model
df = exp(-r*timeToMaturity);
d1 = log(s/k)+0.5*vol^2*t;
d1 = d1/vol/sqrt(t);
d2 = d1-vol*sqrt(t);
Nd1 = normcdf(d1);
Nd2 = normcdf(d2);
NMinusd1 = 1-Nd1;
NMinusd2 = 1-Nd2;
callPrice = df*(s*Nd1-k*Nd2);
putPrice = df*(k*NMinusd2-s*NMinusd1);
callDelta = df*Nd1;
putDelta = -df*NMinusd1;
straddle = struct('price',callPrice+putPrice,'delta',callDelta+putDelta,...
    'callprice',callPrice,'putprice',putPrice,...
    'callDelta',callDelta,'putDelta',putDelta);
end