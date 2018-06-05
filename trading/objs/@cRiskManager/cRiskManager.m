classdef cRiskManager < handle
    properties
        name_@char
        method_@char
        
    end
    
    methods
        function set.method_(obj,method)
            if strcmpi(method,'standard') || strcmpi(method,'batman')
                obj.method_ = method;
            else
                error('cRiskManager:invalid method')
            end
        end
        
    end
    
    methods
        function obj = cRiskManager(varargin)
            obj = init(obj,varargin{:});
        end
        
        
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
    end
end