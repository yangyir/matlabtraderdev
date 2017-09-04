classdef cWindDB < handle
    
    properties
        pConnection@windmatlab
        pContracts
    end
    
    methods (Access = public)
        %
        function obj = cWindDB(varargin)
            obj = init(obj,varargin{:});
        end
        
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
            if ~isa(obj.pConnection,'windmatlab') || isempty(obj.pConnection)
                obj.pConnection = windmatlab;
                if obj.pConnection.isconnected
                    fprintf('Wind connection succeed!\n');
                end
            end
        end
    end
    
end

