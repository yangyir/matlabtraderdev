classdef charlotteSignalGeneratorFX < handle
    events
        NewIndicatorGenerated
        NewSignalGenerated
        ErrorOccurred
    end
    
    properties
        codes_@cell
        signals_@cell
        extrainfo_@cell
        calcflag_@double
        printSignal_@logical
    end
    
    properties (Access = private)
        candles_@cell
        ticksize_@double
        freq_@cell
        kellytables_@cell
    end
    
    methods
        function obj = charlotteSignalGeneratorFX(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        [] = onNewData(obj,~,eventData)
        [] = setCalcFlag(obj,code,flag)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        [] = initCandles(obj)
        [signal,ei] = genSignal(obj,code,freq)
    end
end
    