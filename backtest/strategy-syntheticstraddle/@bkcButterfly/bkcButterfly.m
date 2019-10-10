classdef bkcButterfly < bkcVanilla
    methods
        function obj = bkcButterfly(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods (Access = public)
        [] = valuation(obj,varargin)
        obj = init(obj,varargin)
    end
    
end