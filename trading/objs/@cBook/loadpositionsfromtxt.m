function [] = loadpositionsfromtxt(obj,fn)
    trades = cTradeOpenArray;
    trades.fromtxt(fn);
    %sanity check 1: make sure the same 
    
    
    
    livetrades = trades.filterbystatus('set');
    positions = livetrades.convert2positions;
    obj.positions_ = positions;


end