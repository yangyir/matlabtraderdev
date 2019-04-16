function [signals] = gensignals_futpaircointegration(strategy)
%cStratFutPairCointegration
    instruments = strategy.getinstruments;
    
    try
        calcsignalflag1 = strategy.getcalcsignalflag(instruments{1});
    catch e
        calcsignalflag1 = 0;
        msg = ['ERROR:%s:getcalcsignalflag:',class(strategy),e.message,'\n'];
        fprintf(msg);
        if strcmpi(strategy.onerror_,'stop'), strategy.stop; end
    end
    %
    try
        calcsignalflag2 = strategy.getcalcsignalflag(instruments{2});
    catch e
        calcsignalflag2 = 0;
        msg = ['ERROR:%s:getcalcsignalflag:',class(strategy),e.message,'\n'];
        fprintf(msg);
        if strcmpi(strategy.onerror_,'stop'), strategy.stop; end
    end
    
    calcsignalflag = calcsignalflag1 || calcsignalflag2;
    if ~calcsignalflag
        signals = {};
        return
    end
    
    %update obj data
    strategy.updatapairdata;
    % check whether rebalancing is required
    M = strategy.lookbackperiod_;
    N = strategy.rebalanceperiod_;
    count = size(strategy.data_,1);
    doRebalance = mod(count-M,N) == 0;
    if doRebalance
        fprintf('rebalancing...\n');
        [h,~,~,~,reg1] = egcitest(strategy.data_(end-M+1:end,2:3));
        if h ~= 0
            strategy.cointegrationparams_ = reg1;
        else
            strategy.cointegrationparams_ = {};
        end
    end
    
    if isempty(strategy.cointegrationparams_)
        signals = {};
        return
    end
    
    lasttick1 = strategy.mde_fut_.getlasttick(instruments{1});
    lasttick2 = strategy.mde_fut_.getlasttick(instruments{2});
    if isempty(lasttick1) || isempty(lasttick2)
        signals = {};
        return
    end
    
    params = strategy.cointegrationparams_;
    check = lasttick1(4) - (params.coeff(1) + params.coeff(2) * lasttick2(4));
    check = check / params.RMSE;
    
    if check > strategy.upperbound_
        fprintf('5y overbought:sell 5y at %s and buy 10y at %s\n',num2str(lasttick1(4)),num2str(lasttick2(4)))
    elseif check < strategy.lowerbound_
        fprintf('5y oversold:buy 5y at %s and sell 10y at %s\n',num2str(lasttick1(4)),num2str(lasttick2(4)))
    else
        fprintf('%4.1f\n',check);
    end
    
    signals = {};
        
end

