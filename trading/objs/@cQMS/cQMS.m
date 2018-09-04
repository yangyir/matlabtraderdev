classdef cQMS < handle
    %class of quotes management system (QMS)
    properties
        instruments_@cInstrumentArray
        watcher_@cWatcher
    end
    
    methods
        function obj = cQMS(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        
        [ret] = ctplogin(obj,varargin)
        [ret] = ctplogoff(obj,varargin)
        flag = isconnect(obj)
        [] = setdatasource(self,connstr)
        [] = registerinstrument(self,instrument)
        [] = removeinstrument(self,instrument)
        [] = refresh(self,timestr)
        quote = getquote(self,instrument)
        
    end
    
    methods (Access = private)
        [obj] = init(obj,varargin)
    end
    
end