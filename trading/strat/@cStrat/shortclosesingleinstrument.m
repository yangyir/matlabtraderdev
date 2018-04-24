function [ret,e] = shortclosesingleinstrument(strategy,ctp_code,lots,closetodayFlag,spread)
    if lots <= 0 
        return; 
    end

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
    instrument.loadinfo([ctp_code,'_info.txt']);
    
    [f1, idx] = strategy.instruments_.hasinstrument(instrument);
    [f2,idxp] = strategy.bookrunning_.hasposition(instrument);
    
    if ~f1
        fprintf('cStrat:shortclosesingleinstrument:%s not registered in strategy\n',ctp_code)
        return; 
    end
    
    if ~f2
        fprintf('cStrat:shortclosesingleinstrument:%s not traded in strategy\n',ctp_code)
        return; 
    end
    
    volume = abs(strategy.bookrunning_.positions_{idxp}.position_total_);
    
    if volume <= 0
        fprintf('cStrat:shortclosesingleinstrument:%s:existing long position not found\n',ctp_code);
        return
    end
    
    if abs(volume) < abs(lots)
        %note:we will close the current position with the lots size
        %adjuste. however, an warning message shall still be printed on the
        %screen
        fprintf('cStrat:shortclosesingleinstrument:%s:input size exceeds existing size\n',ctp_code);
        lots = abs(volume);
    end
    
    if isopt
        q = strategy.mde_opt_.qms_.getquote(ctp_code);
    else
        q = strategy.mde_fut_.qms_.getquote(ctp_code);
    end
    
    if nargin < 5
        orderprice = q.bid1 + strategy.bidspread_(idx)*instrument.tick_size;
    else
        orderprice = q.bid1 + spread*instrument.tick_size;
    end
    
    if closetodayFlag
        [ret,e] = strategy.trader_.placeorder(ctp_code,'s','ct',orderprice,lots,strategy.helper_);
    else
        [ret,e] = strategy.trader_.placeorder(ctp_code,'s','c',orderprice,lots,strategy.helper_);
    end
    
    if ret
        strategy.updatestratwithentrust(e);
    end
    
end
%end of shortclosesigleinstrument