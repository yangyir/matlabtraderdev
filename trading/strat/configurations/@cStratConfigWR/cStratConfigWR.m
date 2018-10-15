classdef cStratConfigWR < cStratConfig
    %class cStratConfigWR
    %used in trading with cStratFutMultiWR
    
    properties (GetAccess = public, SetAccess = private)
        numofperiod_@double = 144
        overbought_@double = 0
        oversold_@double = -100
        executiontype_@char = 'fixed'
        
    end
    
    methods
        function obj = cStratConfigWR(varargin)
            obj = obj@cStratConfig(varargin{:});
        end
        
        function [] = set.executiontype_(obj,val)
            if ~(strcmpi(val,'fixed') || strcmpi(val,'martingale'))
                error([class(obj),':invalid executiontype_'])
            end
            obj.executiontype_ = val;
        end
        
        function [] = set.oversold_(obj,val)
            if val < -100 || val > 0
                error([class(obj),':invalid oversold_'])
            end
            obj.oversold_ = val;
        end
        
        function [] = set.overbought_(obj,val)
            if val < -100 || val > 0
                error([class(obj),':invalid overbought_'])
            end
            obj.overbought_ = val;
        end
        
    end
    
    
end