classdef cGUIFut < cMyTimerObj
    %cGUIFUT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mdefut_@cMDEFut
        handles_@struct
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
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
    end
        
end

