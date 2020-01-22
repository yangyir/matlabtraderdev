function obj = init(obj,varargin)
%cMDEOptBBG
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','mdeoptbbg',@ischar);
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    
    obj.settimerinterval(60);
end