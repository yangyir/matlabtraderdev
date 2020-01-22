classdef cMDEOptBBG < cMyTimerObj
    %Note:the class of market data engine for listed options
    %but the datasource is bloomberg only
    %now only implemented for 50ETF and 300ETF options
    
    properties
        conn_@cBloomberg
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
    
    methods
        function obj = cMDEOptBBG(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        %login/logout
        [ret] = login(obj,varargin)
        [ret] = logoff(obj)
    end
    
    methods
        
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        %
        % abstract methods derived from base class
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = savemktdata(obj,varargin)
        [] = savetrades(obj,varargin)
        [] = loadmktdata(obj,varargin)
        [] = loadtrades(obj,varargin)
        [t] = getreplaytime(obj,varargin)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
    end
    
end

