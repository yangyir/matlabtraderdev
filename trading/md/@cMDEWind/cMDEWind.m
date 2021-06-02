classdef cMDEWind < cMyTimerObj
    %the datasource is wind only
    
    properties
        conn_@cWind
        codes_@cell
        freq_@cell
    end
    
    properties
        candlesintraday_@cell
        candlesdaily_@cell
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
        [] = refresh(obj, varagin)
        [] = print(obj, varagin)
        [] = savemktdata(obj, varargin)
        [] = savetrades(obj, varargin)
        [] = loadmktdata(obj, varargin)
        [] = loadtrades(obj, varargin)
        [t] = getreplaytime(obj, varargin)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
    end
    
end