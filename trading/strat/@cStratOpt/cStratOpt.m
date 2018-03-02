classdef cStratOpt < cStrat
    properties
        delta_underlier_@double
        closeyesterday_underlier_@double
        %
        delta_@double
        gamma_@double
        vega_@double
        theta_@double
        impvol_@double
        %
        deltacarry_@double
        gammacarry_@double
        vegacarry_@double
        thetacarry_@double
        %
        deltacarryyesterday_@double
        gammacarryyesterday_@double
        vegacarryyesterday_@double
        thetacarryyesterday_@double
        impvolcarryyesterday_@double
        pvcarryyesterday_@double
        %
        optnewlytraded_@cell
        
    end
    
    %set/get methods
    methods
        [] = setriskvalue(obj,instrument,riskname,value)
        [value] = getriskvalue(obj,instrument,riskname)
        
    end
    %end of set/get methods
    
    %strategy initialization related
    methods
        %constructor
        function obj = cStratOpt
            obj.name_ = 'stratopt';
        end
        %
        %register instruments
        [] = registerinstrument(obj,instrument)
        [] = registeroptions(obj,code_ctp_underlier,numoptions)
        [] = registeroptionswithstrikes(obj,code_ctp_underlier,strikes)
        %
        %pnl/risk related
        [pnltbl,risktbl] = pnlriskeod(obj)        
        [pnltbl,risktbl] = pnlriskrealtime(obj)
    end
    
    
    %derived methods from cStrat base class
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_opt;
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_opt(signals)
        end
        %end of autoplacenewentrusts
        
        function [] = updategreeks(obj)
            obj.updategreeks_opt
        end
            
        function [] = riskmanagement(obj,dtnum)
            obj.riskmanagement_opt(dtnum)
        end
        
        function [] = initdata(obj)
            obj.initdata_opt;
        end
        %end of initdata
        
    end
    
    methods (Access = private)
        [] = riskmanagement_opt(obj,dtnum)
        [] = updategreeks_opt(obj)
        signals = gensignals_opt(obj)
        [] = autoplacenewentrusts_opt(obj,signals)
        [] = initdata_opt(obj) 
    end
    
    
end