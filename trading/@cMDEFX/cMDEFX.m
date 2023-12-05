classdef cMDEFX < cMonitorBase
    %class of market data engine of fx
    %frequency = daily only
    %
    properties
        w_@cWind
        ths_@cTHS
    end
    %
    properties (GetAccess = private,SetAccess = private)
        codes_fx_@cell
        instruments_fx_@cell
        %
        dailybar_fx_@cell
        %
        printed_@double = 0
        %
        mat_fx_@cell
        %
        struct_fx_@cell
        %
        trades_fx_@cTradeOpenArray
        trades_dir_@char
        %
        kelly_table_@struct
        
    end
    %
    methods
        %constructor
        function obj = cMDEFX(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = savemktdata(obj,varargin)
        [] = loadmktdata(obj,varargin)
        [] = savetrades(obj,varargin)
        [] = loadtrades(obj,varargin)
        %
        [t] = getreplaytime(obj,varargin)
        %
        [flag] = istime2sleep(obj,t)
        [flag] = istime2print(obj,t)
        [flag] = istime2savemktdata(obj,t)
        [flag] = istime2savetrades(obj,t)
        [flag] = istime2loadmktdata(obj,t)
        [flag] = istime2loadtrades(obj,t)
        %
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        [] = updatesignal_fx(obj,varagin)
        [] = riskmanagement_fx(obj,varargin)
    end
    
end