function [] = update(obj,varargin)
    if strcmpi(obj.status_,'closed')
        return
    end
    %
    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    p.addParameter('MDEFut',{},...
                @(x) validateattributes(x,{'cMDEFut'},{},'','MDEFut'));
    p.parse(varargin{:});
    mdefut = p.Results.MDEFut;
    
    tick = mdefut.getlasttick(obj.instrument_);
    datetime = tick(1);
    bid = tick(2);
    ask = tick(3);
    if strcmpi(obj.riskmanagementmethod_,'standard')
        if isempty(obj.targetprice_) && isempty(obj.stoplossprice_)
            return
        elseif isempty(obj.targetprice_) && ~isempty(obj.stoplossprice_)
        elseif isempty(obj.targetprice_) && ~isempty(obj.stoplossprice_)
        end
    elseif strcmpi(obj.riskmanagementmethod_,'batman')
        error('not implemented yet')
    end
end