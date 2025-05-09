classdef charlotteTraderFX < handle
    events
        OpenNewTrade
        CloseExistingTrade
        ErrorOccurred
    end
    
    properties
        dir_ = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Data\']
        book_@cTradeOpenArray
    end
    
    methods
        function obj = charlotteTraderFX()
            obj.book_ = cTradeOpenArray;
        end
    end
    
    methods
        [] = onNewSignal(obj,~,eventData)
        [] = onNewIndicator(obj,~,eventData)
        [] = onOpenNewTrade(obj,~,eventData)
        [] = onCloseExistingTrade(obj,~,eventData)
        %
        [ret,trade] = hasLongPosition(obj,code,varargin)
        [ret,trade] = hasShortPosition(obj,code,varargin)
        %
        
    end
    
    methods (Access = private)
        [] = writeTrade2File(obj,code)
        [] = manageRisk(obj,data)
    end
end