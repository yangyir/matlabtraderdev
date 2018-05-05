function [] = riskmanagement_futbatman(obj,dtnum)
%cStratFutBatman
    if isempty(obj.counter_) && strcmpi(obj.mode_,'realtime'), return;end
    
    instruments = obj.instruments_.getinstrument;
    for i = 1:obj.count
        %firstly to check whether this is in trading hours
        ismarketopen = istrading(dtnum,instruments{i}.trading_hours,...
            'tradingbreak',instruments{i}.trading_break);
        if ~ismarketopen, continue; end
        
        %secondly to check whether the instrument has been traded
        isinstrumenttraded = obj.bookrunning_.hasposition(instruments{i});
        if ~isinstrumenttraded, continue; end
        
        %calculate running pnl in case the instrument has been traded
        pnl = obj.helper_.calcrunningpnl('code',instruments{i}.code_ctp,'mdefut',obj.mde_fut_);
        obj.pnl_running_(i) = pnl;
        
        if strcmpi(obj.pnl_stop_type_{i},'rel')
            fprintf('batman:rel stop type is not implemented\n');
        else
            stop_ = obj.pnl_stop_(i);
        end
        if stop_ > 0, stop_ = -stop_;end
        
        if pnl <= stop_
            obj.unwindposition(instruments{i});
        end

        
    end

end