function [] = shortopensingleinstrument(strategy,ctp_code,lots)
    if isempty(strategy.counter_)
        fprintf('cStrat:counter not registered in strategy\n');
        return
    end

    if ~ischar(ctp_code)
        error('cStrat:shortopensingleinstrument:invalid ctp_code input')
    end
    isopt = isoptchar(ctp_code);
    if isopt
        instrument = cOption(ctp_code);
    else
        instrument = cFutures(ctp_code);
    end
    [bool, idx] = strategy.instruments_.hasinstrument(instrument);
    if ~bool, return; end
    %only place entrusts in case the instrument has been registered
    %with the strategy
    
    e = Entrust;
    direction = -1;
    offset = 1;
    if isopt
        q = strategy.mde_opt_.qms_.getquote(ctp_code);
    else
        q = strategy.mde_fut_.qms_.getquote(ctp_code);
    end
    
    orderprice = q.bid1 + strategy.bidspread_(idx);
    e.fillEntrust(1,ctp_code,direction,orderprice,lots,offset,ctp_code);
    
    ret = strategy.counter_.placeEntrust(e);
    if ret
        %the entrust is valid or alternatively the entrust has been placed
        strategy.entrusts_.push(e);
        %first we put the entrust into the pending entrust array
        %and we shall update the pending entrust array and the finished
        %entrust array once the entrust is finished
        strategy.entrustsfinished_.push(e);
        strategy.updateportfoliowithentrust(e); 
    end
    
end
%end of shortopensigleinstrument