classdef cStrategy
    %base class of strategy class
    properties
        StrategyID = 'unknown'
        InitialBalance = []
        MaxMarginRatio = []
        StopLossRatio = []
        Instruments = {}
    end
    
    
    methods (Access = public)
        function obj = registerinstruments(obj,instruments)
            if iscell(instruments)
                for i = 1:length(instruments)
                    obj = registerinstrument(obj,instruments{i});
                end
            elseif isa(instruments,'cContract') || isstruct(instruments)
                obj = registerinstrument(obj,instruments);
            else
                error('cStrategy:registerinstruments:invalid input of instruments')
            end
        end
        %end of 'registerinstruments'
        
        function obj = removeinstruments(obj,instruments)
            if iscell(instruments)
                for i = 1:length(instruments)
                    obj = removeinstrument(obj,instruments{i});
                end
            elseif isa(instruments,'cContract') || isstruct(instruments)
                obj = removeinstrument(obj,instruments);
            else
                error('cStrategy:removeinstruments:invalid input of instruments')
            end
        end
        %end of 'removeinstruments'
    
    end
    
    methods (Access = private)
        function obj = registerinstrument(obj,instrument)
            if isa(instrument,'cContract') || isstruct(instrument)
                %only register with a different instrument
                for i = 1:length(obj.Instruments)
                    if strcmpi(obj.Instruments{i}.BloombergCode,instrument.BloombergCode)
                        return
                    end
                end
                n = length(obj.Instruments)+1;
                instruments = cell(n,1);
                instruments(1:n-1,1) = obj.Instruments;
                instruments{n,1} = instrument;
                obj.Instruments = instruments;            
            else
                error('cStrategy:registerinstruments:invalid input of instruments')
            end
        end
        %end of 'registerinstrument'
        
        function obj = removeinstrument(obj,instrument)
            if isa(instrument,'cContract') || isstruct(instrument)
                idx = 0;
                for i = 1:length(obj.Instruments)
                    if strcmpi(obj.Instruments{i}.BloombergCode,instrument.BloombergCode)
                        idx = i;
                        break
                    end
                end
                if idx > 0
                    n = length(obj.Instruments)-1;
                    if n == 0
                        obj.Instruments = {};
                    else
                        instruments = cell(n,1);
                        instruments(1:idx-1,1) = obj.Instruments(1:idx-1,1);
                        instruments(idx:end,1) = obj.Instruments(idx+1:end,1);
                        obj.Instruments = instruments;
                    end
                end
            else
                error('cStrategy:removeinstruments:invalid input of instruments')
            end
        end
        %end of 'removeinstrument'
        
    end
    
end

