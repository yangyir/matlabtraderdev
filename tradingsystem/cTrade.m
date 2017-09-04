classdef cTrade
    %
    properties
        pTradeID
        pOrderID
        pInstrument
        pTraderID
        pDirection
        pOffsetFlag
        pPrice
        pVolume
        pTime       
    end
    
    methods (Access = public)
        function obj = cTrade(varargin)
            obj = init(obj,varargin{:});
        end
        
        function print(obj)
            try
                message = ['trade:',obj.pTradeID,' on ',datestr(obj.pTime,'yyyymmdd HH:MM:SS'),...
                    ' ',obj.pDirection,...
                    ' ',num2str(obj.pVolume),' lots of',...
                    ' ',obj.pInstrument.WindCode(1:end-4),...
                    ' at ',num2str(obj.pPrice),...
                    ' to ',obj.pOffsetFlag,' positions.\n'];
            catch
                message = ['trade:',obj.pTradeID,' on ',datestr(obj.pTime,'yyyymmdd HH:MM:SS'),...
                    ' ',obj.pDirection,...
                    ' ',num2str(obj.pVolume),' lots of',...
                    ' ',obj.pInstrument.BloombergCode,...
                    ' at ',num2str(obj.pPrice),...
                    ' to ',obj.pOffsetFlag,' positions.\n'];
            end
            fprintf(message);
        end
        
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Order',@(x)validateattributes(x,{'cOrder'},{},'','Order'));
            p.addParameter('VolumeTraded',@(x)validateattributes(x,{'numeric'},{},'','Order'));
            p.addParameter('TradeID',{},@(x)validateattributes(x,{'char','numeric'},{},'','TradeID'));
            p.addParameter('Time',{},@(x)validateattributes(x,{'char','numeric'},{},'','Time'));
            p.parse(varargin{:});
            
            order = p.Results.Order;
            if isempty(order)
                error('cTrade:order is required for booking a trade!');
            end
            obj.pVolume = p.Results.VolumeTraded;
            if isempty(obj.pVolume)
                error('cTrade:volume is missing!');
            end
            obj.pTradeID = p.Results.TradeID;
            obj.pTime = p.Results.Time;
            if isempty(obj.pTime)
                obj.pTime = now;
            end
            
            if isempty(obj.pTradeID)
                obj.pTradeID = order.pOrderID;
            end
            
            obj.pOrderID = order.pOrderID;
            obj.pInstrument = order.pInstrument;
            obj.pTraderID = order.pTraderID;
            obj.pDirection = order.pDirection;
            obj.pOffsetFlag = order.pOffsetFlag;
            obj.pPrice = order.pPrice;
            
        end
    end
end