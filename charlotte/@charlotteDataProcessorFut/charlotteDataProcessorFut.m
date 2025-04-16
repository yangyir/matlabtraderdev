classdef charlotteDataProcessorFut < handle
    properties
        codes_@cell
        ticks_@cell
        tickcounts_@double
    end
    
    properties (Access = private)
        candles_m1_@cell
        candles_m5_@cell
        candles_m15_@cell
        candles_m30_@cell
    end
    
    methods
        function obj = charlotteDataProcessorFut(codes)
            obj.codes_ = codes;
            ncodes = size(obj.codes_,1);
            obj.ticks_ = cell(ncodes,1);
            obj.tickcounts_ = zeros(ncodes,1);
            obj.candles_m1_ = cell(ncodes,1);
            obj.candles_m5_ = cell(ncodes,1);
            obj.candles_m15_ = cell(ncodes,1);
            obj.candles_m30_ = cell(ncodes,1);
        end
    end
    
    methods
        [] = onNewData(obj,~,eventData)        
    end
    
    methods
        k = getcandles(obj,code,freq)
    end
    
    methods (Access = private)
        [] = initcandles(obj,code)
        [] = updatecandles(obj,code)
    end
end