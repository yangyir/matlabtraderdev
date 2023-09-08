classdef cMacroCN < cMonitorBase
    %class of macro variables of CHINA
    %
    properties
        w_@cWind
    end
    %
    properties (GetAccess = private,SetAccess = private)
        codes_cash_@char = 'DR007.IB'
        codes_govtbondfut_@cell
        codes_govtbond_@cell
        codes_fx_@char = 'USDCNH.FX'
        codes_eqindex_@char = '000300.SH'
        %
        dailybar_dr007_@double
        dailybar_govtbondfut_@cell
        dailybar_govtbondyields_@cell
        dailybar_fx_@double
        dailybar_eqindex_@double
        %
        printed_@double = 0
        %
        mat_govtbondfut_@cell
        mat_govtbondyields_@cell
        mat_fx_@double
        mat_eqindex_@double
        struct_govtbondfut_@cell
        struct_govtbondyields_@cell
        struct_fx_@struct
        struct_eqindex_@struct
    end
    %
    methods
        %constructor
        function obj = cMacroCN(varargin)
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
    end
    
end