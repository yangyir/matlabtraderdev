function vol =  CreateVol(volHandle,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('ObjHandle',@ischar);
    p.addParameter('VolName',{},...
        @(x) validateattributes(x,{'char'},{},'','VolName'));
    p.parse(volHandle,varargin{:});
    objhandle = p.Results.ObjHandle;
    volname = p.Results.VolName;
    
    if strcmpi(volname,'MARKETVOL')
        vol = cMarketVol(objhandle,varargin{:});
    elseif strcmpi(volname,'LOCALVOL')
        vol = cLocalVol(objhandle,varargin{:});
    else
        error('vol not implemented yet')
    end
end