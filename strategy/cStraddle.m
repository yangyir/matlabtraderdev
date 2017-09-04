classdef cStraddle
    properties
        Underlier
        Strike
        ExpiryDate
        TradeDate
        Notional
%         RefSpot
    end
    
    properties (GetAccess = public, SetAccess = private, Dependent)
        TradingDays;
    end
    
    methods
        function tradingDays = get.TradingDays(obj)
            tradingDays = gendates('FromDate',obj.TradeDate,'ToDate',obj.ExpiryDate);
        end
    end
    
    methods
        function obj = cStraddle(varargin)
            obj = init(obj,varargin{:});
        end %end of constructor
        
        function flag = isequal(obj,straddle)
%             if isa(obj.Underlier,'cContract') && isa(straddle.Underlier,'cContract')
                sameUnderlier = strcmpi(obj.Underlier.BloombergCode,straddle.Underlier.BloombergCode);
%             elseif isa(obj.Underlier,'cContract') && ischar(straddle.Underlier)
%                 sameUnderlier = strcmpi(obj.Underlier.BloombergCode,straddle.Underlier);
%             elseif ischar(obj.Underlier) && ischar(straddle.Underlier)
%                 sameUnderlier = strcmpi(obj.Underlier,straddle.Underlier);
%             elseif ischar(obj.Underlier) && isa(straddle.Underlier,'cContract')
%                 sameUnderlier = strcmpi(obj.Underlier,straddle.Underlier.BloombergCode);
%             else
%                 sameUnderlier = false;
%             end
          
            if sameUnderlier &&...
                    obj.Strike == straddle.Strike &&...
                    datenum(obj.ExpiryDate) == datenum(straddle.ExpiryDate) &&...
                    datenum(obj.TradeDate) == datenum(straddle.TradeDate)
                flag = true;
            else
                flag = false;
            end
        end
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Underlier',{},@(x)validateattributes(x,{'cContract','struct'},{},'','Underlier'));
            p.addParameter('Strike',{},@(x)validateattributes(x,{'numeric'},{},'','Strike'));
            p.addParameter('ExpiryDate',{},@(x)validateattributes(x,{'numeric','char'},{},'','ExpiryDate'));
            p.addParameter('TradeDate',{},@(x)validateattributes(x,{'numeric','char'},{},'','TradeDate'));
            p.addParameter('Notional',{},@(x)validateattributes(x,{'numeric'},{},'','Notional'));
%             p.addParameter('RefSpot',{},@(x)validateattributes(x,{'numeric'},{},'','RefSpot'));
            p.parse(varargin{:});
            underlier = p.Results.Underlier;
            if isempty(underlier)
                error('cStraddle:init:invalid input of Underlier')
            end
            strike = p.Results.Strike;
            if isempty(strike)
                error('cStraddle:init:invalid input of Strike')
            end
            expiryDate = p.Results.ExpiryDate;
            if isempty(expiryDate)
                error('cStraddle:init:invalid input of ExpiryDate')
            end
            tradeDate = p.Results.TradeDate;
            if isempty(tradeDate)
                error('cStraddle:init:invalid input of TradeDate')
            end
            notional = p.Results.Notional;
            if isempty(notional)
                error('cStraddle:init:invalid input of Notional')
            end
%             refspot = p.Results.RefSpot;
%             if isempty(refspot)
%                 error('cStraddle:init:invalid input of RefSpot')
%             end
            
            obj.Underlier = underlier;
            obj.Strike = strike;
            obj.ExpiryDate = expiryDate;
            obj.TradeDate = tradeDate;
            obj.Notional = notional;
%             obj.RefSpot = refSpot;
            
        end
    end
end