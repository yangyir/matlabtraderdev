function obj = init(obj,varargin)
%cSyntheticStraddle
    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    p.addParameter('ID',{},@(x) validateattributes(x,{'char','numeric'},{},'','ID'));
    p.addParameter('Code','',@ischar);
    p.addParameter('Strike',[],@isnumeric);
    p.addParameter('Notional',[],@isnumeric);
    p.addParameter('Expiry',[],@isnumeric);
    
    p.parse(varargin{:});
    obj.id_ = p.Results.ID;
    obj.code_ = p.Results.Code;
    obj.strike_ = p.Results.Strike;
    obj.notional_ = p.Results.Notional;
    obj.stopdatetime1_ = p.Results.Expiry;
    
end