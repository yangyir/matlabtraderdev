function [] = riskmanagement_fx(mdefx,varargin)
%cMDEFX method
    ntrades = mdefx.trades_fx_.latest_;
    for i = 1:ntrades
        trade_i = mdefx.trades_fx_.node_(i);
    end
    
end