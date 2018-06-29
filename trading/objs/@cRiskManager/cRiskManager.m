classdef cRiskManager < handle
    properties
        name_@char
        trades_@cTradeOpenArray
    end
    
    methods
        function obj = cRiskManager(varargin)
            obj = init(obj,varargin{:});
        end
         
    end
    
    methods
        

        
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
    end
end