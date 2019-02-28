function obj = init(obj,varargin)
%cSyntheticStraddle
    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    p.addParameter('ID',{},@(x) validateattributes(x,{'char','numeric'},{},'','ID'));
    p.addParameter('Code','',@ischar);
    p.addParameter('Strike',[],@isnumeric);
    p.addParameter('Notional',[],@isnumeric);
    p.addParameter('StartDate',[],@(x) validateattributes(x,{'char','numeric'},{},'','StartDate'));
    p.addParameter('ExpiryDate',[],@(x) validateattributes(x,{'char','numeric'},{},'','ExpiryDate'));
    
    p.parse(varargin{:});
    obj.id_ = p.Results.ID;
    obj.code_ = p.Results.Code;
    obj.strike_ = p.Results.Strike;
    obj.notional_ = p.Results.Notional;
    
    startdate = p.Results.StartDate;
    if ~isempty(startdate)
        if ischar(startdate)
            obj.opendatetime1_ = datenum(startdate);
        else
            obj.opendatetime1_ = startdate;
        end
    end
    
    expiry = p.Results.ExpiryDate;
    if ischar(expiry)
        try
            expirynum = datenum(expiry);
            obj.expirydatetime1_ = expirynum;
        catch
            obj.expirydatetime1_ = dateadd(obj.opendatetime1_,expiry);
        end
        
    else
        obj.expirydatetime1_ = p.Results.ExpiryDate;
    end
    
end