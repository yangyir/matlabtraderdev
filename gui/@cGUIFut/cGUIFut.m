classdef cGUIFut < cMyTimerObj
    %cGUIFUT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        countername_@char
        mdefut_@cMDEFut
        handles_@struct
    end
    
    properties (Hidden = true)
        code2plot_@char
    end
    
    methods
        function obj = cGUIFut(varargin)
            obj = init(obj,varargin{:});
        end
    end
    
    methods
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = savemktdata(obj,varargin)
        [] = savetrades(obj,varargin)
        [] = loadmktdata(obj,varargin)
        [] = loadtrades(obj,varargin)
        [t] = getreplaytime(obj,varargin)
        [ret] = login(obj,varargin)
        [ret] = logoff(obj)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        [output] = refreshtbl(obj,varargin)
        [] = refreshplot(obj,varargin)
    end
        
end

