classdef cFractalInfo < cSignalInfo
    properties
        type_@char = 'unset'
        mode_@char = 'unset'
        nfractal_@double
        hh_@double
        ll_@double
        hh1_@double
        ll1_@double
    end
    
    methods
        function obj = cFractalInfo
            obj.name_ = 'fractal';
        end
        
        function [] = set.type_(obj,val)
            if strcmpi(val,'unset') || ...
                    strcmpi(val,'breachup-B') || ...
                    strcmpi(val,'reverse-B') || ...
                    strcmpi(val,'breachdn-S') || ...
                    strcmpi(val,'reverse-S')
                obj.type_ = val;
            else
                error('cFractalInfo:invalid type input')
            end 
        end
        %
        function [] = set.mode_(obj,val)
            if strcmpi(val,'unset') || ...
                    strcmpi(val,'breachup-lvlup') || ...
                    strcmpi(val,'breachup-lvldn') || ...
                    strcmpi(val,'breachdn-lvldn') || ...
                    strcmpi(val,'breachdn-lvlup') || ...
                    strcmpi(val,'breachup-highsc13')
                obj.mode_ = val;
            else
                error('cFractalInfo:invalid mode input')
            end     
        end
        
    end
end