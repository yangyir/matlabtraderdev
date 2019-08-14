classdef cStratFutMultiTDSQ < cStrat
    % Strategy class with TD Sequential
    
    properties
        tdbuysetup_@cell
        tdsellsetup_@cell
        tdbuycountdown_@cell
        tdsellcoundown_@cell
        tdstlevelup_@cell
        tdstleveldn_@cell
        wr_@cell
        macdvec_@cell
        nineperma_@cell
    end
    
    methods
        function obj = cStratFutMultiTDSQ
            obj.name_ = 'multipletdsq';
        end
        %end of cStratFutMultiTDSQ
        
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        [] = printinfo(obj)
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_futmultitdsq2;
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_futmultitdsq2(signals)
        end
        %end of autoplacenewentrusts
        
        function [] = updategreeks(obj)
            obj.updategreeks_futmultitdsq
        end
            
        function [] = riskmanagement(obj,dtnum)
            obj.riskmanagement_futmultitdsq(dtnum)
        end
        
        function [] = initdata(obj)
            obj.initdata_futmultitdsq;
        end
        %end of initdata
                
    end
    
    methods (Access = private)
        [] = riskmanagement_futmultitdsq(obj,dtnum)
        [] = riskmanagement_futmultitdsq2(obj,varargin)
        [] = updategreeks_futmultitdsq(obj)
        signals = gensignals_futmultitdsq(obj)
        signals = gensignals_futmultitdsq2(obj)
        [] = autoplacenewentrusts_futmultitdsq(obj,signals)
        [] = autoplacenewentrusts_futmultitdsq2(obj,signals)
        [] = initdata_futmultiwr(obj)
    end
    
    methods (Access = private)
       [volume] = getlivetradevolume(obj,code,modename,modetype)
    end

    
end



