classdef charlotteDataProcessorFX < handle
    events
        ErrorOccurred
    end
    
    properties
        codes_@cell
        candles_@cell
    end
    
    properties (Access = private)
        signals_@cell
        trades_@cell
    end
    
    methods
        function obj = charlotteDataProcessorFX()
            obj.codes_ = charlotte_select_fx_pairs;
            ncodes = size(obj.codes_,1);
            obj.signals_ = cell(ncodes,2);
            obj.trades_ = cell(ncodes,1);
            
            try
                initCandles(obj);
            catch ME
                notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData(ME.message));
            end
            
        end
        
    end
    
    methods
        [] = onNewData(obj,~,eventData)
        signal = getSignal(obj,code)
        trade = getTrade(obj,code)
        
    end
    
    methods (Access = private)
        [] = initCandles(obj)
        [] = generateSignal(obj,code)
        [] = updateTrade(obj,code)
    end
end
    