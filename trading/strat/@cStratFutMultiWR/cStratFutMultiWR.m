classdef cStratFutMultiWR < cStrat
    
    properties
        wr_@double                  %william%R
        maxnperiods_@double         %maximum price as of the previous candles exclude the latest one
        minnperiods_@double         %minimum price as of the previous candles exclude the latest one
    end
    
    methods
        function obj = cStratFutMultiWR
            obj.name_ = 'multiplewr';
        end
        %end of cStratFutMultiWR
        
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        [wr,wrts] = getlastwr(obj,instrument)
        [maxp,maxt,maxcandle] = getmaxnperiods(obj,instrument,varargin)
        [minp,mint.mincandle] = getminnperiods(obj,instrument,varargin)
        [] = printinfo(obj)
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_futmultiwr;
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_futmultiwr(signals)
        end
        %end of autoplacenewentrusts
        
        function [] = updategreeks(obj)
            obj.updategreeks_futmultiwr
        end
            
        function [] = riskmanagement(obj,dtnum)
            obj.riskmanagement_futmultiwr(dtnum)
        end
        
        function [] = initdata(obj)
            obj.initdata_futmultiwr;
        end
        %end of initdata
                
    end
    
    methods (Access = private)
        [] = riskmanagement_futmultiwr(obj,dtnum)
        [] = updategreeks_futmultiwr(obj)
        signals = gensignals_futmultiwr(obj)
        [] = autoplacenewentrusts_futmultiwr(obj,signals)
        [] = initdata_futmultiwr(obj)
    end

    
end

