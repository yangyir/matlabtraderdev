classdef cPortfolio < handle
    properties
       portfolio_id = 'unknown'
       %
       pos_list@cell = {}
    end
    
    methods
        n = count(obj)
        [bool,idx] = hasposition(obj,instrument)
        [] = addposition(obj,instrument,px,volume,dtnum,closetoday)
        [] = overrideposition(obj,instrument,px,volume,dtnum)
        [] = removeposition(obj,instrument)
        pnl = runningpnl(obj,quotes)
        pnl = updateportfolio(obj,transaction)
        p = subportfolio(obj,instruments)
        [] = print(obj)
        [] = clear(obj)
        [] = setcostopen(obj,instrument,cost_open)

    end
        
    methods (Static = true)
        [] = demo(~)
    end
        
end