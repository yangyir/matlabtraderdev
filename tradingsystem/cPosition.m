classdef cPosition
    properties
%         pTradeID
        pInstrument
        pTraderID
        pDirection
        pPrice
        pVolume
        pTime
    end
    
    methods (Access = public)
        function obj = cPosition(varargin)
            obj = init(obj,varargin{:});
        end
        
        function print(obj)
            if strcmpi(obj.pDirection,'buy')
                direction = 1;
            elseif strcmpi(obj.pDirection,'sell')
                direction = -1;
            else
                direction = 0;
            end
            try
                message = ['\tposition:',...
                    obj.pInstrument.WindCode(1:end-4),...
                    ' ',num2str(direction*obj.pVolume),' lots at',...
                    ' ',num2str(round(obj.pPrice,2)),'.\n'];
                fprintf(message);
            catch
                message = ['\tposition:',...
                    obj.pInstrument.BloombergCode,...
                    ' ',num2str(direction*obj.pVolume),' lots at',...
                    ' ',num2str(round(obj.pPrice,2)),'.\n'];
                fprintf(message);
            end
        end
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Trade',{},@(x)validateattributes(x,{'cTrade'},{},'','Trade'));
            p.parse(varargin{:});
            trade = p.Results.Trade;
            
            if isempty(trade)
                error('cPosition:a trade object is required!');
            end
            
            if strcmpi(trade.pOffsetFlag, 'open')
%                 obj.pTradeID = trade.pTradeID;
                obj.pInstrument = trade.pInstrument;
                obj.pTraderID = trade.pTraderID;
                obj.pDirection = trade.pDirection;
                obj.pPrice = trade.pPrice;
                obj.pVolume = trade.pVolume;
                obj.pTime = trade.pTime;
            end
        end
    end
end