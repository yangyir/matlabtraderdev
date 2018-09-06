function [] = setlimittype(strategy,instrument,limitype)    
%cStrat
    if ischar(limitype)
        if strcmpi(limitype,'rel')
            typein = 0; 
        elseif strcmpi(limitype,'abs')
            typein = 1;
        else
            typein = -1;
        end
    elseif isnumeric(limitype)
        typein = limitype;
    end

    if ~(typein == 0 || typein == 1)
        error('cStrat:setlimittype:invalid stoptype input')
    end
        
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag
        %default is relative pnl stop
        if isempty(strategy.pnl_limit_type_)
            strategy.pnl_limit_type_ = typein*ones(strategy.count,1);
        else
            if size(strategy.pnl_limit_type_,1) < strategy.count
                strategy.pnl_limit_type_ = [strategy.pnl_limit_type_;typein];
            end
        end
    else
        strategy.pnl_limit_type_(idx) = typein;
    end



end
%setlimittype