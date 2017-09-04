classdef cStrategyIntradayStraddle < cStrategy
    properties
    end
    
    properties (Access = private)
    end
    
    properties (GetAccess = public, SetAccess = private, Dependent)
    end
    
    methods
        %GET methods
    end
    
    methods
        function obj = cStrategyIntradayStraddle(varargin)
            obj = init(obj,varargin{:});
        end %end of constructor
    end
    
    methods (Access = public)
        function order = genorder(obj,varargin)
            p = inputParser;p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('UnderlierInfo',{},@(x)validateattributes(x,{'struct'},{},'UnderlierInfo'));
%             p.addParameter('UnderlierVol',{},@(x)validateattributes(x,{'cMarketVol'},{},'UnderlierVol'));
            p.addParameter('TradingPlatform',{},@(x)validateattributes(x,{'cTradingPlatform'},{},'TradingPlatform'));
            p.addParameter('LiquidityAdjustment',{},@(x)validateattributes(x,{'numeric'},{},'LiquidityAdjustment'));
            p.addParameter('MaximumSizePerOrder',{},@(x)validateattributes(x,{'numeric'},{},'MaximumSizePerOrder'));
            p.parse(varargin{:});
            underlierInfo = p.Results.UnderlierInfo;
            platform = p.Results.TradingPlatform;
            if isempty(platform)
                error('cStrategyIntradayStraddle:genorder:TradingPlatform required!')
            end
            
            liqadj = p.Results.LiquidityAdjustment;
            if isempty(liqadj)
                liqadj  = 0.0;
            end
            
            maxOrderSize = p.Results.MaximumSizePerOrder;
            if isempty(maxOrderSize)
                %by default we assume we can buy or sell any size of the
                %underlying futures
                maxOrderSize = inf;
            end
        end %end of function "genorder"
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
            p = inputParser;p.CaseSensitive = false;p.KeepUnmatched = true;
            
        end
    end
    
end