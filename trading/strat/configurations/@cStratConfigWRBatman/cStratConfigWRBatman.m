classdef cStratConfigWRBatman < cStratConfigWR & cStratConfigBatman
    methods
        function obj = cStratConfigWRBatman(varargin)
            obj = obj@cStratConfigWR(varargin{:});
            obj.setname('cStratConfigWRBatman');
        end
        
        function [] = loadfromfile(obj,varargin)
            loadfromfile@cStratConfig(obj,varargin{:});
        end
        
    end
    
    
end