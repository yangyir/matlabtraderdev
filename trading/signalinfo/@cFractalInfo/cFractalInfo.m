classdef cFractalInfo < cSignalInfo
    properties
        type_@char = 'unset'
        hh_@double
        ll_@double
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
    end
end