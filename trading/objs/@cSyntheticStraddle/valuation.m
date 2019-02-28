function [res] = valuation(obj,varargin)
%cSyntheticStraddle
    p = inputParser;
    p.CaseSensitive = false;
    p.addParameter('ValuationDate',[],@(x) validateattributes(x,{'char','numeric'},{},'','ValuationDate'));
    p.addParameter('Spot',[],@isnumeric);
    p.addParameter('Vol',[],@isnumeric);
    p.parse(varargin{:});
    
    valdate = p.Results.ValuationDate;
    spot = p.Results.Spot;
    vol = p.Results.Vol;
    
    if isempty(valdate), error('cSyntheticStraddle:valuation:invalid/empty valuationdate input');end
    if isempty(spot), error('cSyntheticStraddle:valuation:invalid/empty spot input');end
    if isempty(vol), error('cSyntheticStraddle:invalid/empty vol input');end
    
    if ischar(valdate), valdate = datenum(valdate);end
    
    if valdate < floor(obj.opendatetime1_) || valdate > floor(obj.expirydatetime1_)
        obj.callcost_ = 0;
        obj.putcost_ = 0;
        obj.calldelta_ = 0;
        obj.putdelta_ = 0;
        res = 1;
        return
    end
    
    if valdate == floor(obj.opendatetime1_)
        %on the creation date of the synthetic straddle
        t = (floor(obj.expirydatetime1_) - valdate)/365;
        r = 0.04;
        [c,p] = blsprice(spot,obj.strike_,r,t,vol,r);
        obj.callcost_ = c;
        obj.putcost_ = p;
        [cdelta,pdelta] = blsdelta(spot,obj.strike_,r,t,vol,r);
        obj.calldelta_ = cdelta;
        obj.putdelta_ = pdelta;
        res = 1;
        return
    end
    
    if valdate == floor(obj.expirydatetime1_)
        obj.callcost_ = max(spot-obj.strike,0);
        obj.putcost_ = max(obj.strike_ - spot,0);
        obj.calldelta_ = 0;
        obj.putdelta_ = 0;
        res = 1;
        return
    end
    
    if valdate > floor(obj.opendatetime1_) && valdate < floor(obj.expirydatetime1_)
        
    end
        
    
    
    
    
end