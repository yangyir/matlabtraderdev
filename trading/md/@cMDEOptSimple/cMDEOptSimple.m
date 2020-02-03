classdef cMDEOptSimple < cMyTimerObj
    %Note: the class of Market Data Engine for listed options - simple
    %version
    properties
        qms_@cQMS
        %
        options_@cInstrumentArray
        underliers_@cInstrumentArray
        %
        strikes_@cell
        %
        tradeflag_@logical = false
        countertype_@char = 'ctp'
        threshold_@double
        nmaxtradeperday_@double
    end
    
    properties
        counterctp_@CounterCTP
        counterrh_@CounterRH
    end
    
    properties (Access = private)
%         quotes_@cell
%         pivottable_@cell
%         categories_@double
    end
    
    methods
        function obj = cMDEOptSimple(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        %login/logout
        [ret] = login(obj,varargin)
        [ret] = logoff(obj)
    end
    
    methods
        %cMDEOptSimple specific ones
        [] = registeroptions(obj,underlier,strikes)
        [sellfwdlongspot,sellspotlongfwd,fwdbid,fwdask] = cpparb(obj,underlier)
        %trading related
        [] = setthreshold(obj,underlier,val)
        [] = setnmax(obj,underlier,val)
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
%         [] = savequotes2mem(obj) 
%         tbl = genpivottable(obj)
%         tbl = displaypivottable(obj)
    end
    
    methods (Static = true)
        [] = pnlriskbreakdowneod(obj,underlier_code_ctp,numofstrikes)
    end
    
    
end