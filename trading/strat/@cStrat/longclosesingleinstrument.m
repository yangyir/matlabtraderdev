function [ret,e] = longclosesingleinstrument(strategy,ctp_code,lots,closetodayFlag)
    if nargin < 4
        closetodayFlag = 0;
    end
    
    if isempty(strategy.counter_)
        fprintf('cStrat:counter not registered in strategy\n');
        return
    end

    if ~ischar(ctp_code)
        error('cStrat:shortclosesingleinstrument:invalid ctp_code input')
    end
    
    isopt = isoptchar(ctp_code);
    if isopt
        instrument = cOption(ctp_code);
    else
        instrument = cFutures(ctp_code);
    end
    
    [f1, idx] = strategy.instruments_.hasinstrument(instrument);
    [f2,idxp] = strategy.portfolio_.hasinstrument(instrument);
    
    if ~f1
        fprintf('cStrat:shortclosesingleinstrument:%s not registered in strategy\n',ctp_code)
        return; 
    end
    
    if ~f2
        fprintf('cStrat:shortclosesingleinstrument:%s not traded in strategy\n',ctp_code)
        return; 
    end
    
    volume = abs(strategy.portfolio_.instrument_volume(idxp));
    if volume >= 0
        fprintf('cStrat:longclosesingleinstrument:%s:existing short position not found\n',ctp_code);
    end
    
    
    if abs(volume) < abs(lots)
        fprintf('cStrat:longclosesingleinstrument:%s:input size exceeds existing size\n',ctp_code);
        lots = abs(volume);
    end
    
    e = Entrust;
    direction = 1;
    offset = -1;
    if isopt
        q = strategy.mde_opt_.qms_.getquote(ctp_code);
    else
        q = strategy.mde_fut_.qms_.getquote(ctp_code);
    end
    
    orderprice = q.ask1 + strategy.askspread_(idx)*instrument.tick_size;
    e.fillEntrust(1,ctp_code,direction,orderprice,lots,offset,ctp_code);
    if closetodayFlag, e.closetodayFlag = 1;end
    
    ret = strategy.counter_.placeEntrust(e);
    if ret
        strategy.entrusts_.push(e);
        strategy.entrustspending_.push(e);
        strategy.updateportfoliowithentrust(e);
    end
    
end
%end of longopensigleinstrument