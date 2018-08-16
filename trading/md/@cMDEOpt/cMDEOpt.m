classdef cMDEOpt < cMyTimerObj
    %Note: the class of Market Data Engine for listed options
    properties
        options_@cInstrumentArray
        underliers_@cInstrumentArray
        qms_@cQMS    
        display_@double = 1
    end
    
    properties
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
        
    end
    
    properties (Access = private)
        quotes_@cell
        pivottable_@cell
    end
    
    methods
        [] = loadoptions(obj,code_ctp_underlier,numstrikes)
        [] = registerinstrument(obj,instrument)
        [] = refresh(obj,varargin)
        tbl = voltable(obj)
        res = getgreeks(obj,instrument)
    end
    
    methods (Access = private)
        [] = savequotes2mem(obj) 
        tbl = genpivottable(obj)
        tbl = displaypivottable(obj)
    end
    
    
    
end