function [] = updatestratwithentrust(strategy,e)
    if isempty(strategy.counter_), return; end
    if ~isa(e,'Entrust'), return; end

    if strcmpi(strategy.mode_,'realtime')
        f0 = strategy.counter_.queryEntrust(e);
        f1 = e.is_entrust_closed;
        f2 = e.dealVolume > 0;
    elseif strcmpi(strategy.mode_,'replay')
        f0 = true;
        %note:to be implemented
        f1 = true;
        f2 = f1;
    end
    [f3,idx] = strategy.instruments_.hasinstrument(e.instrumentCode);
    if f0&&f1&&f2&&f3
        instrument = strategy.instruments_.getinstrument{idx};
        if isa(instrument,'cFutures')
            bucketnum = strategy.mde_fut_.getcandlecount(instrument);
            if strategy.executionbucketnumber_(idx) ~= bucketnum;
                strategy.executionbucketnumber_(idx) = bucketnum;
                strategy.executionperbucket_(idx) = 1;
            else
                strategy.executionperbucket_(idx) = strategy.executionperbucket_(idx)+1;
            end 
        end
    end
    
end
%end of updateportfoliowithentrust