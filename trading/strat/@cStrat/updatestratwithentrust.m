function [] = updatestratwithentrust(strategy,e)
%note:TODO:we shall move this function to cOps as it is more like an ops'
%behavior
    if isempty(strategy.helper_), return; end
    counter = strategy.helper_.getcounter;
    if isempty(counter), return; end
    if ~isa(e,'Entrust'), return; end

    if strcmpi(strategy.mode_,'realtime')
        %f0 checks whether the entrust is placed or not
        f0 = counter.queryEntrust(e);
        %f1 checks whether the entrust is executed or is canceld
        f1 = e.is_entrust_closed;
        %f2 checks whether the entrust is executed or partially executed
        f2 = e.dealVolume > 0;
    elseif strcmpi(strategy.mode_,'replay')
        %we assume the entrust is always placed in replay mode
        f0 = true;
        f1 = e.is_entrust_closed;
        f2 = f1 & e.cancelVolume == 0;
    end
    [f3,idx] = strategy.instruments_.hasinstrument(e.instrumentCode);
    %note:yangyiran:20180907
    %only executed entrust with open orders as close orders are for
    %risk-management or profit taking purposes
    f4 = e.offsetFlag == 1;
    
    if f0&&f1&&f2&&f3&&f4
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