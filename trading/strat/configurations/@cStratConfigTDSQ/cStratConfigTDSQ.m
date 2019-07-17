classdef cStratConfigTDSQ < cStratConfig
    %class cStratConfigTDSQ
    %used in trading with cStratFutMultiTDSQ
    
    properties (GetAccess = public, SetAccess = public)
        %default values
        wrnperiod_@double = 144
        wroverbought_@double = 0
        wroversold_@double = -100
        macdlead_@double = 6
        macdlag_@double = 12
        macdnavg_@double = 9
        tdsqlag_@double = 4
        tdsqconsecutive_@double = 9
        includelastcandle_@double = 0
    end
    
    methods
        function obj = cStratConfigTDSQ(varargin)
            obj = obj@cStratConfig(varargin{:});
            obj.setname('cStratConfigTDSQ');
        end
        
        function [] = set.wroverbought_(obj,val)
            if val < -100 || val > 0
                error([class(obj),':invalid wroverbought_'])
            end
            obj.wroverbought_ = val;
        end
        
        function [] = set.wroversold_(obj,val)
            if val < -100 || val > 0
                error([class(obj),':invalid wroversold_'])
            end
            obj.wroversold_ = val;
        end

        function [] = loadfromfile(obj,varargin)
            loadfromfile@cStratConfig(obj,varargin{:});
        end
    end
end