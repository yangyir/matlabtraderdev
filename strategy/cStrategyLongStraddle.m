%
% --- synthetic long straddle strategy -----
% variable inputs:
% ->reference spot(scalar)
% ->strikes(vector), e.g. can be absolute values or relative values of the
% reference spot
% ->valuation date(scalar or string)
% ->synthetic option expiry dates (vector), i.e. the size of the option
% expiry dates shall be the same as the strikes
% ->anualized volatility
% ->underlying futures contract
%
%

classdef cStrategyLongStraddle < cStrategy
    properties
    end
    
    methods
        function obj = cStrategyLongStraddle(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods (Access = public)
        
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('ReferenceSpot',
        end
    end
end