function [ret,e] = longopensingleinstrument(strategy,ctp_code,lots,spread)
    if lots == 0
        return
    end

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
    instrument.loadinfo([ctp_code,'_info.txt']);
    
    [bool, idx] = strategy.instruments_.hasinstrument(instrument);
    if ~bool
        fprintf('cStrat:longopensingleinstrument:%s not registered in strategy\n',ctp_code)
        return; 
    end
    %only place entrusts in case the instrument has been registered
    %with the strategy
    
    if isopt
        q = strategy.mde_opt_.qms_.getquote(ctp_code);
    else
        q = strategy.mde_fut_.qms_.getquote(ctp_code);
    end
    
    if nargin < 4
        price = q.ask1 - strategy.askspread_(idx)*instrument.tick_size;
    else
        price = q.ask1 - spread*instrument.tick_size;
    end
    
    [ret,e] = strategy.trader_.placeorder(ctp_code,'b','o',price,lots,strategy.helper_);
    if ret
        strategy.updatestratwithentrust(e);
    end
    
end
%end of longopensigleinstrument