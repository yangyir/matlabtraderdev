function volatility = bjsimpv(S, X, r, settle, maturity,value, varargin)
%BJSIMPV Bjerksund-Stensland(2002) implied volatility.
%   Compute the implied volatility of an underlying asset from the market 
%   value of American call and put options using a Bjerksund-Stensland model.
%
%   Volatility = bjsimpv(Price, Strike, Rate, Settle, Maturity, Value)
%   Volatility = bjsimpv(Price, Strike, Rate, Settle, Maturity, Value, Limit, ...
%     Yield, Tolerance, Class)
%
% Optional Inputs: Limit, Yield, Tolerance, Class.
%
% Inputs: 
%   Price - Current price of the underlying asset.
%
%   Strike - Strike (i.e., exercise) price of the option.
%
%   Rate - Annualized continuously compounded risk-free rate of return over
%     the life of the option, expressed as a positive decimal number.
%
%   Settle - Settlement of trade dates
%
%   Maturity - Expiration of the option, expressed in years.
%
%   Value - Price (i.e., value) of a European option from which the implied
%     volatility of the underlying asset is derived.
%
% Optional Inputs:
%   Limit - Positive scalar representing the upper bound of the implied 
%     volatility search interval. If empty or missing, the default is 10,
%     or 1000% per annum.
%
%   Yield - Annualized continuously compounded yield of the underlying asset
%     over the life of the option, expressed as a decimal number. For example,
%     this could represent the dividend yield and foreign risk-free interest
%     rate for options written on stock indices and currencies, respectively.
%     If empty or missing, the default is zero.
%
%   Tolerance - Positive scalar implied volatility termination tolerance.
%     If empty or missing, the default is 1e-6.
%
%   Class - Option class (i.e., whether a call or put) indicating the 
%     option type from which the implied volatility is derived. This may
%     be either a logical indicator or a cell array of characters. To 
%     specify call options, set Class = true or Class = {'call'}; to specify
%     put options, set Class = false or Class = {'put'}. If empty or missing,
%     the default is a call option.
%
% Output:
%   Volatility - Implied volatility of the underlying asset derived from 
%     American option prices, expressed as a decimal number. If no solution
%     can be found, a NaN (i.e., Not-a-Number) is returned.
%

if nargin < 6
    error(message('bjsimpv:InsufficientInputs'))
end

if nargin > 10
   error(message('bjsimpv:TooManyInputs')) 
end

if any(value(:) < 0)
   error(message('bjsimpv:NegativeValue'))
end

if (nargin < 7) || isempty(varargin{1})
   limit = 10;
else
   if varargin{1}(1) <= 0
      error(message('bjsimpv:NonPositiveVolatility'))
   end
   limit = varargin{1};
end 

if (nargin < 8) || isempty(varargin{2})
   q = 0;
else
   q = varargin{2};
end

if (nargin < 9) || isempty(varargin{3})
    tol = 1e-6;
else
    if varargin{3} <= 0
       error(message('bjsimpv:NonPositiveTolerance'))
    end
    tol = varargin{3};
end

if (nargin < 10) || isempty(varargin{4})
   optionClass = 'call';
else
   optionClass = varargin{4};
   if ~(strcmpi(optionClass,'call') || strcmpi(optionClass,'put'))
       error(message('bjsimpv:InvalidOptionClass'))
   end
end

RateSpec = intenvset('ValuationDate',settle,'StartDates',settle,...
    'EndDates',maturity,'Rates',r,'Compounding',-1,'Basis',3);

StockSpec = stockspec(NaN,S,{'continuous'},q);

volatility = impvbybjs(RateSpec,StockSpec,settle,maturity,optionClass,...
    X,value,'Limit',[0.05,limit],'Tolerance',tol);


