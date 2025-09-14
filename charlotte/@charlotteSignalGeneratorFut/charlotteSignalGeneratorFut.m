classdef charlotteSignalGeneratorFut < handle
    %
    events
        NewSignalGeneratedM1
        NewSignalGeneratedM5
        NewSignalGeneratedM15
        NewSignalGeneratedM30
        NewSignalGeneratedD1
        ErrorOccurred
    end
    
    properties
        codes_@cell
        mode_@char
        %
        signals_m1_@cell
        signals_m5_@cell
        signals_m15_@cell
        signals_m30_@cell
        signals_d1_@cell
        %
        ei_m1_@cell
        ei_m5_@cell
        ei_m15_@cell
        ei_m30_@cell
        ei_d1_@cell
        %
        kellytable_m1_@struct
        kellytable_m5_@struct
        kellytable_m15_@struct
        kellytable_m30_@struct
        kellytable_d1_@struct
        %
        feed_@charlotteDataFeedFut
        
    end
    
    properties (Access = private)
        candles_m1_@cell
        candles_m5_@cell
        candles_m15_@cell
        candles_m30_@cell
        candles_d1_@cell
        %
        ticksize_@double
    end
    
    methods
        function obj = charlotteSignalGeneratorFut(feed)
            if ~isa(feed,'charlotteDataFeedFut')
                error('%s:constructor requires a charlotteDataFeedFut instance...',class(obj))
            end
            obj.feed_ = feed;
            obj.codes_ = feed.codes_;
            obj.mode_ = feed.mode_;
            ncodes = size(obj.codes_,1);
            obj.signals_m1_ = cell(ncodes,1);
            obj.signals_m5_ = cell(ncodes,1);
            obj.signals_m15_ = cell(ncodes,1);
            obj.signals_m30_ = cell(ncodes,1);
            obj.signals_d1_ = cell(ncodes,1);
            obj.ei_m1_ = cell(ncodes,1);
            obj.ei_m5_ = cell(ncodes,1);
            obj.ei_m15_ = cell(ncodes,1);
            obj.ei_m30_ = cell(ncodes,1);
            obj.ei_d1_ = cell(ncodes,1);
            obj.candles_m1_ = cell(ncodes,1);
            obj.candles_m5_ = cell(ncodes,1);
            obj.candles_m15_ = cell(ncodes,1);
            obj.candles_m30_ = cell(ncodes,1);
            obj.candles_d1_ = cell(ncodes,1);
            obj.ticksize_ = zeros(ncodes,1);
            for i = 1:ncodes
                try
                    instr = code2instrument(obj.codes_{i});
                    obj.ticksize_(i) = instr.tick_size;
                catch
                    fprintf('%s:fails to initiate tick size on %s...\n',class(obj),obj.codes_{i});
                    obj.ticksize_(i) = 0;
                end
            end
        end
        %end of charlotteSignalGeneratorFut
    end
    
    methods
        [] = onNewBarSetM1(obj,~,eventData)
        [] = onNewBarSetM5(obj,~,eventData)
        [] = onNewBarSetM15(obj,~,eventData)
        [] = onNewBarSetM30(obj,~,eventData)
        [] = onNewBarSetD1(obj,~,eventData)
    end
    
    methods
        [] = loadHistoricalData(obj,varargin)
        [] = loadKellyTable(obj,varargin)
        [signal] = genSignal(obj,code,freq)
    end
    
    
    
    
end