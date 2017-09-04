function [ output_args ] = vanillaHistRevalSimple(asset,varargin)
p = inputParser;
p.CaseSensitive = fales;p.KeepUnmatched = true;
p.addRequired('AssetName',@ischar);
p.addParameter('Vanilla',@isstruct);
p.addParameter('LengthOfPeriod','',@ischar);

p.parse(asset,varargin{:});
assetName = p.Results.AssetName;
vanilla = p.Results.Vanilla;
lengthOfPeriod = p.Results.LengthOfPeriod;

%1.first to roll the continuous futures
rollinfo = rollfutures(assetName,'lengthofperiod',lengthOfPeriod,...
    calcdailyreturn',true);
ret = rollinfo.DailyReturn(:,2);
index = rollinfo.




end

