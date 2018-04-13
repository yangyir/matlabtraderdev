function [] = addstrat(obj,strat)
%cTrader
    if ~isa(strat,'cStrat'), error('cTrader:invalid strat input'); end
    
    n = size(obj.strats_,1);
    strats = cell(n+1,1);
    for i = 1:n, strats{i} = obj.strats_{i}; end
    strats{n+1} = strat;
    obj.strats_ = strats;
end