classdef cStratFutMultiWR < cStrat
    
    properties
        %strategy related 
        numofperiods_@double
        tradingfreq_@double
        overbought_@double
        oversold_@double
        wr_@double                  %william%R
        executionperbucket_@double
        maxexecutionperbucket_@double
        executionbucketnumber_@double
    end
    
    methods
        function obj = cStratFutMultiWR
            obj.name_ = 'multiplewr';
        end
        %end of cStratFutMultiWR
        
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        [] = setparameters(obj,instrument,params)
        [] = settradingfreq(obj,instrument,freq)
        [] = setboundary(obj,instrument,overbought,oversold)
        [wr,wrts] = getlastwr(obj,instrument)
        [] = printinfo(obj)
        [] = readparametersfromtxtfile(obj,fn_)
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

