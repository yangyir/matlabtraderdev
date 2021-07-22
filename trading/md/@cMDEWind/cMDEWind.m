classdef cMDEWind < cMyTimerObj
    %the datasource is wind only
    %for now equity/fund only
    
    properties
        conn_@cWind
        codes_@cell
        codeswind_@cell
        freq_@double
        ticksquick_@double
        %
        replayer_@cReplayer
        replay_datetimevec_@double
        replay_idx_@double
        replay_updatetime_@logical = true
        %
        datenum_open_@cell
        datenum_close_@cell
        %
        lastclose_@double
    end
    
    properties
        hcandlesintraday_@cell
        hcandlesdaily_@cell
        candlesintraday_@cell
        candlesdaily_@cell
    end
    
    properties (GetAccess = public, SetAccess = private)
        newset_@double
    end
    
    properties (Access = private)
        ticks_count_@double
        candles_count_@double
    end
    
    methods
        function obj = cMDEWind(varargin)
            obj = init(obj, varargin{:});
        end
    end
    
    methods
        %login/logout
        [ret] = login(obj, varargin)
        [ret] = logoff(obj)
    end
    
    methods
        [] = registercode(obj,code,varargin)
        %
        % abstract methods derived form base class
        
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = savemktdata(obj,varargin)
        [] = savetrades(obj,varargin)
        [] = loadmktdata(obj,varargin)
        [] = loadtrades(obj,varargin)
        [t] = getreplaytime(obj, varargin)
        [] = saveticks2mem(obj)
        [] = updatecandleinmem(obj)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        
        
    end
    
end