classdef bkcStraddle < handle
    properties
        id_@double
        code_@char
        strike_@double
        opendt1_@double
        expirydt1_@double
        tradedts_@double
        pvs_@double
        deltas_@double
        S_@double
        thetapnl_@double
        deltapnl_@double
        % note: status_ is a 0,1 vector in which 1 indicates live and 0
        % indicator expired or early-unwinded
        status_@double
    end
    
    properties (Dependent = true, SetAccess = private, GetAccess = public)
        opendt2_@char
        expirydt2_@char
    end
    
    methods
        function obj = bkcStraddle(varargin)
            obj = init(obj,varargin{:});
        end
        %
        function opendt2 = get.opendt2_(obj)
            if isempty(obj.opendt1_)
                opendt2 = '';
            else
                opendt2 = datestr(obj.opendt1_,'yyyy-mm-dd');
            end
        end
        %
        function expirydt2 = get.expirydt2_(obj)
            if isempty(obj.expirydt1_)
                expirydt2 = '';
            else
                expirydt2 = datestr(obj.expirydt1_,'yyyy-mm-dd');
            end 
        end
    end
    
    methods (Access = public)
        [] = valuation(obj,varargin)
        [] = plotpv(obj)
        outputs = stats(obj)  
        [idxunwind,unwinddt] = unwindinfo(obj,varargin)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)    
    end
end