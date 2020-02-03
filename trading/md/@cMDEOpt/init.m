function obj = init(obj,varargin)
%cMDEOpt
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','mdeopt',@ischar);
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    
    % other default values
    obj.qms_ = cQMS;
    obj.settimerinterval(60);
end