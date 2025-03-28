classdef cStratConfigFractal < cStratConfig
    %class cStratConfigFractal
    %used in trading with cStratFutMultiFractal
    
    properties (GetAccess = public, SetAccess = public)
        %default values
        tdsqlag_@double = 4
        tdsqconsecutive_@double = 9
        nfractals_@double = 2
        includelastcandle_@double = 0
        usefractalupdate_@double = 1
        usefibonacci_@double = 1
        kellylong_@double = 0.15
        kellyconditionallong_@double = 0.15
        
        
    end
    
    methods
        function obj = cStratConfigFractal(varargin)
            obj = obj@cStratConfig(varargin{:});
            obj.setname('cStratConfigFractal');
        end
        
        function [] = loadfromfile(obj,varargin)
            loadfromfile@cStratConfig(obj,varargin{:});
        end
    end
end