function [] = setparameters(strategy,instrument,params)
    if isempty(strategy.numofperiods_), strategy.numofperiods_ = 144*ones(strategy.count,1); end

    if ~isa(instrument,'cInstrument')
        error('cStratFutMultiWR:setparameters:invalid instrument input')
    end

    if ~isstruct(params)
        error('cStratFutMultiWR:setparameters:invalid params input')
    end
    
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);

    if ~flag
        error('cStratFutMultiWR:setparameters:instrument not found')
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

    strategy.numofperiods_(idx) = wlpr;

    params_ = struct('name','WilliamR','values',{{propnames{j},wlpr}});
    strategy.mde_fut_.settechnicalindicator(instrument,params_);

end
%end of setparameters