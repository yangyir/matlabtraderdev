classdef charlotteDataProcessorFut < handle
    events
        NewBarSetM1
        NewBarSetM5
        NewBarSetM15
        NewBarSetM30
    end
    
    properties
        codes_@cell
        ticks_@cell
        tickcounts_@double
    end
    
    properties (Access = private)
        candles_m1_@cell
        candles_m1_count_@double
        newset_m1_@double
        candles_m5_@cell
        candles_m5_count_@double
        newset_m5_@double
        candles_m15_@cell
        candles_m15_count_@double
        newset_m15_@double
        candles_m30_@cell
        candles_m30_count_@double
        newset_m30_@double
        %
        fut_categories_@double
        datenum_open_@cell
        datenum_close_@cell
        %
        num21_00_00_@double
        num21_00_0_5_@double
        num00_00_00_@double
        num00_00_0_5_@double
    end
    
    methods
        function obj = charlotteDataProcessorFut(codes)
            obj.codes_ = codes;
            ncodes = size(obj.codes_,1);
            obj.ticks_ = cell(ncodes,1);
            obj.tickcounts_ = zeros(ncodes,1);
            obj.candles_m1_ = cell(ncodes,1);
            obj.candles_m1_count_ = zeros(ncodes,1);
            obj.newset_m1_ = zeros(ncodes,1);
            obj.candles_m5_ = cell(ncodes,1);
            obj.candles_m5_count_ = zeros(ncodes,1);
            obj.newset_m5_ = zeros(ncodes,1);
            obj.candles_m15_ = cell(ncodes,1);
            obj.candles_m15_count_ = zeros(ncodes,1);
            obj.newset_m15_ = zeros(ncodes,1);
            obj.candles_m30_ = cell(ncodes,1);
            obj.candles_m30_count_ = zeros(ncodes,1);
            obj.newset_m30_ = zeros(ncodes,1);
            obj.fut_categories_ = zeros(ncodes,1);
            obj.datenum_open_ = cell(ncodes,1);
            obj.datenum_close_ = cell(ncodes,1);
            %
            obj.initcandles;
        end
    end
    
    methods
        [] = onNewData(obj,~,eventData)
        [] = onMarketClose(obj,~,eventData)
        [] = onMarketOpen(obj,~,eventData)
        [] = onNewBarSetM1(obj,~,eventData)
        [] = onNewBarSetM5(obj,~,eventData)
        [] = onNewBarSetM15(obj,~,eventData)
        [] = onNewBarSetM30(obj,~,eventData)
    end
    
    methods
        k = getcandles(obj,code,freq)
    end
    
    methods (Access = private)
        [] = initcandles(obj)
        [] = updatecandles(obj)
    end
end