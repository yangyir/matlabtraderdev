function obj = init(obj,varargin)
%cMDEWind
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','mdewind',@ischar);
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    
    obj.settimerinterval(60);
end