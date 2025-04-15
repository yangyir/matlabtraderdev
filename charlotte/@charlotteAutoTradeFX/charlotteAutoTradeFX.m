classdef charlotteAutoTradeFX < handle
    events
        ErrorOccurred
    end
    
    properties
        codes_@cell
        candles_@cell
    end
    
    properties (Access = private)
        ticksize_@double
        signals_@cell
        trades_@cell
        freq_@cell
        kellytables_@cell
    end
    
    methods
        function obj = charlotteAutoTradeFX()
            obj.codes_ = charlotte_select_fx_pairs;
            ncodes = size(obj.codes_,1);
            obj.candles_ = cell(ncodes,1);
            obj.ticksize_ = zeros(ncodes,1);
            obj.signals_ = cell(ncodes,2);
            obj.trades_ = cell(ncodes,1);
            obj.freq_ = cell(ncodes,1);
            obj.kellytables_ = cell(ncodes,1);
            for i = 1:ncodes
                fx_i = code2instrument(obj.codes_{i});
                obj.ticksize_(i) = fx_i.tick_size;
            end
%             try
%                 initCandles(obj);
%             catch ME
%                 notify(obj, 'ErrorOccurred', ...
%                     charlotteErrorEventData(ME.message));
%             end   
        end
        
    end
    
    methods
        [] = onNewData(obj,~,eventData)
        signal = getSignal(obj,code)
        trades = getTrades(obj,code)
        
    end
    
    methods (Access = private)
        [] = initCandles(obj)
        [] = genSignal(obj,code)
        [] = updateTrades(obj,code)
    end
end
    