classdef cStratConfigFractalOpt < cStratConfig
    %class cStratConfigFractalOpt
    %used in trading with cStratOptMultiFractal
    
    properties (GetAccess = public, SetAccess = public)
        %default values
        tdsqlag_@double = 4
        tdsqconsecutive_@double = 9
        nfractals_@double = 2
        includelastcandle_@double = 0
        usefractalupdate_@double = 1
        usefibonacci_@double = 1
        %
        underliercodectp_@char
        
    end
    
    methods
        function obj = cStratConfigFractalOpt(varargin)
            obj = obj@cStratConfig(varargin{:});
            obj.setname('cStratConfigFractal');
        end
        
        function [] = loadfromfile(obj,varargin)
            loadfromfile@cStratConfig(obj,varargin{:});
            
            [optflag,~,~,underlierstr,~] = isoptchar(obj.codectp_);
            if ~optflag
                obj.underliercodectp_ = obj.codectp_;
            else
                obj.underliercodectp_ = underlierstr;
            end
        end
    end
end