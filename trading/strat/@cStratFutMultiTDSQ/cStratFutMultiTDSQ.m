classdef cStratFutMultiTDSQ < cStrat
    % Strategy class with TD Sequential
    
    properties
        tdbuysetup_@cell
        tdsellsetup_@cell
        tdbuycountdown_@cell
        tdsellcountdown_@cell
        tdstlevelup_@cell
        tdstleveldn_@cell
        wr_@cell
        macdvec_@cell
        nineperma_@cell
        %
        useperfect_@double
        usesemiperfect_@double
        useimperfect_@double
        usesinglelvlup_@double
        usesinglelvldn_@double
        usedoublerange_@double
        usedoublebullish_@double
        usedoublebearish_@double
        usesimpletrend_@double
        %
        %
        signals_@cell
    end
    
    properties
        targetportfolio_@double
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
        %
        [is2closetrade,entrustplaced] = riskmanagement_perfectbs(obj,tradein,varargin)
        [is2closetrade,entrustplaced] = riskmanagement_semiperfectbs(obj,tradein,varargin)
        [is2closetrade,entrustplaced] = riskmanagement_imperfectbs(obj,tradein,varargin)
        %
        [is2closetrade,entrustplaced] = riskmanagement_perfectss(obj,tradein,varargin)
        [is2closetrade,entrustplaced] = riskmanagement_semiperfectss(obj,tradein,varargin)
        [is2closetrade,entrustplaced] = riskmanagement_imperfectss(obj,tradein,varargin)
        %
        [is2closetrade,entrustplaced] = riskmanagement_singlelvldn(obj,tradein,varargin)
        [is2closetrade,entrustplaced] = riskmanagement_singlelvlup(obj,tradein,varargin)
        [is2closetrade,entrustplaced] = riskmanagement_doublerange(obj,tradein,varargin)
        [is2closetrade,entrustplaced] = riskmanagement_doublebullish(obj,tradein,varargin)
        [is2closetrade,entrustplaced] = riskmanagement_doublebearish(obj,tradein,varargin)
        %
        [] = updategreeks_futmultitdsq(obj)
        signals = gensignals_futmultitdsq(obj)
        signals = gensignals_futmultitdsq2(obj)
        [] = autoplacenewentrusts_futmultitdsq(obj,signals)
        [] = autoplacenewentrusts_futmultitdsq2(obj,signals)
        [] = initdata_futmultiwr(obj)
    end
    
    methods (Access = private)
       [trade] = getlivetrade_tdsq(obj,code,modename,typename)
       %

       %TODO
       %in realtime trading with bigger volume per trade, we might be
       %unable to execute the total required volume, e.g. 50 lots in one
       %trade. Alternatively, we would split the total required volume into
       %several small pieces, e.g. 5 per trade. As a result, more than one
       %trades are associated with the same mode/type, e.g.
       %reverse/perfectbs. A workround shall be implemented at a later
       %stage.
    end

    
end



