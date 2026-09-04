classdef charlotteTraderFX < handle
    events
        OpenNewTrade
        CloseExistingTrade
        ErrorOccurred
    end
    
    properties
        codes_
        freqs_ % trade signal frequency
        book_
        pendingbook_
        specialbook_
        
    end
    
    properties (Access = private)
        dir_ = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Data\']
        signals_
        ei_signal_
        kellytables_m15_
        kellytables_m30_
        kellytables_h1_
        kellytables_h4_
    end
    
    methods
        function obj = charlotteTraderFX(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        [] = OnNewSignal(obj,~,eventData)
%         [] = onNewIndicator(obj,~,eventData)
        [] = OnNewBar_M15(obj,~,eventData)
        [] = OnNewBar_M30(obj,~,eventData)
        [] = OnNewBar_H1(obj,~,eventData)
        [] = OnNewBar_H4(obj,~,eventData)
        
        [] = onOpenNewTrade(obj,~,eventData)
        [] = onCloseExistingTrade(obj,~,eventData)
        %
        [ret,trade] = hasLongPosition(obj,code,freq,varargin)
        [ret,trade] = hasShortPosition(obj,code,freq,varargin)
        %
        [trade] = genSpecialTrade(obj,condsignal,eisignal,pxspecial,ordertype)
        [ret,trade] = hasSpecialTrade(obj,condsignal,eisignal)
        %
        [] = showMeTheBook(obj)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        [] = manageRisk(obj,data)
        [] = updatePendingBook(obj,data)
    end
end