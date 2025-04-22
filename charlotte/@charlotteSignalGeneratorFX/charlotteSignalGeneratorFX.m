classdef charlotteSignalGeneratorFX < handle
    events
        NewSignalGenerated
        ErrorOccurred
    end
    
    properties
        codes_@cell
        candles_@cell
        signals_@cell
    end
    
    properties (Access = private)
        ticksize_@double
        freq_@cell
        kellytables_@cell
    end
    
    methods
        function obj = charlotteSignalGeneratorFX()
            obj.codes_ = charlotte_select_fx_pairs;
            ncodes = size(obj.codes_,1);
            obj.candles_ = cell(ncodes,1);
            obj.ticksize_ = zeros(ncodes,1);
            obj.signals_ = cell(ncodes,1);
            obj.freq_ = cell(ncodes,1);
            obj.kellytables_ = cell(ncodes,1);
            for i = 1:ncodes
                fx_i = code2instrument(obj.codes_{i});
                obj.ticksize_(i) = fx_i.tick_size;
            end  
        end
        
    end
    
    methods
        [] = onNewData(obj,~,eventData)
    end
    
    methods (Access = private)
        [] = initCandles(obj)
        [signal] = genSignal(obj,code)
    end
end
    