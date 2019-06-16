function obj = init(obj,varargin)
%cGUIFut
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','guifut',@ischar);
    p.addParameter('MDEFut',{},@(x) validateattributes(x,{'cMDEFut','cell'},{},'','MDEFut'));
    p.addParameter('Handles',{},@(x) validateattributes(x,{'struct','cell'},{},'','Handles'));
    
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    obj.mdefut_ = p.Results.MDEFut;
    obj.handles = p.Results.Handles;
end