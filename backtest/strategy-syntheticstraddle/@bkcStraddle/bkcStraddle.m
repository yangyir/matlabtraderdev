classdef bkcStraddle < bkcVanilla
    methods
        function obj = bkcStraddle(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods (Access = public)
        [] = valuation(obj,varargin)
        obj = init(obj,varargin)
    end
    
end