function pnl = getpnlrunning(strategy,instrument)
%cStrat
    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, error('cStrat:getpnlrunning:instrument not found');end
    pnl = strategy.pnl_running_(idx);

end
%getpnlclose