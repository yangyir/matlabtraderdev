function [] = setexecutiontype(stratfutwr,instrument,typein)
    if ~ischar(typein), error('cStratFutMultiWR:setexecutiontype:invalid type input'); end
    if ~(strcmpi(typein,'fixed') || strcmpi(typein,'martingale'))
        error('cStratFutMultiWR:setexecutiontype:invalid type input');
    end
    
    if isempty(stratfutwr.executiontype_), stratfutwr.executiontype_ = cell(stratfutwr.count,1);end

    [flag,idx] = stratfutwr.instruments_.hasinstrument(instrument);
    
    if flag
        stratfutwr.executiontype_{idx} = typein;
    else
        error('cStratFutMultiWR:setexecutiontype:instrument not found')
    end
    
end