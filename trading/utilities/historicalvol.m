function hv = historicalvol(px,nperiod,mode,varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('Price',@isnumeric);
%NumOfPeriod defines how many observations are used for calculate the
%historical vol
p.addRequired('NumOfPeriod',@isscalar);
p.addRequired('Mode',@ischar);
p.addParameter('Parameters',{},@(x)validateattributes(x,{'numeric','cell'},{},'','Parameters'));
p.parse(px,nperiod,mode,varargin{:});

price = p.Results.Price;
nPeriod = p.Results.NumOfPeriod;
mode = p.Results.Mode;
if ~(strcmpi(mode,'classical') || strcmpi(mode,'ewma') || strcmpi(mode,'garch'))
    error('historicalvol:invalid mode input')
end
parameters = p.Results.Parameters;

[npx,ncols] = size(price);
if ncols == 1
    ret = price(2:end)./price(1:end-1)-1;
elseif ncols == 2
    ret = [price(2:end,2),price(2:end,2)./price(1:end-1,2)-1];
elseif ncols == 5
    ret = [price(2:end,5),price(2:end,5)./price(1:end-1,5)-1];
end

if strcmpi(mode,'classical')
    hv = NaN(npx,ncols);
    for i = nPeriod:npx
        hv(i,ncols) = std(ret(i-nPeriod+1:i-1,ncols));
    end
    if ncols > 1
        hv(:,1) = px(:,1);
    end
elseif strcmpi(mode,'ewma')
    if isempty(parameters)
        lambda = 0.94;
    else
        lambda = parameters;
    end
    hv = NaN(npx,ncols);
    for i = 2:npx
        if i == 2
            hv(i,ncols) = abs(ret(i-1,ncols));
        else
            hv(i,ncols) = hv(i-1,ncols)^2*lambda + ...
                ret(i-1,ncols)^2*(1-lambda);
            hv(i,ncols) = sqrt(hv(i,ncols));
        end 
    end
    if ncols > 1
        hv(:,1) = px(:,1);
    end
elseif strcmpi(mode,'garch')
    hv = [];
end




end