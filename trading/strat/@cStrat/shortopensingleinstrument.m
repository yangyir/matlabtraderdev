function [ret,e] = shortopensingleinstrument(strategy,ctp_code,lots,spread)
    if lots <= 0 
        return; 
    end
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
    instrument.loadinfo([ctp_code,'_info.txt']);
    multi = instrument.contract_size;
    if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
        multi = multi/100;
    end
    
    [bool, idx] = strategy.instruments_.hasinstrument(instrument);
    if ~bool
        fprintf('cStrat:shortopensingleinstrument:%s not registered in strategy\n',ctp_code)
        return; 
    end
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
    
    if nargin < 4
        orderprice = q.bid1 + strategy.bidspread_(idx)*instrument.tick_size;
    else
        orderprice = q.bid1 + spread*instrument.tick_size;
    end
    e.fillEntrust(1,ctp_code,direction,orderprice,lots,offset,ctp_code);
    if ~isopt, e.assetType = 'Future'; end
    e.multiplier = multi;
    
    ret = strategy.counter_.placeEntrust(e);
    if ret
        %the entrust is valid or alternatively the entrust has been placed
        fprintf('entrust: %d, code: %s, direct: %d, offset: %d, price: %4.2f, amount: %d\n',...
            e.entrustNo,e.instrumentCode,e.direction,e.offsetFlag,e.price,e.volume);
        strategy.entrusts_.push(e);
        %first we put the entrust into the pending entrust array
        %and we shall update the pending entrust array and the finished
        %entrust array once the entrust is finished
        strategy.entrustspending_.push(e);
        strategy.updateportfoliowithentrust(e); 
    end
    
end
%end of shortopensigleinstrument