function obj = init(obj,varargin)
%cMDEOptSimple
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','mdeoptsimple',@ischar);
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    
    % other default values
    obj.qms_ = cQMS;
    % mdeoptsimple is only for simple arbitrage and greeks are not needed
    obj.qms_.watcher_.calcgreeks = false;
    obj.settimerinterval(60);
end