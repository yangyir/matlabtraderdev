function [] = setparameters(obj,instrument,params)
    if isempty(obj.nperiods_), obj.nperiods_ = 144*ones(obj.count,1); end

    if ~(isa(instrument,'cInstrument') || ischar(instrument))
        error('cStratFutMultiWRPlusBatman:setparameters:invalid instrument input')
    end
    
    if ischar(instrument)
        instrument = code2instrument(instrument);
    end

    if ~isstruct(params)
        error('cStratFutMultiWRPlusBatman:setparameters:invalid params input')
    end
    
    [flag,idx] = obj.instruments_.hasinstrument(instrument);

    if ~flag
        error('cStratFutMultiWRPlusBatman:setparameters:instrument not found')
    end

    propnames = fields(params);
    %default value
    wlpr = 144;
    for j = 1:size(propnames,1)
        if strcmpi(propnames{j},'numofperiods')
            wlpr = params.(propnames{j});
            break
        end
    end

    obj.nperiods_(idx) = wlpr;

    params_ = struct('name','WilliamR','values',{{propnames{j},wlpr}});
    obj.mde_fut_.settechnicalindicator(instrument,params_);

end
%end of setparameters