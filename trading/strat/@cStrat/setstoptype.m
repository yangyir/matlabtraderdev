function [] = setstoptype(strategy,instrument,stoptype)
%cStrat
    if ischar(stoptype)
        if strcmpi(stoptype,'rel')
            typein = 0; 
        elseif strcmpi(stoptype,'abs')
            typein = 1;
        else
            typein = -1;
        end
    elseif isnumeric(stoptype)
        typein = stoptype;
    end

    if ~(typein == 0 || typein == 1)
        error('cStrat:setstoptype:invalid stoptype input')
    end
        
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        %default is relative pnl stop
        if isempty(strategy.pnl_stop_type_)
            strategy.pnl_stop_type_ = typein*ones(strategy.count,1);
        else
            if size(strategy.pnl_stop_type_,1) < strategy.count
                strategy.pnl_stop_type_ = [strategy.pnl_stop_type_;typein];
            end
        end
    else
        strategy.pnl_stop_type_(idx) = typein;
    end

end
%setstoptype