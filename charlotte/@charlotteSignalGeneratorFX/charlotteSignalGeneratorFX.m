classdef charlotteSignalGeneratorFX < handle
    events
        ErrorOccurred
        NewSignalGenerated
    end
    
    properties
        codes_
        freqs_
        signals_
        extrainfo_
        calcflag_
        printSignal_
    end
    
    properties (Access = private)
        ticksize_
        kellytables_m15_
        kellytables_m30_
        kellytables_h1_
        kellytables_h4_
        %
    end
    
    methods
        function obj = charlotteSignalGeneratorFX(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        [] = OnNewCandle_M15(obj,~,eventData)
        [] = OnNewCandle_H30(obj,~,eventData)
        [] = OnNewCandle_H1(obj,~,eventData)
        [] = OnNewCandle_H4(obj,~,eventData)
        [] = setCalcFlag(obj,code,flag)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        [signal,ei] = genSignal(obj,code,freq,mode)
    end
end
    