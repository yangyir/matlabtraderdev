function [call,put] = bjsprice(S, X, r, settle, maturity,sig, q)
%BJS Bjerksund-Stensland(2002) American put and call option pricing.
%   Compute American put and call option prices using Bjerksund-Stensland model.
%
%   [Call,Put] = bjsprice(Price, Strike, Rate, Settle, Maturity, Volatility)
%   [Call,Put] = bjsprice(Price, Strike, Rate, Settle, Maturity, Volatility, Yield)
%
%   Optional Input: Yield
%
%   Inputs:
%   Price   	- Current price of the underlying asset.
%
%   Strike      - Strike (i.e., exercise) price of the option.
%
%   Rate        - Annualized continuously compounded risk-free rate of return
%                 over the life of the option, expressed as a positive decimal
%                 number.
%
%   Settle      - Settlement of trade dates
%
%   Maturity    - Expiration of the option, expressed in years.
%
%   Volatility  - Annualized asset price volatility (i.e., annualized standard
%                 deviation of the continuously compounded asset return),
%                 expressed as a positive decimal number.
%
%   Optional Input:
%   Yield       - Annualized continuously compounded yield of the underlying
%                 asset over the life of the option, expressed as a decimal
%                 number. If Yield is empty or missing. the default value is
%                 zero.
%
%                 For example, this could represent the dividend yield (annual
%                 dividend rate expressed as a percentage of the price of the
%                 security) or foreign risk-free interest rate for options
%                 written on stock indices and currencies, respectively.
%
%   Outputs:
%   Call        - Price (i.e., value) of a American call option.
%
%   Put         - Price (i.e., value) of a American put option.

if nargin < 6
    error(message('bjsprice:InsufficientInputs'))
end

if (nargin < 7) || isempty(q)
    q = 0;
end

StockSpec = stockspec(sig,S,{'continuous'},q);

%ACT/365:Basis 3
RateSpec = intenvset('ValuationDate',settle,'StartDates',settle,...
    'EndDates',maturity,'Rates',r,'Compounding',-1,'Basis',3);

OptSpec = {'call';'put'};

Price = optstockbybjs(RateSpec,StockSpec,settle,maturity,OptSpec,X);

call = Price(1);
put = Price(2);


end