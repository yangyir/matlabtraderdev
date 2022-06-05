function [ret] = riskmanagementintradayend(obj,varargin)
% a cETFWatcher method
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Position',[],@isstruct);
    p.addParameter('Extrainfo',[],@isstruct);
    p.parse(varargin{:});
    pos = p.Results.Position;
    ei = p.Results.Extrainfo;
    
    
end