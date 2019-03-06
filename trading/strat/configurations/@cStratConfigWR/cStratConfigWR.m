classdef cStratConfigWR < cStratConfig
    %class cStratConfigWR
    %used in trading with cStratFutMultiWR
    
    properties (GetAccess = public, SetAccess = public)
        numofperiod_@double = 144
        overbought_@double = 0
        oversold_@double = -100
        executiontype_@char = 'fixed'
        wrmode_@char = 'classic'
        includelastcandle_@double = 0
        wrmalead_@double = -9.99
        wrmalag_@double = -9.99       
    end
    
    methods
        function obj = cStratConfigWR(varargin)
            obj = obj@cStratConfig(varargin{:});
            obj.setname('cStratConfigWR');
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
        
        function [] = set.wrmode_(obj,val)
            if ~(strcmpi(val,'classic') || ...
                    strcmpi(val,'reverse') || ...
                    strcmpi(val,'flash') || ...
                    strcmpi(val,'flashma') || ...
                    strcmpi(val,'follow') || ...
                    strcmpi(val,'all'))
                error([class(obj),':invalid wrmode_'])
            end
            obj.wrmode_ = val;
        end
        
        function [] = loadfromfile(obj,varargin)
            loadfromfile@cStratConfig(obj,varargin{:});
        end
        
    end
    
end