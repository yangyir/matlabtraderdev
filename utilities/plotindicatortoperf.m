function plotindicatortoperf(price,indicator)

p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('Price',@isnumeric);
p.addRequired('Indicator',@isnumeric);
p.parse(price,indicator);
px = p.Results.Price;
indicator = p.Results.Indicator;

npx = size(px,1);
nind = size(indicator,1);
if npx < nind
    error('plotindicatortoperf:invalid input of price or indicator');
end

perf = price(2:end,end) - price(1:end-1,end);
nperf = npx-1;

matrix = [indicator(1:nperf,end),perf];
%sort the indicator 
matrix = sortrows(matrix);
matrix = [matrix(:,1),cumsum(matrix(:,1)];


    
    

end