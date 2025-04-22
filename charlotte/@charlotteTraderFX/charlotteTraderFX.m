classdef charlotteTraderFX < handle
    events
        OpenNewTrade
        CloseExistingTrade
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
        onNewSignal(obj,~,eventData)
        onOpenNewTrade(obj,~,eventData)
        onCloseExistingTrade(obj,~,eventData)
        %
        [ret,trade] = hasLongPosition(obj,code)
        [ret,trade] = hasShortPosition(obj,code)
    end
    
    methods (Access = private)
        [] = writeTrade2File(obj,code)
    end
end