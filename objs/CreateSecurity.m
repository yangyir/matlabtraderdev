function security = CreateSecurity(objhandle,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('ObjHandle',@ischar);
    p.addParameter('SecurityName',{},...
        @(x) validateattributes(x,{'char'},{},'','SecurityName'));
    p.parse(objhandle,varargin{:});
    objhandle = p.Results.ObjHandle;
    securityname = p.Results.SecurityName;
    
    if strcmpi(securityname,'EUROPEAN')
        security = cEuropean(objhandle,varargin{:});
    elseif strcmpi(securityname,'VANILLA')
        security = cVanilla(objhandle,varargin{:});
    else
        error([securityname,' not implemented yet']);
    end
    
end