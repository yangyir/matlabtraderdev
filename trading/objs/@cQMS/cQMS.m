classdef cQMS < handle
    %class of quotes management system (QMS)
    properties
        instruments_@cInstrumentArray
        watcher_@cWatcher
    end
    
    methods
        
        flag = isconnect(obj)
        [] = setdatasource(self,connstr)
        [] = registerinstrument(self,instrument)
        [] = removeinstrument(self,instrument)
        [] = refresh(self,timestr)
        quote = getquote(self,instrument)
        
    end
    
end