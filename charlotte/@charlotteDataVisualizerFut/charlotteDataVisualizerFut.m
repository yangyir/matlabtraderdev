classdef charlotteDataVisualizerFut < handle
    properties
        codes_@cell
        candles_m1_@cell
        candles_m5_@cell
        candles_m15_@cell
        candles_m30_@cell
    end
    
    methods
        function obj = charlotteDataVisualizerFut(codes)
            obj.codes_ = codes;
            ncodes = size(obj.codes_,1);
            obj.candles_m1_ = cell(ncodes,1);
            obj.candles_m5_ = cell(ncodes,1);
            obj.candles_m15_ = cell(ncodes,1);
            obj.candles_m30_ = cell(ncodes,1);
            %here historical data shall be loaded
        end
    end
    
    methods
        [] = onNewBarSetM1(obj,~,eventData)
        [] = onNewBarSetM5(obj,~,eventData)
        [] = onNewBarSetM15(obj,~,eventData)
        [] = onNewBarSetM30(obj,~,eventData)
    end
end