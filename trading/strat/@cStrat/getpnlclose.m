function pnl = getpnlclose(strategy,instrument)
%cStrat
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getpnlclose:instrument not found');end
    pnl = strategy.pnl_close_(idx);

end
%getpnlclose