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
    multi = instrument.contract_size;
    if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
        multi = multi/100;
    end
    
    [f1, idx] = strategy.instruments_.hasinstrument(instrument);
    [f2,idxp] = strategy.portfolio_.hasposition(instrument);
    
    if ~f1
        fprintf('cStrat:shortclosesingleinstrument:%s not registered in strategy\n',ctp_code)
        return; 
    end
    
    if ~f2
        fprintf('cStrat:shortclosesingleinstrument:%s not traded in strategy\n',ctp_code)
        return; 
    end
    
    volume = abs(strategy.portfolio_.pos_list{idxp}.position_total_);
    
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
    
    e = Entrust;
    direction = -1;
    offset = -1;
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
    
    e.fillEntrust(1,ctp_code,direction,orderprice,lots,offset,ctp_code);
    if ~isopt, e.assetType = 'Future'; end
    e.multiplier = multi;
    if closetodayFlag, e.closetodayFlag = 1;end
    
    ret = strategy.counter_.placeEntrust(e);
    if ret
        fprintf('entrust: %d, code: %s, direct: %d, offset: %d, price: %4.2f, amount: %d\n',...
            e.entrustNo,e.instrumentCode,e.direction,e.offsetFlag,e.price,e.volume);
        strategy.entrusts_.push(e);
        strategy.entrustspending_.push(e);
        strategy.updateportfoliowithentrust(e);
    end
    
end
%end of shortclosesigleinstrument