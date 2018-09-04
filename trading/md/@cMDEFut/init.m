function obj = init(obj,varargin)
%cMDEFut
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','mdefut',@ischar);
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    
    % other default values
    obj.qms_ = cQMS;
    obj.timer_interval_ = 0.5;
end