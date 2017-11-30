function [ret,e] = longopensingleinstrument(strategy,ctp_code,lots)
    if isempty(strategy.counter_)
        fprintf('cStrat:counter not registered in strategy\n');
        return
    end
    
    if ~ischar(ctp_code)
        error('cStrat:longopensingleinstrument:invalid ctp_code input')
    end
    
    isopt = isoptchar(ctp_code);
    if isopt
        instrument = cOption(ctp_code);
    else
        instrument = cFutures(ctp_code);
    end
    
    [bool, idx] = strategy.instruments_.hasinstrument(instrument);
    if ~bool
        fprintf('cStrat:longopensingleinstrument:%s not registered in strategy\n',ctp_code)
        return; 
    end
    %only place entrusts in case the instrument has been registered
    %with the strategy
    
    e = Entrust;
    direction = 1;
    offset = 1;
    if isopt
        q = strategy.mde_opt_.qms_.getquote(ctp_code);
    else
        q = strategy.mde_fut_.qms_.getquote(ctp_code);
    end
    
    price = q.ask1 + strategy.askspread_(idx)*instrument.tick_size;
    e.fillEntrust(1,ctp_code,direction,price,lots,offset,ctp_code);
    
    ret = strategy.counter_.placeEntrust(e);
    if ret
        strategy.entrusts_.push(e);
        strategy.entrustspending_.push(e);
        strategy.updateportfoliowithentrust(e); 
    end
    
end
%end of longopensigleinstrument