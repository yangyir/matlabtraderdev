classdef cMDEOpt < cMyTimerObj
    %Note: the class of Market Data Engine for listed options
    properties
        qms_@cQMS
        %
        options_@cInstrumentArray
        underliers_@cInstrumentArray
        %
        %
        %for underliers
        candles_@cell
        datenum_open_@cell
        datenum_close_@cell
        %
        
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
        categories_@double
    end
    
    methods
        function obj = cMDEOpt(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        %login/logout
        [ret] = login(obj,varargin)
        [ret] = logoff(obj)
    end
    
    methods
        %option specific ones
        [calls,puts] = loadoptions(obj,code_ctp_underlier,numstrikes)
        [] = plotvolslice(obj,code_ctp_underlier,numstrikes,varargin)
        tbl = voltable(obj)
        res = getgreeks(obj,instrument)
        res = getatmgreeks(obj,code_ctp_underlier,varargin)
    end
    
    
    methods
        
        [] = registerinstrument(obj,instrument)
        %
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = savemktdata(obj,varargin)
        [] = savetrades(obj,varargin)
        [] = loadmktdata(obj,varargin)
        [] = loadtrades(obj,varargin)
        [t] = getreplaytime(obj,varargin)
        %
        
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        [] = savequotes2mem(obj) 
        tbl = genpivottable(obj)
        tbl = displaypivottable(obj)
    end
    
    methods (Static = true)
        [] = pnlriskbreakdowneod(obj,underlier_code_ctp,numofstrikes)
    end
    
    
end