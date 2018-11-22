function [ret,entrusts] = placeentrusts(obj,varargin)
%cStratManual
    if ~strcmpi(obj.status_,'working')
        ret = 0;
        entrusts = {};
        fprintf('%s:placeentrusts is not allowed when the strateg is not working\n',class(obj));
        return
    end
    %
    p = inputParser;
    p.addParameter('Instruments',{},@iscell);
    p.addParameter('Prices',[],@isnumeric);
    p.addParameter('Volumes',[],@isnumeric);
    %todo:
    %add more optional parameters for pair trading
    
    p.parse(varargin{:});
    instruments = p.Results.Instruments;
    prices = p.Results.Prices;
    volumes = p.Results.Volumes;
    
    f1 = length(instruments) == length(prices);
    f2 = length(instruments) == length(volumes);
    if ~(f1&&f2)
        ret = 0;
        entrusts = {};
        fprintf('%s:placeentrusts with invald instruments,prices or volumes inputs\n',class(obj));
        return
    end
    
    
    
    
    
    
    
    
    
end