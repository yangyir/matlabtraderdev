classdef cPortfolio < handle
    properties
       portfolio_id = 'unknown'
       instrument_list@cell = {}
       instrument_avgcost@double = []
       instrument_volume@double = []
       instrument_volume_today@double = []
       %
       pos_list_@cell = {}
    end
    
    methods
        n = count(obj)
        [bool,idx] = hasinstrument(obj,instrument)
        [] = addinstrument(obj,instrument,px,volume,dtnum,closetoday)
        [] = updateinstrument(obj,instrument,px,volume)
        [] = removeinstrument(obj,instrument)
        pnl = runningpnl(obj,quotes)
        pnl = updateportfolio(obj,transaction)
        p = subportfolio(obj,instruments)
        [] = print(obj)
        [] = clear(obj)

    end
        
    methods (Static = true)
        [] = demo(~)
    end
        
end