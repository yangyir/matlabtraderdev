function obj = CreateObj(objHandle,objType,varargin)
%function to create object given inputs
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('ObjHandle',@ischar);
    p.addRequired('ObjType',@isobjtype);
    p.parse(objHandle,objType,varargin{:});
    objhandle = p.Results.ObjHandle;
    objtype = p.Results.ObjType;
    
    if strcmpi(objtype,'DICTIONARY')
        obj = CreateDictionary(objhandle,varargin{:});
    elseif strcmpi(objtype,'MODEL')
        obj = CreateModel(objhandle,varargin{:});
    elseif strcmpi(objtype,'YIELDCURVE')
        obj = CreateYieldCurve(objhandle,varargin{:});
    elseif strcmpi(objtype,'MKTDATA')
        obj = CreateMktData(objhandle,varargin{:});
    elseif strcmpi(objtype,'VOL')
        obj = CreateVol(objhandle,varargin{:});
    elseif strcmpi(objtype,'SECURITY')
        obj = CreateSecurity(objhandle,varargin{:});
    elseif strcmpi(objtype,'BOOK')
        obj = CreateBook(objhandle,varargin{:});
    elseif strcmpi(objtype,'EXTRAINFO') || strcmpi(objtype,'RESULTS')
        obj = CreateResults(objhandle,varargin{:});
    end
   
        
    
end