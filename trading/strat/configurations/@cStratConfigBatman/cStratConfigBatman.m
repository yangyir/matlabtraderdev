classdef cStratConfigBatman < cStratConfig
    %class cStratConfigWR
    %used in trading with cStratFutMultiBatman
    properties (GetAccess = public, SetAccess = public)
        bandwidthmin_@double = 1/3
        bandwidthmax_@double = 0.5
        bandstoploss_@double = 0.01
        bandtarget_@double = 0.01
        bandtype_@double = 0        %0:normal 1:option
    end
    
    methods
        function obj = cStratConfigBatman(varargin)
            obj = obj@cStratConfig(varargin{:});
            obj.setname('cStratConfigBatman');
        end
        
        function [] = loadfromfile(obj,varargin)
            loadfromfile@cStratConfig(obj,varargin{:});
        end
        
    end
    
    
end